import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { StatesService } from './states.service';
import { Public } from '../auth/decorators/public.decorator';

import { ApiTags } from '@nestjs/swagger';

@ApiTags('States')
@Public()
@Controller('states')
export class StatesController {
    constructor(private statesService: StatesService) {}

    @Get()
    findAll() {
        return this.statesService.findAll();
    }

    @Get(':id/districts')
    findDistricts(@Param('id', ParseUUIDPipe) id: string) {
        return this.statesService.findDistricts(id);
    }
}
