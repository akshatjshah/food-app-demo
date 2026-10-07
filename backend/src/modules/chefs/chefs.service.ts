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
      // "Ready" tray now means ready-to-deliver: legacy 'ready' orders
      // plus the normal 'out_for_delivery' state (no Ready-for-Pickup step).
      this.prisma.order.count({
        where: { chefId, status: { in: ['ready', 'out_for_delivery'] } },
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

  /**
   * Legacy endpoint name kept (POST /chefs/orders/:id/ready) so existing
   * chef clients keep working, but the Parabdi workflow has no pickup
   * step: preparing now advances directly to OUT FOR DELIVERY.
   */
  async markReady(orderId: string, chefId?: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (chefId && order.chefId && order.chefId !== chefId) {
      throw new ForbiddenException('Order assigned to another chef');
    }
    // Allow legacy 'ready' orders to be re-marked (idempotent drain).
    if (order.status !== 'preparing' && order.status !== 'ready') {
      throw new BadRequestException(`Cannot mark ready from status ${order.status}`);
    }
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'out_for_delivery' },
    });
    await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'out_for_delivery');
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
