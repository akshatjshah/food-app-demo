import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { OrderStatus } from '@prisma/client';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class OrdersService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async create(userId: string, dto: {
    addressId: string;
    deliverySlot: string;
    specialInstructions?: string;
    couponCode?: string;
    paymentMethod?: string;
  }) {
    const address = await this.prisma.address.findFirst({
      where: { id: dto.addressId, userId },
    });
    if (!address) {
      throw new BadRequestException('Invalid delivery address');
    }

    const cart = await this.prisma.cart.findUnique({
      where: { userId },
      include: { items: { include: { foodItem: true } } },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    const errors: string[] = [];
    let itemTotal = 0;
    const orderItems: any[] = [];

    for (const ci of cart.items) {
      if (!ci.foodItem.isActive) {
        errors.push(`${ci.foodItem.name} is no longer available`);
        continue;
      }
      if (ci.foodItem.deletedAt) {
        errors.push(`${ci.foodItem.name} has been removed`);
        continue;
      }
      const basePrice = Number(ci.foodItem.price);
      const customizationItems = Array.isArray(ci.customizationItems)
        ? (ci.customizationItems as any[])
        : [];
      const customizationTotal = customizationItems.reduce(
        (s: number, c: any) => s + Number(c.additional_price || 0),
        0,
      );
      const unitPrice = basePrice + customizationTotal;
      itemTotal += unitPrice * ci.quantity;
      orderItems.push({
        foodItemId: ci.foodItemId,
        quantity: ci.quantity,
        unitPrice,
        customizations: customizationItems.map((c: any) => ({
          customizationItemId: c.customization_item_id || c.id,
          name: c.name || '',
          additionalPrice: Number(c.additional_price || 0),
        })),
      });
    }

    if (errors.length > 0) {
      throw new BadRequestException({
        message: 'Some items are no longer available',
        errors,
      });
    }

    if (itemTotal < 1) {
      throw new BadRequestException(
        `Minimum order value is ₹1. Current total: ₹${itemTotal}`,
      );
    }

    const taxAmount = itemTotal * 0.05;
    const platformFee = 2;
    const deliveryFee = itemTotal >= 200 ? 0 : 30;
    let discountAmount = 0;

    if (dto.couponCode) {
      const coupon = await this.prisma.coupon.findUnique({
        where: { code: dto.couponCode },
      });
      if (coupon && coupon.isActive && new Date() < coupon.expiresAt) {
        if (coupon.discountType === 'percentage') {
          discountAmount = Math.min(
            itemTotal * (Number(coupon.discountValue) / 100),
            coupon.maxDiscountValue ? Number(coupon.maxDiscountValue) : Infinity,
          );
        } else {
          discountAmount = Number(coupon.discountValue);
        }
      }
    }

    const grandTotal = itemTotal + taxAmount + platformFee + deliveryFee - discountAmount;
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    const paymentMethod = (dto.paymentMethod || 'upi') as any;

    const order = await this.prisma.$transaction(async (tx) => {
      const newOrder = await tx.order.create({
        data: {
          userId,
          addressId: dto.addressId,
          status: 'placed',
          paymentMethod,
          paymentStatus: paymentMethod === 'cod' ? 'pending' : 'pending',
          itemTotal,
          taxAmount,
          platformFee,
          deliveryFee,
          discountAmount,
          grandTotal,
          specialInstructions: dto.specialInstructions,
          deliverySlot: dto.deliverySlot,
          otpCode,
          items: {
            create: orderItems.map((oi) => ({
              foodItemId: oi.foodItemId,
              quantity: oi.quantity,
              unitPrice: oi.unitPrice,
              customizations: {
                create: (oi.customizations || []).map((c: any) => ({
                  customizationItemId: c.customizationItemId,
                  name: c.name,
                  additionalPrice: c.additionalPrice,
                })),
              },
            })),
          },
        },
        include: { items: true },
      });

      if (dto.couponCode) {
        const coupon = await tx.coupon.findUnique({ where: { code: dto.couponCode } });
        if (coupon) {
          await tx.couponUsage.create({
            data: {
              couponId: coupon.id,
              userId,
              orderId: newOrder.id,
            },
          });
        }
      }

      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });

      return newOrder;
    });

    // In-app notification for order placed (best-effort, never breaks checkout).
    await this.notificationsService.sendOrderStatusUpdate(userId, order.id, 'placed');

    return {
      id: order.id,
      status: order.status,
      itemTotal: Number(order.itemTotal),
      taxAmount: Number(order.taxAmount),
      platformFee: Number(order.platformFee),
      deliveryFee: Number(order.deliveryFee),
      discountAmount: Number(order.discountAmount),
      grandTotal: Number(order.grandTotal),
      otpCode: order.otpCode,
      createdAt: order.createdAt,
    };
  }

  private toPlainOrder(o: any) {
    return {
      ...o,
      itemTotal: Number(o.itemTotal),
      grandTotal: Number(o.grandTotal),
      deliveryFee: Number(o.deliveryFee),
      platformFee: Number(o.platformFee),
      taxAmount: Number(o.taxAmount),
      discountAmount: Number(o.discountAmount),
      items: (o.items || []).map((item: any) => ({
        ...item,
        unitPrice: Number(item.unitPrice),
        total: Number(item.unitPrice) * item.quantity,
        customizations: (item.customizations || []).map((c: any) => ({
          ...c,
          additionalPrice: Number(c.additionalPrice),
        })),
      })),
    };
  }

  async findAll(userId: string, params: { skip?: number; take?: number; status?: string }) {
    const where: any = { userId };
    if (params.status) where.status = params.status;

    const orders = await this.prisma.order.findMany({
      where,
      include: {
        items: {
          include: {
            foodItem: { select: { id: true, name: true, imageUrls: true, isVeg: true } },
            customizations: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: params.skip || 0,
      take: params.take || 20,
    });

    return orders.map((o) => this.toPlainOrder(o));
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        items: {
          include: {
            foodItem: { select: { id: true, name: true, imageUrls: true, isVeg: true } },
            customizations: true,
          },
        },
        address: true,
        statusHistory: { orderBy: { createdAt: 'desc' } },
      },
    });
    if (!order) throw new NotFoundException('Order not found');
    const plain = this.toPlainOrder(order);
    if (order.address) {
      plain.deliveryAddress = {
        ...order.address,
        latitude: Number(order.address.latitude),
        longitude: Number(order.address.longitude),
      };
    }
    return plain;
  }

  async cancel(id: string, userId: string) {
    const order = await this.prisma.order.findUnique({ where: { id } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.userId !== userId) throw new BadRequestException('Not authorized');
    if (!['placed', 'confirmed'].includes(order.status)) {
      throw new BadRequestException('Order cannot be cancelled');
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const next = await tx.order.update({
        where: { id },
        data: { status: 'cancelled' },
      });
      await tx.orderStatusHistory.create({
        data: { orderId: id, fromStatus: order.status, toStatus: 'cancelled', triggeredBy: userId },
      });
      return next;
    });

    await this.notificationsService.sendOrderStatusUpdate(userId, id, 'cancelled');

    return updated;
  }

  async reorder(userId: string, orderId: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true },
    });
    if (!order) throw new NotFoundException('Order not found');

    let cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) cart = await this.prisma.cart.create({ data: { userId } });

    await this.prisma.cartItem.deleteMany({ where: { cartId: cart.id } });

    for (const item of order.items) {
      const foodItem = await this.prisma.foodItem.findUnique({
        where: { id: item.foodItemId },
      });
      if (foodItem && foodItem.isActive && !foodItem.deletedAt) {
        await this.prisma.cartItem.create({
          data: {
            cartId: cart.id,
            foodItemId: item.foodItemId,
            quantity: item.quantity,
            customizationItems: [],
          },
        });
      }
    }

    return { message: 'Available items added to cart' };
  }
}
