import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class ChefsService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async findByPin(pin: string) {
    return this.prisma.user.findFirst({ where: { role: 'chef', phoneNumber: pin } });
  }

  async getDashboard(chefId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [totalOrders, preparingOrders, readyOrders] = await Promise.all([
      this.prisma.order.count({
        where: { chefId, createdAt: { gte: today } },
      }),
      this.prisma.order.count({
        where: { chefId, status: 'preparing' },
      }),
      this.prisma.order.count({
        where: { chefId, status: 'ready' },
      }),
    ]);

    return { totalOrders, preparingOrders, readyOrders };
  }

  async getOrders(chefId: string, status?: string) {
    const where: any = {};
    if (status) where.status = status;

    return this.prisma.order.findMany({
      where,
      include: {
        items: {
          include: {
            foodItem: { select: { id: true, name: true, imageUrls: true } },
          },
        },
        user: { select: { id: true, fullName: true, phoneNumber: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async acceptOrder(orderId: string, chefId: string) {
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'confirmed', chefId },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'confirmed');
    return updated;
  }

  async startPreparing(orderId: string) {
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'preparing' },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'preparing');
    return updated;
  }

  async markReady(orderId: string) {
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'ready' },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'ready');
    return updated;
  }

  async toggleFoodStock(foodItemId: string) {
    const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId } });
    if (!food) throw new Error('Food item not found');
    return this.prisma.foodItem.update({
      where: { id: foodItemId },
      data: { isActive: !food.isActive },
    });
  }
}
