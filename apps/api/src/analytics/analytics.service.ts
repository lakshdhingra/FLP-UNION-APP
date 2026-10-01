import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AnalyticsService {
    constructor(private prisma: PrismaService) {}

    async getAdminSummary() {
        const [states, districts, managers, engineers, issues, openIssues] = await Promise.all([
            this.prisma.state.count({ where: { isActive: true } }),
            this.prisma.district.count({ where: { isActive: true } }),
            this.prisma.managerProfile.count(),
            this.prisma.engineer.count(),
            this.prisma.issue.count(),
            this.prisma.issue.count({ where: { status: 'OPEN' } }),
        ]);

        const engineersByState = await this.prisma.state.findMany({
            select: {
                name: true,
                _count: { select: { engineers: true } },
            },
            where: { isActive: true },
            orderBy: { name: 'asc' },
        });

        const activeEngineers = await this.prisma.engineer.count({ where: { isActive: true } });

        return {
            states,
            districts,
            managers,
            engineers,
            activeEngineers,
            inactiveEngineers: engineers - activeEngineers,
            issues,
            openIssues,
            engineersByState: engineersByState.map((s: { name: string; _count: { engineers: number } }) => ({
                state: s.name,
                count: s._count.engineers,
            })),
        };
    }
}
