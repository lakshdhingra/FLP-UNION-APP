import {
    Controller, Get, Patch, Body, Param, UseGuards,
    ParseUUIDPipe, Query,
} from '@nestjs/common';
import { ManagersService } from './managers.service';
import { UpdateManagerDto } from './dto/update-manager.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';
import { Role } from '@prisma/client';

import { ApiTags } from '@nestjs/swagger';

@ApiTags('Managers')
@Controller('manager')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MANAGER)
export class ManagersController {
    constructor(private readonly managersService: ManagersService) {}

    /** GET /api/manager/profile */
    @Get('profile')
    getProfile(@CurrentUser() user: CurrentUserPayload) {
        return this.managersService.getProfile(user.userId);
    }

    /** PATCH /api/manager/profile */
    @Patch('profile')
    updateProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: UpdateManagerDto,
    ) {
        return this.managersService.updateProfile(user.userId, dto);
    }

    /** GET /api/manager/dashboard */
    @Get('dashboard')
    getDashboard(@CurrentUser() user: CurrentUserPayload) {
        return this.managersService.getDashboard(user.userId);
    }

    /** GET /api/manager/managers - same-state manager directory */
    @Get('managers')
    findManagers(
        @CurrentUser() user: CurrentUserPayload,
        @Query('search') search?: string,
        @Query('districtId') districtId?: string,
        @Query('page') page?: string,
        @Query('limit') limit?: string,
    ) {
        return this.managersService.findSameStateManagers(user.userId, {
            search,
            districtId,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        });
    }

    /** GET /api/manager/managers/:id - another manager's profile */
    @Get('managers/:id')
    findManager(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.managersService.findManagerById(user.userId, id);
    }

    /** GET /api/manager/managers/:id/engineers - read-only, masked */
    @Get('managers/:id/engineers')
    findManagerEngineers(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.managersService.findManagerEngineers(user.userId, id);
    }
}
