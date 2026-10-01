import {
    Injectable,
    ConflictException,
    UnauthorizedException,
    BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { hashPassword, verifyPassword } from './argon2.util';
import { RegisterManagerDto } from './dto/register-manager.dto';
import { LoginDto } from './dto/login.dto';
import { Role, Prisma } from '@prisma/client';

import { AuditService } from '../audit/audit.service';

@Injectable()
export class AuthService {
    constructor(
        private prisma: PrismaService,
        private jwt: JwtService,
        private config: ConfigService,
        private audit: AuditService,
    ) { }

    async registerManager(dto: RegisterManagerDto) {
        if (dto.password !== dto.confirmPassword) {
            throw new BadRequestException('Passwords do not match');
        }

        // Uniqueness check — do this before hashing anything, cheap fail-fast
        const existing = await this.prisma.user.findFirst({
            where: { OR: [{ email: dto.email }, { mobile: dto.mobile }] },
        });
        if (existing) {
            throw new ConflictException(
                existing.email === dto.email
                    ? 'Email already registered'
                    : 'Mobile number already registered',
            );
        }

        // Never trust that a submitted districtId actually belongs to the
        // submitted stateId — verify server-side, same principle you already
        // logged for engineer ownership in Phase 4's notes
        const district = await this.prisma.district.findUnique({
            where: { id: dto.districtId },
        });
        if (!district || district.stateId !== dto.stateId) {
            throw new BadRequestException(
                'Selected district does not belong to the selected state',
            );
        }

        const passwordHash = await hashPassword(dto.password);

        let user;
        try {
            user = await this.prisma.user.create({
                data: {
                    email: dto.email,
                    mobile: dto.mobile,
                    passwordHash,
                    role: Role.MANAGER,
                    managerProfile: {
                        create: {
                            fullName: dto.fullName,
                            stateId: dto.stateId,
                            districtId: dto.districtId,
                        },
                    },
                },
            });
        } catch (error: any) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
                throw new ConflictException('Email or mobile number is already registered');
            }
            throw error;
        }

        // Audit log for registration (no actorId since self-registration)
        this.audit.log({
            action: 'REGISTER',
            targetType: 'USER',
            targetId: user.id,
            metadata: { email: user.email, mobile: user.mobile, role: user.role },
        });

        // Per spec §9: no auto-login. Return a confirmation, not tokens.
        return { id: user.id, email: user.email, message: 'Registered. Please log in.' };
    }

    async login(dto: LoginDto) {
        const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
        if (!user) throw new UnauthorizedException('Invalid credentials');
        if (!user.isActive) throw new UnauthorizedException('Account is deactivated');

        const valid = await verifyPassword(user.passwordHash, dto.password);
        if (!valid) throw new UnauthorizedException('Invalid credentials');

        return this.issueTokens(user.id, user.role);
    }

    async refresh(refreshToken: string) {
        const tokenHash = this.hashToken(refreshToken);

        const stored = await this.prisma.refreshToken.findFirst({ where: { tokenHash } });

        if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
            throw new UnauthorizedException('Invalid or expired refresh token');
        }

        const user = await this.prisma.user.findUnique({ where: { id: stored.userId } });
        if (!user) throw new UnauthorizedException('User no longer exists');

        const tokens = await this.issueTokens(user.id, user.role);

        // Rotation: the token just used is immediately dead, even if this
        // isn't reused again. This is what makes reuse-detection possible
        // later if you want to add it (a revoked token being presented again
        // is a strong signal of theft).
        await this.prisma.refreshToken.update({
            where: { id: stored.id },
            data: { 
                revokedAt: new Date(),
                replacedByHash: this.hashToken(tokens.refreshToken)
            },
        });

        return tokens;
    }

    async logout(refreshToken: string) {
        const tokenHash = this.hashToken(refreshToken);
        await this.prisma.refreshToken.updateMany({
            where: { tokenHash },
            data: { revokedAt: new Date() },
        });
        return { message: 'Logged out' };
    }

    private async issueTokens(userId: string, role: Role) {
        const accessToken = this.jwt.sign(
            { userId, role },
            {
                secret: this.config.get('JWT_SECRET'),
                expiresIn: this.config.get('JWT_ACCESS_EXPIRY') || '15m',
            },
        );

        const refreshTokenRaw = crypto.randomBytes(40).toString('hex');
        const tokenHash = this.hashToken(refreshTokenRaw);
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 30);

        await this.prisma.refreshToken.create({
            data: { userId, tokenHash, expiresAt },
        });

        return { accessToken, refreshToken: refreshTokenRaw };
    }

    private hashToken(token: string) {
        return crypto.createHash('sha256').update(token).digest('hex');
    }
}