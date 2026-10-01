import { Module, Global } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

import { PrismaModule } from '../prisma/prisma.module';

import { NotificationsController } from './notifications.controller';

@Global()
@Module({
    imports: [PrismaModule],
    controllers: [NotificationsController],
    providers: [NotificationsService],
    exports: [NotificationsService],
})
export class NotificationsModule {}
