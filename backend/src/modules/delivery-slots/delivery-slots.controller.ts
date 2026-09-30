import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DeliverySlotsService } from './delivery-slots.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { Public } from '../../guards/public.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Delivery Slots')
@Controller('delivery-slots')
export class DeliverySlotsController {
  constructor(private deliverySlotsService: DeliverySlotsService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get active delivery slots' })
  async findActive() {
    return this.deliverySlotsService.findActive();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all slots incl. inactive (admin)' })
  async findAllAdmin() {
    return this.deliverySlotsService.findAllAdmin();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Create delivery slot (admin)' })
  async create(@Body() dto: any) {
    return this.deliverySlotsService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Patch(':id')
  @ApiOperation({ summary: 'Update delivery slot (admin)' })
  async update(@Param('id') id: string, @Body() dto: any) {
    return this.deliverySlotsService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @ApiBearerAuth()
  @Delete(':id')
  @ApiOperation({ summary: 'Delete delivery slot (admin)' })
  async remove(@Param('id') id: string) {
    return this.deliverySlotsService.remove(id);
  }
}
