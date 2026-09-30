import { Controller, Get, Post, Patch, Param, Query, UseGuards, Request, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ChefsService } from './chefs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Chefs')
@Controller('chefs')
export class ChefsController {
  constructor(private chefsService: ChefsService) {}

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Get('dashboard')
  @ApiOperation({ summary: 'Get chef dashboard stats' })
  async getDashboard(@Request() req) {
    return this.chefsService.getDashboard(req.user.id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Get('orders')
  @ApiOperation({ summary: 'Get chef orders' })
  async getOrders(@Request() req, @Query('status') status?: string) {
    return this.chefsService.getOrders(req.user.id, status);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Post('orders/:orderId/accept')
  @ApiOperation({ summary: 'Accept order' })
  async acceptOrder(@Param('orderId') orderId: string, @Request() req) {
    return this.chefsService.acceptOrder(orderId, req.user.id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Post('orders/:orderId/start')
  @ApiOperation({ summary: 'Start preparing order' })
  async startPreparing(@Param('orderId') orderId: string, @Request() req) {
    return this.chefsService.startPreparing(orderId, req.user.id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Post('orders/:orderId/ready')
  @ApiOperation({ summary: 'Mark order as ready' })
  async markReady(@Param('orderId') orderId: string, @Request() req) {
    return this.chefsService.markReady(orderId, req.user.id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.chef)
  @ApiBearerAuth()
  @Patch('foods/:foodItemId/stock')
  @ApiOperation({ summary: 'Toggle food stock' })
  async toggleStock(@Param('foodItemId') foodItemId: string) {
    return this.chefsService.toggleFoodStock(foodItemId);
  }
}
