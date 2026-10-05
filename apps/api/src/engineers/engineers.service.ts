import {
    Injectable,
    NotFoundException,
    ForbiddenException,
    BadRequestException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { maskPhone, maskEmail } from '../common/masking.util';
import { CreateEngineerDto } from './dto/create-engineer.dto';
import { UpdateEngineerDto } from './dto/update-engineer.dto';

interface FindMineOptions {
    search?: string;
    designation?: string;
    page?: number;
    limit?: number;
}

import { AuditService } from '../audit/audit.service';
import { S3Service } from '../s3/s3.service';
import { GetEngineerUploadUrlDto } from './dto/get-upload-url.dto';

@Injectable()
export class EngineersService {
    constructor(
        private prisma: PrismaService,
        private audit: AuditService,
        private s3Service: S3Service,
    ) {}

    async getUploadUrl(dto: GetEngineerUploadUrlDto) {
        return this.s3Service.getPresignedUploadUrl(
            'android/sub-members',
            dto.fileName,
            dto.mimeType,
        );
    }

    async getDocumentUrl(userId: string, key: string) {
        if (!key) {
            throw new BadRequestException('Key parameter is required');
        }

        const manager = await this.getManagerProfile(userId);

        // Verify key belongs to an engineer accessible to the manager
        const engineer = await this.prisma.engineer.findFirst({
            where: { profilePhotoUrl: key },
        });

        if (engineer) {
            if (engineer.stateId !== manager.stateId) {
                throw new ForbiddenException('You do not have permission to access this document');
            }
        } else {
            // For keys not yet linked to an engineer record, restrict to sub-members folder
            if (!key.startsWith('android/sub-members/')) {
                throw new ForbiddenException('Access denied for this key path');
            }
        }

        const signedUrl = await this.s3Service.getPresignedDownloadUrl(key, 3600);
        return { signedUrl };
    }

    private async getManagerProfile(userId: string) {
        const profile = await this.prisma.managerProfile.findUnique({
            where: { userId },
        });
        if (!profile) throw new ForbiddenException('No manager profile for this user');
        return profile;
    }

    // ─── Own engineers: full CRUD ─────────────────────────────────────────

    async findMine(userId: string, opts: FindMineOptions = {}) {
        const manager = await this.getManagerProfile(userId);
        const page = opts.page ? parseInt(opts.page as any, 10) : 1;
        const limit = opts.limit ? Math.min(parseInt(opts.limit as any, 10), 50) : 20;
        const skip = (page - 1) * limit;

        const where: any = {
            managerId: manager.id,
            ...(opts.search ? {
                fullName: { contains: opts.search, mode: 'insensitive' },
            } : {}),
            ...(opts.designation ? {
                designation: { contains: opts.designation, mode: 'insensitive' },
            } : {}),
        };

        const [engineers, total] = await Promise.all([
            this.prisma.engineer.findMany({
                where,
                skip,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    district: { select: { name: true } },
                    state: { select: { name: true } },
                },
            }),
            this.prisma.engineer.count({ where })
        ]);

        return {
            data: engineers,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            }
        };
    }

    async create(userId: string, dto: CreateEngineerDto) {
        const manager = await this.getManagerProfile(userId);

        const district = await this.prisma.district.findUnique({
            where: { id: dto.districtId },
        });
        if (!district || district.stateId !== manager.stateId) {
            throw new ForbiddenException('District does not belong to your state');
        }

        const { 
            districtId, fullName, phone, email, profilePhotoUrl, address, 
            skills, experienceYears, designation, govIdType, govIdNumber, 
            salary, privateNotes 
        } = dto;

        try {
            const engineer = await this.prisma.engineer.create({
                data: {
                    fullName, phone, email, profilePhotoUrl, address, skills, 
                    experienceYears, designation, govIdType, govIdNumber, 
                    salary, privateNotes,
                    stateId: manager.stateId,
                    districtId,
                    managerId: manager.id,
                },
                include: {
                    district: { select: { name: true } },
                    state: { select: { name: true } },
                },
            });
            this.audit.log({ actorId: userId, action: 'CREATE', targetType: 'ENGINEER', targetId: engineer.id, metadata: dto as any });
            return engineer;
        } catch (error: any) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
                throw new BadRequestException('An engineer with this phone number already exists in your directory.');
            }
            throw error;
        }
    }

    async update(userId: string, engineerId: string, dto: UpdateEngineerDto) {
        const manager = await this.getManagerProfile(userId);
        const engineer = await this.prisma.engineer.findUnique({ where: { id: engineerId } });

        if (!engineer) throw new NotFoundException('Engineer not found');
        if (engineer.managerId !== manager.id) {
            throw new ForbiddenException('You do not own this engineer');
        }

        if (dto.districtId) {
            const district = await this.prisma.district.findUnique({
                where: { id: dto.districtId },
            });
            if (!district || district.stateId !== manager.stateId) {
                throw new ForbiddenException('District does not belong to your state');
            }
        }

        try {
            const updated = await this.prisma.engineer.update({
                where: { id: engineerId },
                data: dto,
                include: {
                    district: { select: { name: true } },
                    state: { select: { name: true } },
                },
            });
            this.audit.log({ actorId: userId, action: 'UPDATE', targetType: 'ENGINEER', targetId: engineerId, metadata: dto as any });
            return updated;
        } catch (error: any) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
                throw new BadRequestException('An engineer with this phone number already exists in your directory.');
            }
            throw error;
        }
    }

    async remove(userId: string, engineerId: string) {
        const manager = await this.getManagerProfile(userId);
        const engineer = await this.prisma.engineer.findUnique({ where: { id: engineerId } });

        if (!engineer) throw new NotFoundException('Engineer not found');
        if (engineer.managerId !== manager.id) {
            throw new ForbiddenException('You do not own this engineer');
        }

        await this.prisma.engineer.delete({ where: { id: engineerId } });
        this.audit.log({ actorId: userId, action: 'DELETE', targetType: 'ENGINEER', targetId: engineerId });
        return { message: 'Engineer deleted' };
    }

    // ─── Cross-manager, same-state: read-only, masked ─────────────────────

    async findOne(userId: string, engineerId: string) {
        const manager = await this.getManagerProfile(userId);
        const engineer = await this.prisma.engineer.findUnique({
            where: { id: engineerId },
            include: {
                district: { select: { name: true } },
                state: { select: { name: true } },
                manager: {
                    select: {
                        id: true,
                        fullName: true,
                    },
                },
            },
        });

        if (!engineer || engineer.stateId !== manager.stateId) {
            throw new NotFoundException('Engineer not found');
        }

        if (engineer.managerId === manager.id) {
            return { ...engineer, isOwned: true };
        }

        return { ...this.maskEngineer(engineer), isOwned: false };
    }

    private maskEngineer(engineer: any) {
        return {
            id: engineer.id,
            fullName: engineer.fullName,
            phone: maskPhone(engineer.phone),
            email: engineer.email ? maskEmail(engineer.email) : null,
            profilePhotoUrl: engineer.profilePhotoUrl,
            stateId: engineer.stateId,
            state: engineer.state,
            districtId: engineer.districtId,
            district: engineer.district,
            skills: engineer.skills,
            experienceYears: engineer.experienceYears,
            designation: engineer.designation,
            isActive: engineer.isActive,
            createdAt: engineer.createdAt,
            manager: engineer.manager,
            // Omitted: address, govIdType, govIdNumber, salary, privateNotes, managerId
        };
    }
}
