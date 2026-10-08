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
      if (!ci.foodItem.isActive || (ci.foodItem as any).isAvailable === false) {
        errors.push(`${ci.foodItem.name} is no longer available`);
        continue;
      }
      if (ci.foodItem.deletedAt) {
        errors.push(`${ci.foodItem.name} has been removed`);
        continue;
      }
      const basePrice = Number(ci.foodItem.price);
      // Server-authoritative customization revalidation at checkout:
      // never trust the client/cart snapshot — reload groups + DB prices.
      const rawCustom = Array.isArray(ci.customizationItems)
        ? (ci.customizationItems as any[])
        : [];
      const groups = await this.prisma.customizationGroup.findMany({
        where: { foodItemId: ci.foodItemId, isActive: true },
        include: { items: true },
      });
      const itemById = new Map<string, { item: any; group: any }>();
      for (const g of groups) for (const it of g.items) itemById.set(it.id, { item: it, group: g });
      const seenByGroup = new Map<string, number>();
      let customizationTotal = 0;
      const snapshotCustom: any[] = [];
      let invalid = false;
      for (const c of rawCustom) {
        const id = c.customization_item_id || c.id;
        const found = itemById.get(id);
        if (!found || !found.item.isActive || !found.group.isActive) {
          errors.push(`${ci.foodItem.name}: a selected option is no longer available — please reconfigure in cart`);
          invalid = true;
          break;
        }
        seenByGroup.set(found.group.id, (seenByGroup.get(found.group.id) ?? 0) + 1);
        const price = Number(found.item.additionalPrice);
        customizationTotal += price;
        snapshotCustom.push({
          customizationItemId: found.item.id,
          name: found.item.name,
          additionalPrice: price,
          groupName: found.group.name,
        });
      }
      if (invalid) continue;
      for (const g of groups) {
        const count = seenByGroup.get(g.id) ?? 0;
        if (count < g.minSelections || count > g.maxSelections) {
          errors.push(
            `${ci.foodItem.name}: "${g.name}" needs ${g.minSelections}–${g.maxSelections} selection(s) — please reconfigure in cart`,
          );
          invalid = true;
          break;
        }
      }
      if (invalid) continue;
      const unitPrice = basePrice + customizationTotal;
      itemTotal += unitPrice * ci.quantity;
      orderItems.push({
        foodItemId: ci.foodItemId,
        quantity: ci.quantity,
        unitPrice,
        foodName: ci.foodItem.name,
        basePrice,
        customizations: snapshotCustom,
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
              foodName: oi.foodName,
              basePrice: oi.basePrice,
              customizations: {
                create: (oi.customizations || []).map((c: any) => ({
                  customizationItemId: c.customizationItemId,
                  name: c.name,
                  additionalPrice: c.additionalPrice,
                  groupName: c.groupName,
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

    // Live Admin Orders list: broadcast the new order (best-effort).
    try {
      this.notificationsService.emitNewOrderToAdmins({
        id: order.id,
        userId,
        status: order.status,
        grandTotal: Number(order.grandTotal),
        createdAt: order.createdAt,
      });
    } catch {
      // best-effort only
    }

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

  async findOne(id: string, requesterId?: string, isAdmin = false) {
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
    // Ownership enforcement: customers may only view their own orders.
    // Chefs/riders may view orders assigned to them; admins bypass.
    if (!isAdmin && requesterId) {
      const allowed =
        order.userId === requesterId ||
        (order as any).chefId === requesterId ||
        (order as any).deliveryBoyId === requesterId;
      if (!allowed) throw new BadRequestException('Not authorized');
    }
    const plain = this.toPlainOrder(order);
    if (order.address) {
      plain.deliveryAddress = {
        ...order.address,
        latitude: Number(order.address.latitude),
        longitude: Number(order.address.longitude),
      };
    }
    // Never expose delivery OTP in read responses; it is returned once at creation
    // and available to privileged admin/chef flows only.
    delete (plain as any).otpCode;
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
      include: { items: { include: { customizations: true } } },
    });
    if (!order) throw new NotFoundException('Order not found');
    if (order.userId !== userId) throw new BadRequestException('Not authorized');

    let cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) cart = await this.prisma.cart.create({ data: { userId } });

    await this.prisma.cartItem.deleteMany({ where: { cartId: cart.id } });

    for (const item of order.items) {
      const foodItem = await this.prisma.foodItem.findUnique({
        where: { id: item.foodItemId },
        include: { customizationGroups: { where: { isActive: true }, include: { items: true } } },
      });
      if (foodItem && foodItem.isActive && (foodItem as any).isAvailable !== false && !foodItem.deletedAt) {
        // Preserve the historical customization snapshot, but only for
        // options that still exist and are active today.
        const validIds = new Set(
          foodItem.customizationGroups.flatMap((g) => g.items.filter((i) => i.isActive).map((i) => i.id)),
        );
        const groupByItem = new Map<string, { item: any; group: any }>();
        for (const g of foodItem.customizationGroups) {
          for (const it of g.items) groupByItem.set(it.id, { item: it, group: g });
        }
        const kept: any[] = [];
        for (const c of (item as any).customizations || []) {
          const found = groupByItem.get(c.customizationItemId);
          if (found && found.item.isActive) {
            kept.push({
              customization_group_id: found.group.id,
              customization_item_id: found.item.id,
              id: found.item.id,
              name: found.item.name,
              additional_price: Number(found.item.additionalPrice),
              group: found.group.name,
            });
          }
        }
        void validIds;
        await this.prisma.cartItem.create({
          data: {
            cartId: cart.id,
            foodItemId: item.foodItemId,
            quantity: item.quantity,
            customizationItems: kept as any,
          },
        });
      }
    }

    return { message: 'Available items added to cart' };
  }
}
