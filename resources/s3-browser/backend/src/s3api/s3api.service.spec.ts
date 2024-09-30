import { Test, TestingModule } from '@nestjs/testing';
import { S3apiService } from './s3api.service';

describe('S3apiService', () => {
  let service: S3apiService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [S3apiService],
    }).compile();

    service = module.get<S3apiService>(S3apiService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
