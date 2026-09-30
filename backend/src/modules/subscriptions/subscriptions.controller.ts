import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private subscriptionsService: SubscriptionsService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get all subscription plans' })
  async findAll() {
    return this.subscriptionsService.findAll();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all plans incl. inactive (admin)' })
  async findAllAdmin() {
    return this.subscriptionsService.findAllAdmin();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Post('admin')
  @ApiOperation({ summary: 'Create plan (admin)' })
  async createPlan(@Body() dto: any) {
    return this.subscriptionsService.createPlan(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Patch('admin/:id')
  @ApiOperation({ summary: 'Update plan (admin)' })
  async updatePlan(@Param('id') id: string, @Body() dto: any) {
    return this.subscriptionsService.updatePlan(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete('admin/:id')
  @ApiOperation({ summary: 'Delete plan (admin)' })
  async removePlan(@Param('id') id: string) {
    return this.subscriptionsService.removePlan(id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get('my')
  @ApiOperation({ summary: 'Get my subscriptions' })
  async getMy(@Request() req) {
    return this.subscriptionsService.getMy(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('subscribe')
  @ApiOperation({ summary: 'Subscribe to a plan' })
  async subscribe(@Request() req, @Body('subscriptionId') subscriptionId: string) {
    return this.subscriptionsService.subscribe(req.user.id, subscriptionId);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Patch(':id/pause')
  @ApiOperation({ summary: 'Pause subscription' })
  async pause(@Param('id') id: string, @Request() req) {
    return this.subscriptionsService.pause(id, req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Patch(':id/resume')
  @ApiOperation({ summary: 'Resume subscription' })
  async resume(@Param('id') id: string, @Request() req) {
    return this.subscriptionsService.resume(id, req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post(':id/skip')
  @ApiOperation({ summary: 'Skip subscription day' })
  async skipDay(@Param('id') id: string, @Request() req, @Body('date') date: string) {
    return this.subscriptionsService.skipDay(id, req.user.id, date);
  }
}
