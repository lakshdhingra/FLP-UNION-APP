import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuditService {
    constructor(private prisma: PrismaService) {}

    async log(opts: {
        actorId?: string;
        action: string;
        targetType: string;
        targetId?: string;
        metadata?: Record<string, unknown>;
    }) {
        try {
            await this.prisma.auditLog.create({
                data: {
                    actorId: opts.actorId,
                    action: opts.action,
                    targetType: opts.targetType,
                    targetId: opts.targetId,
                    metadata: opts.metadata as any,
                },
            });
        } catch {
            // Audit failures must never crash the primary flow
        }
    }
}
