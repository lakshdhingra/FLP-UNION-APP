import { Controller, Get, Patch, Param, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { ApiTags } from '@nestjs/swagger';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) {}

    @Get()
    getNotifications(@Request() req: any) {
        return this.notificationsService.getForUser(req.user.userId);
    }

    @Patch(':id/read')
    markRead(@Request() req: any, @Param('id') id: string) {
        return this.notificationsService.markRead(req.user.userId, id);
    }
}
