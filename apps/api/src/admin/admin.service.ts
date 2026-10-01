import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { IssueStatus } from '@prisma/client';
import { CreateStateDto, UpdateStateDto, CreateDistrictDto, UpdateDistrictDto, AdminUpdateEngineerDto } from './dto/admin.dto';

import { AuditService } from '../audit/audit.service';

@Injectable()
export class AdminService {
    constructor(
        private prisma: PrismaService,
        private audit: AuditService,
    ) {}

    // ─── States ───────────────────────────────────────────────────────────

    async createState(actorId: string, dto: CreateStateDto) {
        try {
            const state = await this.prisma.state.create({ data: { name: dto.name } });
            this.audit.log({ actorId, action: 'CREATE', targetType: 'STATE', targetId: state.id, metadata: dto as any });
            return state;
        } catch (e: any) {
            if (e.code === 'P2002') throw new ConflictException('State name already exists');
            throw e;
        }
    }

    async findAllStates(includeInactive = false) {
        return this.prisma.state.findMany({
            where: includeInactive ? {} : { isActive: true },
            orderBy: { name: 'asc' },
            include: { _count: { select: { districts: true, managerProfiles: true, engineers: true } } },
        });
    }

    async updateState(actorId: string, id: string, dto: UpdateStateDto) {
        try {
            const state = await this.prisma.state.update({ where: { id }, data: dto });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'STATE', targetId: id, metadata: dto as any });
            return state;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('State not found');
            throw e;
        }
    }

    // ─── Districts ────────────────────────────────────────────────────────

    async createDistrict(actorId: string, dto: CreateDistrictDto) {
        const state = await this.prisma.state.findUnique({ where: { id: dto.stateId } });
        if (!state) throw new NotFoundException('State not found');
        try {
            const district = await this.prisma.district.create({ data: { name: dto.name, stateId: dto.stateId } });
            this.audit.log({ actorId, action: 'CREATE', targetType: 'DISTRICT', targetId: district.id, metadata: dto as any });
            return district;
        } catch (e: any) {
            if (e.code === 'P2002') throw new ConflictException('District name already exists in this state');
            throw e;
        }
    }

    async findAllDistricts(stateId?: string) {
        return this.prisma.district.findMany({
            where: stateId ? { stateId } : {},
            orderBy: { name: 'asc' },
            include: {
                state: { select: { name: true } },
                _count: { select: { managerProfiles: true, engineers: true } },
            },
        });
    }

    async updateDistrict(actorId: string, id: string, dto: UpdateDistrictDto) {
        try {
            const district = await this.prisma.district.update({ where: { id }, data: dto });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'DISTRICT', targetId: id, metadata: dto as any });
            return district;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('District not found');
            throw e;
        }
    }

    // ─── Managers ─────────────────────────────────────────────────────────

    async findAllManagers(opts: { stateId?: string; search?: string; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = {
            ...(opts.stateId ? { stateId: opts.stateId } : {}),
            ...(opts.search ? { fullName: { contains: opts.search, mode: 'insensitive' } } : {}),
        };
        const [data, total] = await Promise.all([
            this.prisma.managerProfile.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    state: { select: { id: true, name: true } },
                    district: { select: { id: true, name: true } },
                    user: { select: { id: true, email: true, mobile: true, createdAt: true } },
                    _count: { select: { engineers: true } },
                },
            }),
            this.prisma.managerProfile.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    async findManagerById(id: string) {
        const m = await this.prisma.managerProfile.findUnique({
            where: { id },
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
                user: { select: { id: true, email: true, mobile: true, createdAt: true } },
                _count: { select: { engineers: true } },
            },
        });
        if (!m) throw new NotFoundException('Manager not found');
        return m;
    }

    // ─── Engineers ────────────────────────────────────────────────────────

    async findAllEngineers(opts: { stateId?: string; managerId?: string; search?: string; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = {
            ...(opts.stateId ? { stateId: opts.stateId } : {}),
            ...(opts.managerId ? { managerId: opts.managerId } : {}),
            ...(opts.search ? { fullName: { contains: opts.search, mode: 'insensitive' } } : {}),
        };
        const [data, total] = await Promise.all([
            this.prisma.engineer.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    state: { select: { name: true } },
                    district: { select: { name: true } },
                    manager: { select: { fullName: true } },
                },
            }),
            this.prisma.engineer.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    async findEngineerById(id: string) {
        const e = await this.prisma.engineer.findUnique({
            where: { id },
            include: {
                state: { select: { name: true } },
                district: { select: { name: true } },
                manager: { select: { fullName: true } },
            },
        });
        if (!e) throw new NotFoundException('Engineer not found');
        return e;
    }

    async updateEngineer(actorId: string, id: string, data: AdminUpdateEngineerDto) {
        try {
            const engineer = await this.prisma.engineer.update({ where: { id }, data });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'ENGINEER', targetId: id, metadata: data as any });
            return engineer;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('Engineer not found');
            throw e;
        }
    }

    async deleteEngineer(actorId: string, id: string) {
        try {
            await this.prisma.engineer.delete({ where: { id } });
            this.audit.log({ actorId, action: 'DELETE', targetType: 'ENGINEER', targetId: id });
            return { message: 'Engineer deleted' };
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('Engineer not found');
            throw e;
        }
    }

    // ─── Issues (admin view) ──────────────────────────────────────────────

    async findAllIssues(opts: { status?: IssueStatus; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = opts.status ? { status: opts.status } : {};
        const [data, total] = await Promise.all([
            this.prisma.issue.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    reporter: {
                        select: {
                            email: true,
                            managerProfile: { select: { fullName: true } },
                        },
                    },
                },
            }),
            this.prisma.issue.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    // ─── Audit Logs ───────────────────────────────────────────────────────

    async findAuditLogs(opts: { page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 50, 200);
        const [data, total] = await Promise.all([
            this.prisma.auditLog.findMany({
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    actor: { select: { email: true, managerProfile: { select: { fullName: true } } } },
                },
            }),
            this.prisma.auditLog.count(),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }
}
