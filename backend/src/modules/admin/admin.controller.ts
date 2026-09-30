import { Controller, Get, Post, Patch, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.admin)
@ApiBearerAuth()
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get admin dashboard stats' })
  async getDashboard() {
    return this.adminService.getDashboard();
  }

  @Get('dashboard/revenue')
  @ApiOperation({ summary: 'Get revenue chart data' })
  async getRevenue(@Query('days') days?: string) {
    return this.adminService.getRevenueChart(days ? parseInt(days) : 7);
  }

  @Get('dashboard/orders-by-status')
  @ApiOperation({ summary: 'Get orders count by status' })
  async getOrdersByStatus() {
    return this.adminService.getOrdersByStatus();
  }

  @Get('dashboard/top-dishes')
  @ApiOperation({ summary: 'Get top selling dishes' })
  async getTopDishes(@Query('limit') limit?: string) {
    return this.adminService.getTopDishes(limit ? parseInt(limit) : 10);
  }

  @Get('dashboard/recent-orders')
  @ApiOperation({ summary: 'Get recent orders' })
  async getRecentOrders(@Query('limit') limit?: string) {
    return this.adminService.getRecentOrders(limit ? parseInt(limit) : 5);
  }

  @Get('orders')
  @ApiOperation({ summary: 'Get all orders (admin)' })
  async getOrders(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('status') status?: string,
    @Query('paymentStatus') paymentStatus?: string,
    @Query('search') search?: string,
  ) {
    return this.adminService.getOrders({
      skip: skip ? parseInt(skip) : 0,
      take: Math.min(take ? parseInt(take) : 20, 100),
      status,
      paymentStatus,
      search,
    });
  }

  @Get('orders/:orderId')
  @ApiOperation({ summary: 'Get order detail (admin)' })
  async getOrderDetail(@Param('orderId') orderId: string) {
    return this.adminService.getOrderDetail(orderId);
  }

  @Patch('orders/:orderId/status')
  @ApiOperation({ summary: 'Update order status (admin)' })
  async updateOrderStatus(
    @Param('orderId') orderId: string,
    @Body('status') status: string,
    @Request() req,
  ) {
    return this.adminService.updateOrderStatus(orderId, status, req.user?.id);
  }

  @Post('notifications/broadcast')
  @ApiOperation({ summary: 'Broadcast an announcement/offer to customers (admin)' })
  async broadcast(
    @Body() body: { title: string; body: string; type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT'; userIds?: string[]; referenceId?: string },
  ) {
    return this.adminService.broadcastAnnouncement(
      body.title,
      body.body,
      body.type || 'ANNOUNCEMENT',
      body.userIds,
      body.referenceId,
    );
  }

  @Get('audit-logs')
  @ApiOperation({ summary: 'Get audit logs (admin)' })
  async getAuditLogs(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('entity') entity?: string,
    @Query('action') action?: string,
    @Query('search') search?: string,
  ) {
    return this.adminService.getAuditLogs({
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
      entity,
      action,
      search,
    });
  }

  @Get('customers')
  @ApiOperation({ summary: 'List customers (admin)' })
  async getCustomers(
    @Query('search') search?: string,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    return this.adminService.getCustomers({
      search,
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
    });
  }

  @Get('customers/:id')
  @ApiOperation({ summary: 'Get customer detail (admin)' })
  async getCustomerDetail(@Param('id') id: string) {
    return this.adminService.getCustomerDetail(id);
  }

  @Patch('customers/:id/block')
  @ApiOperation({ summary: 'Block/unblock customer (admin)' })
  async setCustomerBlocked(
    @Param('id') id: string,
    @Body('isBlocked') isBlocked: boolean,
    @Request() req,
  ) {
    return this.adminService.setCustomerBlocked(id, isBlocked === true, req.user?.id);
  }

  @Get('staff')
  @ApiOperation({ summary: 'List chefs/riders (admin)' })
  async getStaff(@Query('role') role?: string, @Query('search') search?: string) {
    const r = role === 'delivery' ? 'delivery' : 'chef';
    return this.adminService.getStaff(r, search);
  }

  @Post('staff')
  @ApiOperation({ summary: 'Create chef/rider (admin)' })
  async createStaff(
    @Body() body: { fullName: string; phoneNumber: string; email?: string; role: 'chef' | 'delivery' },
    @Request() req,
  ) {
    return this.adminService.createStaff(body, req.user?.id);
  }

  @Patch('staff/:id')
  @ApiOperation({ summary: 'Update chef/rider (admin)' })
  async updateStaff(
    @Param('id') id: string,
    @Body() body: { fullName?: string; email?: string; isBlocked?: boolean; role?: 'chef' | 'delivery' },
    @Request() req,
  ) {
    return this.adminService.updateStaff(id, body, req.user?.id);
  }

  @Get('wallet/transactions')
  @ApiOperation({ summary: 'List wallet transactions (admin)' })
  async getWalletTransactions(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('search') search?: string,
  ) {
    return this.adminService.getWalletTransactions({
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
      search,
    });
  }

  @Get('reports/summary')
  @ApiOperation({ summary: 'Get analytics summary (admin)' })
  async getReports(@Query('days') days?: string) {
    return this.adminService.getReports(days ? parseInt(days) : 30);
  }

  @Get('loyalty/transactions')
  @ApiOperation({ summary: 'List loyalty transactions (admin)' })
  async getLoyaltyTransactions(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('search') search?: string,
  ) {
    return this.adminService.getLoyaltyTransactions({
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
      search,
    });
  }

  @Get('notifications/recent')
  @ApiOperation({ summary: 'Recent notifications sent (admin)' })
  async getRecentNotifications(@Query('take') take?: string) {
    return this.adminService.getRecentNotifications(take ? parseInt(take) : 50);
  }
}
