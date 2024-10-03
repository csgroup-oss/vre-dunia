import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { S3apiService } from './s3api/s3api.service';
import { S3apiModule } from './s3api/s3api.module';

@Module({
  imports: [S3apiModule, ConfigModule.forRoot()],
  controllers: [AppController],
  providers: [AppService, S3apiService],
})
export class AppModule {}
