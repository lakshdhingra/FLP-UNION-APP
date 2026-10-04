import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { StatesModule } from './states/states.module';
import { EngineersModule } from './engineers/engineers.module';
import { ManagersModule } from './managers/managers.module';
import { DistrictsModule } from './districts/districts.module';
import { AdminModule } from './admin/admin.module';
import { IssuesModule } from './issues/issues.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AuditModule } from './audit/audit.module';
import { NotificationsModule } from './notifications/notifications.module';
import { MembershipModule } from './membership/membership.module';
import { S3Module } from './s3/s3.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        ThrottlerModule.forRootAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: (config: ConfigService) => [
                {
                    ttl: Number(config.get('AUTH_RATE_LIMIT_TTL') ?? 60) * 1000,
                    limit: Number(config.get('AUTH_RATE_LIMIT_MAX') ?? 10),
                },
            ],
        }),
        PrismaModule,
        AuthModule,
        StatesModule,
        DistrictsModule,
        EngineersModule,
        ManagersModule,
        AdminModule,
        IssuesModule,
        AnalyticsModule,
        AuditModule,
        NotificationsModule,
        MembershipModule,
        S3Module,
    ],
    providers: [
        // Global JWT guard — all routes require auth unless @Public() is present
        { provide: APP_GUARD, useClass: JwtAuthGuard },
        // Global roles guard — enforces @Roles() on any route
        { provide: APP_GUARD, useClass: RolesGuard },
        // Global rate-limiter — enforces ThrottlerModule config on all routes
        { provide: APP_GUARD, useClass: ThrottlerGuard },
    ],
})
export class AppModule {}

