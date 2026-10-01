import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatesService {
    constructor(private prisma: PrismaService) {}

    findAll() {
        return this.prisma.state.findMany({
            where: { isActive: true },
            orderBy: { name: 'asc' },
            select: { id: true, name: true },
        });
    }

    findDistricts(stateId: string) {
        return this.prisma.district.findMany({
            where: { stateId, isActive: true },
            orderBy: { name: 'asc' },
            select: { id: true, name: true, stateId: true },
        });
    }
}
