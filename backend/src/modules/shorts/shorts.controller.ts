import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ShortsService } from './shorts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Shorts')
@Controller('shorts')
export class ShortsController {
  constructor(private shortsService: ShortsService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get food shorts feed' })
  async findAll(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('categoryId') categoryId?: string,
  ) {
    return this.shortsService.findAll({
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
      categoryId,
    });
  }

  @Public()
  @Post(':id/view')
  @ApiOperation({ summary: 'Increment view count' })
  async view(@Param('id') id: string) {
    return this.shortsService.incrementViews(id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post(':id/like')
  @ApiOperation({ summary: 'Toggle like on short' })
  async like(@Param('id') id: string, @Request() req) {
    return this.shortsService.toggleLike(req.user.id, id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all shorts incl. inactive (admin)' })
  async findAllAdmin() {
    return this.shortsService.findAllAdmin();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Post('admin')
  @ApiOperation({ summary: 'Create short (admin)' })
  async create(@Body() dto: any) {
    return this.shortsService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Patch('admin/:id')
  @ApiOperation({ summary: 'Update short (admin)' })
  async update(@Param('id') id: string, @Body() dto: any) {
    return this.shortsService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete('admin/:id')
  @ApiOperation({ summary: 'Delete short (admin)' })
  async remove(@Param('id') id: string) {
    return this.shortsService.remove(id);
  }
}
