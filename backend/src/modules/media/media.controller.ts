import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Query,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { randomUUID } from 'crypto';
import { extname, join } from 'path';
import { unlinkSync, existsSync } from 'fs';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { MediaService, UPLOAD_DIR, ensureUploadDir, mediaFileFilter } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { UserRole } from '@prisma/client';

interface UploadedMorph {
  filename: string;
  mimetype: string;
  size: number;
}

@ApiTags('Media')
@Controller('media')
export class MediaController {
  constructor(private mediaService: MediaService) {}

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.chef)
  @ApiBearerAuth()
  @Post('upload')
  @ApiOperation({ summary: 'Upload image/video (admin/chef). kind=image|video' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({ schema: { type: 'object', properties: { file: { type: 'string', format: 'binary' } } } })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (req, file, cb) => {
          ensureUploadDir();
          cb(null, UPLOAD_DIR);
        },
        filename: (req, file, cb) => {
          cb(null, `${Date.now()}-${randomUUID()}${extname(file.originalname).toLowerCase()}`);
        },
      }),
      fileFilter: mediaFileFilter,
      limits: { fileSize: 50 * 1024 * 1024, files: 1 },
    }),
  )
  async upload(
    @UploadedFile() file: UploadedMorph | undefined,
    @Query('kind') kind?: string,
  ) {
    if (!file) throw new BadRequestException('No file uploaded');
    const max = kind === 'video' ? 50 * 1024 * 1024 : 5 * 1024 * 1024;
    if (file.size > max) {
      try {
        unlinkSync(join(UPLOAD_DIR, file.filename));
      } catch {
        /* ignore */
      }
      throw new BadRequestException(`File too large. Max ${max / 1024 / 1024}MB.`);
    }
    return {
      filename: file.filename,
      url: this.mediaService.toPublicUrl(file.filename),
      mimetype: file.mimetype,
      size: file.size,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get()
  @ApiOperation({ summary: 'List uploaded media (admin)' })
  async list() {
    return this.mediaService.list();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete(':filename')
  @ApiOperation({ summary: 'Delete uploaded media (admin)' })
  async remove(@Param('filename') filename: string) {
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      throw new BadRequestException('Invalid filename');
    }
    const path = join(UPLOAD_DIR, filename);
    if (!existsSync(path)) throw new BadRequestException('File not found');
    unlinkSync(path);
    return { message: 'Deleted' };
  }
}
