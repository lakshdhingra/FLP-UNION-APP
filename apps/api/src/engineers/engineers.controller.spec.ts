import { Test, TestingModule } from '@nestjs/testing';
import { EngineersController } from './engineers.controller';
import { EngineersService } from './engineers.service';

describe('EngineersController', () => {
  let controller: EngineersController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [EngineersController],
      providers: [
        {
          provide: EngineersService,
          useValue: {
            create: jest.fn(),
            update: jest.fn(),
            findOne: jest.fn(),
            findMine: jest.fn(),
            remove: jest.fn(),
            getDocumentUrl: jest.fn(),
            getUploadUrl: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<EngineersController>(EngineersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
