import { Test, TestingModule } from '@nestjs/testing';
import { StatesService } from './states.service';
import { PrismaService } from './prisma/prisma.service';

describe('StatesService', () => {
  let service: StatesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StatesService,
        {
          provide: PrismaService,
          useValue: {
            state: {
              findMany: jest.fn(),
            },
            district: {
              findMany: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<StatesService>(StatesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
