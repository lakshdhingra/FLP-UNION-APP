import { Controller, Post, Get, Body } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { MembershipService } from './membership.service';
import { CreateApplicationDto } from './membership.dto';

@ApiTags('Membership')
@Public()
@Controller('membership')
export class MembershipController {
  constructor(private readonly service: MembershipService) {}

  @Post('apply')
  submitApplication(@Body() dto: CreateApplicationDto) {
    return this.service.submitApplication(dto);
  }

  @Get('public-members')
  getPublicMembers() {
    return this.service.getPublicMembers();
  }
}
