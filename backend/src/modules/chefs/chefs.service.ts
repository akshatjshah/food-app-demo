import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
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
    const where: any = {
      OR: [
        { chefId },
        { chefId: null, status: { in: ['placed', 'confirmed'] } },
      ],
    };
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
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.chefId && order.chefId !== chefId) {
      throw new ForbiddenException('Order already assigned to another chef');
    }
    if (!['placed', 'confirmed'].includes(order.status)) {
      throw new BadRequestException(`Cannot accept order in status ${order.status}`);
    }
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'confirmed', chefId },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'confirmed');
    return updated;
  }

  async startPreparing(orderId: string, chefId?: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (chefId && order.chefId && order.chefId !== chefId) {
      throw new ForbiddenException('Order assigned to another chef');
    }
    if (!['confirmed', 'placed'].includes(order.status)) {
      throw new BadRequestException(`Cannot start preparing from status ${order.status}`);
    }
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'preparing', ...(chefId ? { chefId } : {}) },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'preparing');
    return updated;
  }

  async markReady(orderId: string, chefId?: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (chefId && order.chefId && order.chefId !== chefId) {
      throw new ForbiddenException('Order assigned to another chef');
    }
    if (order.status !== 'preparing') {
      throw new BadRequestException(`Cannot mark ready from status ${order.status}`);
    }
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
