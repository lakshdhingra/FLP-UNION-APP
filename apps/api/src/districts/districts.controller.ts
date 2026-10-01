import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { DistrictsService } from './districts.service';
import { Public } from '../auth/decorators/public.decorator';

@Public()
@Controller('districts')
export class DistrictsController {
    constructor(private readonly service: DistrictsService) {}

    @Get(':id')
    findOne(@Param('id', ParseUUIDPipe) id: string) {
        return this.service.findOne(id);
    }
}
