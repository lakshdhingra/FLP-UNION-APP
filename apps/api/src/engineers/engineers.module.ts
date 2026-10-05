import { Module } from '@nestjs/common';
import { EngineersController } from './engineers.controller';
import { EngineersService } from './engineers.service';
import { S3Module } from '../s3/s3.module';

@Module({
  imports: [S3Module],
  controllers: [EngineersController],
  providers: [EngineersService],
})
export class EngineersModule {}

