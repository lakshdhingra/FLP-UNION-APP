import { Controller, Post, Get, Body } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { MembershipService } from './membership.service';
import { CreateApplicationDto, GetUploadUrlDto } from './membership.dto';

@ApiTags('Membership')
@Public()
@Controller('membership')
export class MembershipController {
  constructor(private readonly service: MembershipService) {}

  @Post('upload-url')
  getUploadUrl(@Body() dto: GetUploadUrlDto) {
    return this.service.getUploadUrl(dto);
  }

  @Post('apply')
  submitApplication(@Body() dto: CreateApplicationDto) {
    return this.service.submitApplication(dto);
  }

  @Get('public-members')
  getPublicMembers() {
    return this.service.getPublicMembers();
  }
}
