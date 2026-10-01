import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DistrictsService {
    constructor(private prisma: PrismaService) {}

    async findOne(id: string) {
        const district = await this.prisma.district.findUnique({
            where: { id },
            include: { state: { select: { id: true, name: true } } },
        });
        if (!district) throw new NotFoundException('District not found');
        return district;
    }
}
