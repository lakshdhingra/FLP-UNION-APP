import { Injectable, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { S3Service } from '../s3/s3.service';
import { CreateApplicationDto, GetUploadUrlDto } from './membership.dto';

@Injectable()
export class MembershipService {
  constructor(
    private prisma: PrismaService,
    private s3Service: S3Service,
  ) {}

  async getUploadUrl(dto: GetUploadUrlDto) {
    const tempId = dto.tempId || crypto.randomUUID();
    const folderPath = `website/membership-applications/temp-${tempId}`;
    const result = await this.s3Service.getPresignedUploadUrl(folderPath, dto.fileName, dto.mimeType);
    return {
      ...result,
      tempId,
    };
  }

  async submitApplication(dto: CreateApplicationDto) {
    // Check existing pending application
    const existing = await this.prisma.membershipApplication.findFirst({
      where: {
        OR: [{ email: dto.email }, { phone: dto.phone }],
        status: { not: 'REJECTED' },
      },
    });

    if (existing) {
      if (existing.email === dto.email) {
        throw new ConflictException('An application with this email address already exists.');
      }
      throw new ConflictException('An application with this phone number already exists.');
    }

    // Get prefix settings
    const settings = await this.prisma.siteSettings.findUnique({ where: { id: 1 } });
    const prefix = settings?.appIdPrefix || 'TASPU-APP';

    // Count applications for sequential number
    const count = await this.prisma.membershipApplication.count();
    const appNumber = `${prefix}-${String(count + 1).padStart(5, '0')}`;

    const app = await this.prisma.membershipApplication.create({
      data: {
        applicationNumber: appNumber,
        fullName: dto.fullName,
        email: dto.email,
        phone: dto.phone,
        serviceCenterName: dto.serviceCenterName,
        designation: dto.designation,
        yearsExperience: dto.yearsExperience,
        brandsWorkedWith: dto.brandsWorkedWith,
        gstNo: dto.gstNo,
        district: dto.district,
        city: dto.city,
        address: dto.address,
        fullAddress: dto.fullAddress,
        reasonForJoining: dto.reasonForJoining || null,
        additionalInfo: dto.additionalInfo || null,
        documents: (dto.documents || []) as any,
        status: 'PENDING',
      },
    });

    return {
      success: true,
      applicationNumber: app.applicationNumber,
      id: app.id,
    };
  }

  async getPublicMembers() {
    return this.prisma.member.findMany({
      where: { status: 'ACTIVE', publicVisibility: true },
      select: {
        id: true,
        fullName: true,
        serviceCenterName: true,
        fullAddress: true,
        district: true,
        city: true,
        brandsWorkedWith: true,
        gstNo: true,
      },
      orderBy: { serviceCenterName: 'asc' },
    });
  }
}
