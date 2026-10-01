import {
    Injectable,
    NotFoundException,
    ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { maskPhone, maskEmail } from '../common/masking.util';
import { UpdateManagerDto } from './dto/update-manager.dto';

interface FindManagersOptions {
    search?: string;
    districtId?: string;
    page?: number;
    limit?: number;
}

import { AuditService } from '../audit/audit.service';

@Injectable()
export class ManagersService {
    constructor(
        private prisma: PrismaService,
        private audit: AuditService,
    ) {}

    private async getManagerProfile(userId: string) {
        const profile = await this.prisma.managerProfile.findUnique({
            where: { userId },
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
                user: { select: { email: true, mobile: true } },
                _count: { select: { engineers: true } },
            },
        });
        if (!profile) throw new ForbiddenException('No manager profile for this user');
        return profile;
    }

    async getProfile(userId: string) {
        const profile = await this.getManagerProfile(userId);
        return {
            id: profile.id,
            fullName: profile.fullName,
            profilePhotoUrl: profile.profilePhotoUrl,
            email: profile.user.email,
            mobile: profile.user.mobile,
            state: profile.state,
            district: profile.district,
            totalEngineers: profile._count.engineers,
        };
    }

    async updateProfile(userId: string, dto: UpdateManagerDto) {
        const profile = await this.getManagerProfile(userId);
        const updated = await this.prisma.managerProfile.update({
            where: { id: profile.id },
            data: dto,
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
            },
        });
        this.audit.log({ actorId: userId, action: 'UPDATE_PROFILE', targetType: 'MANAGER_PROFILE', targetId: profile.id, metadata: dto as any });
        return updated;
    }

    async getDashboard(userId: string) {
        const manager = await this.prisma.managerProfile.findUnique({
            where: { userId },
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
                user: { select: { email: true, mobile: true } },
                _count: { select: { engineers: true } },
            },
        });
        if (!manager) throw new ForbiddenException('No manager profile');

        const engineers = await this.prisma.engineer.findMany({
            where: { managerId: manager.id },
            select: {
                isActive: true,
                experienceYears: true,
                designation: true,
                skills: true,
            },
        });

        const activeCount = engineers.filter((e: any) => e.isActive).length;
        const designations: Record<string, number> = {};
        engineers.forEach((e: any) => {
            if (e.designation) {
                designations[e.designation] = (designations[e.designation] ?? 0) + 1;
            }
        });

        const expBuckets = { '0-2': 0, '3-5': 0, '6-10': 0, '10+': 0 };
        engineers.forEach((e: any) => {
            const yrs = Number(e.experienceYears ?? 0);
            if (yrs <= 2) expBuckets['0-2']++;
            else if (yrs <= 5) expBuckets['3-5']++;
            else if (yrs <= 10) expBuckets['6-10']++;
            else expBuckets['10+']++;
        });

        return {
            manager: {
                id: manager.id,
                fullName: manager.fullName,
                profilePhotoUrl: manager.profilePhotoUrl,
                email: manager.user.email,
                mobile: manager.user.mobile,
                state: manager.state,
                district: manager.district,
            },
            stats: {
                totalEngineers: manager._count.engineers,
                activeEngineers: activeCount,
                inactiveEngineers: manager._count.engineers - activeCount,
                designationDistribution: designations,
                experienceDistribution: expBuckets,
            },
        };
    }

    async findSameStateManagers(userId: string, opts: FindManagersOptions) {
        const myProfile = await this.getManagerProfile(userId);
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 50);
        const skip = (page - 1) * limit;

        const where: any = {
            stateId: myProfile.stateId,
            userId: { not: userId }, // exclude self
            ...(opts.districtId ? { districtId: opts.districtId } : {}),
            ...(opts.search ? { fullName: { contains: opts.search, mode: 'insensitive' } } : {}),
        };

        const [managers, total] = await Promise.all([
            this.prisma.managerProfile.findMany({
                where,
                skip,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    state: { select: { id: true, name: true } },
                    district: { select: { id: true, name: true } },
                    user: { select: { email: true, mobile: true } },
                    _count: { select: { engineers: true } },
                },
            }),
            this.prisma.managerProfile.count({ where }),
        ]);

        return {
            data: managers.map((m: any) => this.formatManagerPublic(m)),
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async findManagerById(userId: string, targetManagerId: string) {
        const myProfile = await this.getManagerProfile(userId);
        const target = await this.prisma.managerProfile.findUnique({
            where: { id: targetManagerId },
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
                user: { select: { email: true, mobile: true } },
                _count: { select: { engineers: true } },
            },
        });

        if (!target || target.stateId !== myProfile.stateId) {
            throw new NotFoundException('Manager not found');
        }

        return this.formatManagerPublic(target);
    }

    async findManagerEngineers(userId: string, targetManagerId: string) {
        const myProfile = await this.getManagerProfile(userId);
        const target = await this.prisma.managerProfile.findUnique({
            where: { id: targetManagerId },
        });

        if (!target || target.stateId !== myProfile.stateId) {
            throw new NotFoundException('Manager not found');
        }

        const engineers = await this.prisma.engineer.findMany({
            where: { managerId: targetManagerId },
            orderBy: { fullName: 'asc' },
            include: {
                district: { select: { name: true } },
                state: { select: { name: true } },
            },
        });

        // Own managers engineers = full (shouldn't happen here since 'managers/:id',
        // but handle if user views self)
        if (targetManagerId === myProfile.id) {
            return engineers.map((e: any) => ({ ...e, isOwned: true }));
        }

        // Mask all sensitive info
        return engineers.map((e: any) => ({
            id: e.id,
            fullName: e.fullName,
            phone: maskPhone(e.phone),
            email: e.email ? maskEmail(e.email) : null,
            profilePhotoUrl: e.profilePhotoUrl,
            state: e.state,
            district: e.district,
            skills: e.skills,
            experienceYears: e.experienceYears,
            designation: e.designation,
            isActive: e.isActive,
            isOwned: false,
        }));
    }

    private formatManagerPublic(m: any) {
        return {
            id: m.id,
            fullName: m.fullName,
            profilePhotoUrl: m.profilePhotoUrl,
            email: m.user.email,
            mobile: m.user.mobile,
            state: m.state,
            district: m.district,
            totalEngineers: m._count.engineers,
        };
    }
}
