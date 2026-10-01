import {
    Controller, Get, Post, Patch, Param, Body, Query,
    UseGuards, ParseUUIDPipe,
} from '@nestjs/common';
import { IssuesService } from './issues.service';
import { CreateIssueDto } from './dto/create-issue.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';
import { Role, IssueStatus } from '@prisma/client';
import { IsEnum, IsOptional } from 'class-validator';

class UpdateStatusDto {
    @IsEnum(IssueStatus)
    status!: IssueStatus;
}

import { ApiTags } from '@nestjs/swagger';

@ApiTags('Issues')
@Controller('issues')
@UseGuards(JwtAuthGuard, RolesGuard)
export class IssuesController {
    constructor(private readonly service: IssuesService) {}

    @Post()
    create(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateIssueDto) {
        return this.service.create(user.userId, dto);
    }

    @Get('mine')
    findMine(@CurrentUser() user: CurrentUserPayload) {
        return this.service.findMine(user.userId);
    }

    @Get(':id')
    findOne(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.service.findOne(user.userId, id, user.role);
    }

    @Patch(':id/status')
    @Roles(Role.ADMIN)
    updateStatus(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
        @Body() dto: UpdateStatusDto,
    ) {
        return this.service.updateStatus(user.userId, id, dto.status);
    }
}
