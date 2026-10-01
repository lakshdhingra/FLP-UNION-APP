import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationType } from '@prisma/client';

@Injectable()
export class NotificationsService {
    constructor(private prisma: PrismaService) {}

    async createNotification(opts: {
        userId: string;
        type: NotificationType;
        title: string;
        body: string;
        data?: Record<string, unknown>;
    }) {
        return this.prisma.notification.create({
            data: {
                userId: opts.userId,
                type: opts.type,
                title: opts.title,
                body: opts.body,
                data: opts.data as any,
            },
        });
    }

    async getForUser(userId: string) {
        return this.prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: 50,
        });
    }

    async markRead(userId: string, notificationId: string) {
        return this.prisma.notification.updateMany({
            where: { id: notificationId, userId },
            data: { isRead: true },
        });
    }
}
