import {
    Controller, Get, Post, Patch, Delete,
    Body, Param, UseGuards, ParseUUIDPipe, Query,
} from '@nestjs/common';
import { EngineersService } from './engineers.service';
import { CreateEngineerDto } from './dto/create-engineer.dto';
import { UpdateEngineerDto } from './dto/update-engineer.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';
import { Role } from '@prisma/client';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Engineers')
@Controller('manager/engineers')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MANAGER)
export class EngineersController {
    constructor(private readonly engineersService: EngineersService) {}

    /** GET /api/manager/engineers - list own engineers */
    @Get()
    findMine(
        @CurrentUser() user: CurrentUserPayload,
        @Query('search') search?: string,
        @Query('designation') designation?: string,
        @Query('page') page?: number,
        @Query('limit') limit?: number,
    ) {
        return this.engineersService.findMine(user.userId, { search, designation, page, limit });
    }

    /** POST /api/manager/engineers - create engineer */
    @Post()
    create(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: CreateEngineerDto,
    ) {
        return this.engineersService.create(user.userId, dto);
    }

    /** GET /api/manager/engineers/:id */
    @Get(':id')
    findOne(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.engineersService.findOne(user.userId, id);
    }

    /** PATCH /api/manager/engineers/:id */
    @Patch(':id')
    update(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
        @Body() dto: UpdateEngineerDto,
    ) {
        return this.engineersService.update(user.userId, id, dto);
    }

    /** DELETE /api/manager/engineers/:id */
    @Delete(':id')
    remove(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id', ParseUUIDPipe) id: string,
    ) {
        return this.engineersService.remove(user.userId, id);
    }
}
