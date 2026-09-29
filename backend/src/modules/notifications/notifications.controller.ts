import { Controller, Get, Patch, Delete, Post, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiProperty } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../../guards/roles.decorator';
import { UserRole } from '@prisma/client';

class SendTestDto {
  @ApiProperty({ example: 'user-id-here' })
  userId: string;

  @ApiProperty({ example: 'Test Notification' })
  title: string;

  @ApiProperty({ example: 'This is a test push notification' })
  body: string;
}

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get user notifications' })
  async findAll(
    @Request() req,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    return this.notificationsService.findAll(req.user.id, {
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 20,
    });
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Get unread notification count' })
  async getUnreadCount(@Request() req) {
    return this.notificationsService.getUnreadCount(req.user.id);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  async markRead(@Request() req, @Param('id') id: string) {
    return this.notificationsService.markRead(id, req.user.id);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllRead(@Request() req) {
    return this.notificationsService.markAllRead(req.user.id);
  }

  @Delete()
  @ApiOperation({ summary: 'Remove all notifications for the signed-in customer' })
  async removeAll(@Request() req) {
    return this.notificationsService.removeAll(req.user.id);
  }

  @Post('send-test')
  @UseGuards(RolesGuard)
  @Roles(UserRole.admin)
  @ApiOperation({ summary: 'Send a test FCM push notification (admin only)' })
  async sendTest(@Body() dto: SendTestDto) {
    const sent = await this.notificationsService.sendPushNotification(
      dto.userId,
      dto.title,
      dto.body,
    );
    return {
      success: sent,
      message: sent
        ? 'Test push notification sent successfully'
        : 'Failed to send push notification (user may not have FCM tokens or Firebase is not configured)',
    };
  }
}
