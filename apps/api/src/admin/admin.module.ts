import { Module } from '@nestjs/common';
import { S3Module } from '../s3/s3.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
    imports: [S3Module],
    controllers: [AdminController],
    providers: [AdminService],
})
export class AdminModule {}
