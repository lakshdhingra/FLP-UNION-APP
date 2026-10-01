import { Test, TestingModule } from '@nestjs/testing';
import { EngineersService } from './engineers.service';

describe('EngineersService', () => {
  let service: EngineersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EngineersService],
    }).compile();

    service = module.get<EngineersService>(EngineersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
