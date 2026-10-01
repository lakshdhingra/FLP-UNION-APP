import { Test, TestingModule } from '@nestjs/testing';
import { EngineersController } from './engineers.controller';

describe('EngineersController', () => {
  let controller: EngineersController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [EngineersController],
    }).compile();

    controller = module.get<EngineersController>(EngineersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
