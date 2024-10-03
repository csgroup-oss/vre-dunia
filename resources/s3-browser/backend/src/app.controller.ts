import { Controller, Delete, Get, Query, StreamableFile, Res, UseInterceptors, Post, UploadedFile, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { basename } from 'path';

import { S3apiService } from './s3api/s3api.service';

@Controller('s3')
export class AppController {
  constructor(private readonly s3: S3apiService) {}

  @Get('list')
  list(@Query('path') path = ''): Promise<any> {
    return this.s3.list(path);
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  upload(
    @Query('path') path = '/',
    @UploadedFile() file: Express.Multer.File
): Promise<any> {
    console.log('FILE', file)
    return this.s3.upload(path, file.stream);
  }

  @Post('folder')
  createFolder(@Query('path') path = '/'): Promise<any>  {
    return this.s3.createFolder(path);
  }

  @Get('download')
  async download(
    @Query('path') path: string,
    @Res({ passthrough: true }) res: Response
): Promise<StreamableFile> {
    const file = await this.s3.download(path);
    res.set({
        'Content-type': 'application/octet-stream',
        'Content-Disposition': `attachment; filename="${basename(path)}"`,
    });
    return new StreamableFile(file);
  }

  @Delete('delete')
  delete(@Query('path') path: string): Promise<any> {
    return this.s3.delete(path);
  }
}
