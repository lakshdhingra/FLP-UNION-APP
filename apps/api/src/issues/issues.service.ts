import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateIssueDto } from './dto/create-issue.dto';
import { IssueStatus } from '@prisma/client';

import { AuditService } from '../audit/audit.service';

@Injectable()
export class IssuesService {
    constructor(
        private prisma: PrismaService,
        private audit: AuditService,
    ) {}

    async create(userId: string, dto: CreateIssueDto) {
        const issue = await this.prisma.issue.create({
            data: { ...dto, reporterId: userId },
        });
        this.audit.log({
            actorId: userId,
            action: 'CREATE',
            targetType: 'ISSUE',
            targetId: issue.id,
            metadata: dto as any,
        });
        return issue;
    }

    async findMine(userId: string) {
        return this.prisma.issue.findMany({
            where: { reporterId: userId },
            orderBy: { createdAt: 'desc' },
        });
    }

    async findOne(userId: string, id: string, role: string) {
        const issue = await this.prisma.issue.findUnique({ where: { id } });
        if (!issue) throw new NotFoundException('Issue not found');
        if (role !== 'ADMIN' && issue.reporterId !== userId) {
            throw new ForbiddenException('Access denied');
        }
        return issue;
    }

    // Admin only
    async findAll(opts: { status?: IssueStatus; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const skip = (page - 1) * limit;
        const where = opts.status ? { status: opts.status } : {};
        const [data, total] = await Promise.all([
            this.prisma.issue.findMany({
                where,
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    reporter: { select: { email: true, managerProfile: { select: { fullName: true } } } },
                },
            }),
            this.prisma.issue.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    async updateStatus(actorId: string, id: string, status: IssueStatus) {
        const issue = await this.prisma.issue.update({
            where: { id },
            data: { status, ...(status === 'RESOLVED' ? { resolvedAt: new Date() } : {}) },
        });
        this.audit.log({
            actorId,
            action: 'UPDATE_STATUS',
            targetType: 'ISSUE',
            targetId: id,
            metadata: { status },
        });
        return issue;
    }
}
