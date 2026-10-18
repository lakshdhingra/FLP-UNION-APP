import { Module } from '@nestjs/common';
import { ManagersController } from './managers.controller';
import { ManagersService } from './managers.service';
import { S3Module } from '../s3/s3.module';

@Module({
    imports: [S3Module],
    controllers: [ManagersController],
    providers: [ManagersService],
    exports: [ManagersService],
})
export class ManagersModule {}
