import {
    Controller, Get, Post, Patch, Delete, Body, Param,
    Query, UseGuards, ParseUUIDPipe, ParseEnumPipe, Request,
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role, IssueStatus } from '@prisma/client';
import {
    CreateStateDto, UpdateStateDto,
    CreateDistrictDto, UpdateDistrictDto,
    AdminUpdateEngineerDto,
} from './dto/admin.dto';

import { ApiTags } from '@nestjs/swagger';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
export class AdminController {
    constructor(private readonly service: AdminService) {}

    // ─── States ────────────────────────────────────────────────
    @Get('states')
    findStates(@Query('includeInactive') includeInactive?: string) {
        return this.service.findAllStates(includeInactive === 'true');
    }

    @Post('states')
    createState(@Request() req: any, @Body() dto: CreateStateDto) {
        return this.service.createState(req.user.userId, dto);
    }

    @Patch('states/:id')
    updateState(@Request() req: any, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateStateDto) {
        return this.service.updateState(req.user.userId, id, dto);
    }

    // ─── Districts ────────────────────────────────────────────
    @Get('districts')
    findDistricts(@Query('stateId') stateId?: string) {
        return this.service.findAllDistricts(stateId);
    }

    @Post('districts')
    createDistrict(@Request() req: any, @Body() dto: CreateDistrictDto) {
        return this.service.createDistrict(req.user.userId, dto);
    }

    @Patch('districts/:id')
    updateDistrict(@Request() req: any, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateDistrictDto) {
        return this.service.updateDistrict(req.user.userId, id, dto);
    }

    // ─── Managers ──────────────────────────────────────────────
    @Get('managers')
    findManagers(
        @Query('stateId') stateId?: string,
        @Query('search') search?: string,
        @Query('page') page?: string,
        @Query('limit') limit?: string,
    ) {
        return this.service.findAllManagers({
            stateId,
            search,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        });
    }

    @Get('managers/:id')
    findManager(@Param('id', ParseUUIDPipe) id: string) {
        return this.service.findManagerById(id);
    }

    // ─── Engineers ────────────────────────────────────────────
    @Get('engineers')
    findEngineers(
        @Query('stateId') stateId?: string,
        @Query('managerId') managerId?: string,
        @Query('search') search?: string,
        @Query('page') page?: string,
        @Query('limit') limit?: string,
    ) {
        return this.service.findAllEngineers({
            stateId,
            managerId,
            search,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        });
    }

    @Get('engineers/:id')
    findEngineer(@Param('id', ParseUUIDPipe) id: string) {
        return this.service.findEngineerById(id);
    }

    @Patch('engineers/:id')
    updateEngineer(@Request() req: any, @Param('id', ParseUUIDPipe) id: string, @Body() body: AdminUpdateEngineerDto) {
        return this.service.updateEngineer(req.user.userId, id, body);
    }

    @Delete('engineers/:id')
    deleteEngineer(@Request() req: any, @Param('id', ParseUUIDPipe) id: string) {
        return this.service.deleteEngineer(req.user.userId, id);
    }

    // ─── Issues ───────────────────────────────────────────────
    @Get('issues')
    findIssues(
        @Query('status', new ParseEnumPipe(IssueStatus, { optional: true })) status?: IssueStatus,
        @Query('page') page?: string,
        @Query('limit') limit?: string,
    ) {
        return this.service.findAllIssues({
            status,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        });
    }

    // ─── Audit Logs ───────────────────────────────────────────
    @Get('audit-logs')
    findAuditLogs(
        @Query('page') page?: string,
        @Query('limit') limit?: string,
    ) {
        return this.service.findAuditLogs({
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 50,
        });
    }
}
