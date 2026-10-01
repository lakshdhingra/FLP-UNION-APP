import { Controller, Get, Param } from '@nestjs/common';
import { StatesService } from './states.service';

@Controller('states')
export class StatesController {
    constructor(private statesService: StatesService) { }

    @Get()
    findAll() {
        return this.statesService.findAll();
    }

    @Get(':id/districts')
    findDistricts(@Param('id') id: string) {
        return this.statesService.findDistricts(id);
    }
}