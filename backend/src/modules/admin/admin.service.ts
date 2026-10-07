import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

const VALID_ORDER_STATUSES = [
  'pending_payment',
  'placed',
  'confirmed',
  'preparing',
  'ready',
  'rider_assigned',
  'picked_up',
  'out_for_delivery',
  'delivered',
  'cancelled',
  'rejected',
];

// Final Parabdi order workflow (single source of truth):
//   PLACED → CONFIRMED → PREPARING → OUT_FOR_DELIVERY → DELIVERED
// Rejection is a separate terminal path: backend status stays "rejected",
// displayed everywhere as "Cancelled" (red). There is exactly ONE visible
// Cancelled action per state (rejected for early states, cancelled for
// out_for_delivery/customer cancels) so the Admin dropdown never shows
// duplicate "cancelled / cancelled" rows.
// Legacy delivery states (ready/rider_assigned/picked_up) are NOT targets
// in the normal flow — they only drain forward to out_for_delivery so
// historically-stranded orders can still advance. The preparing → ready
// handoff was removed: preparing now advances to out_for_delivery.
const ORDER_TRANSITIONS: Record<string, string[]> = {
  pending_payment: ['placed', 'cancelled'],
  placed: ['confirmed', 'rejected'],
  confirmed: ['preparing', 'rejected'],
  preparing: ['out_for_delivery', 'rejected'],
  // Legacy drains (never offered as forward targets from normal states).
  ready: ['out_for_delivery', 'rejected'],
  rider_assigned: ['out_for_delivery'],
  picked_up: ['out_for_delivery'],
  out_for_delivery: ['delivered', 'cancelled'],
  delivered: [],
  cancelled: [],
  rejected: [],
};

@Injectable()
export class AdminService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async getDashboard() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalUsers,
      activeChefs,
      activeRiders,
      totalOrders,
      todayOrders,
      pendingOrders,
      completedOrders,
      cancelledOrders,
      activeSubscriptions,
      activeFoods,
      lowStockFoods,
      totalRevenue,
      todayRevenue,
    ] = await Promise.all([
      this.prisma.user.count({ where: { role: 'customer', isBlocked: false } }),
      this.prisma.user.count({ where: { role: 'chef', isBlocked: false } }),
      this.prisma.user.count({ where: { role: 'delivery', isBlocked: false } }),
      this.prisma.order.count(),
      this.prisma.order.count({ where: { createdAt: { gte: today } } }),
      this.prisma.order.count({ where: { status: { in: ['placed', 'confirmed', 'preparing', 'ready', 'rider_assigned', 'picked_up', 'out_for_delivery'] } } }),
      this.prisma.order.count({ where: { status: 'delivered' } }),
      this.prisma.order.count({ where: { status: { in: ['cancelled', 'rejected'] } } }),
      this.prisma.userSubscription.count({ where: { status: 'active' } }),
      this.prisma.foodItem.count({ where: { isActive: true, deletedAt: null } }),
      this.prisma.foodItem.count({ where: { stock: { not: null, lte: 5 }, deletedAt: null } }),
      this.prisma.order.aggregate({ where: { paymentStatus: 'paid' }, _sum: { grandTotal: true } }),
      this.prisma.order.aggregate({ where: { paymentStatus: 'paid', createdAt: { gte: today } }, _sum: { grandTotal: true } }),
    ]);

    return {
      totalOrders,
      todayOrders,
      pendingOrders,
      completedOrders,
      cancelledOrders,
      totalRevenue: Number(totalRevenue._sum.grandTotal || 0),
      revenueToday: Number(todayRevenue._sum.grandTotal || 0),
      activeSubscriptions,
      totalUsers,
      activeCustomers: totalUsers,
      activeFoods,
      lowStockFoods,
      activeChefs,
      activeRiders,
    };
  }

  async getRevenueChart(days: number = 7) {
    const safeDays = Math.min(Math.max(Math.floor(days) || 7, 1), 90);
    const start = new Date();
    start.setDate(start.getDate() - (safeDays - 1));
    start.setHours(0, 0, 0, 0);

    const grouped: { createdAt: Date; grandTotal: any }[] = await this.prisma.order.findMany({
      where: { paymentStatus: 'paid', createdAt: { gte: start } },
      select: { createdAt: true, grandTotal: true },
    });

    const byDay = new Map<string, { orders: number; revenue: number }>();
    for (let i = safeDays - 1; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = d.toISOString().split('T')[0];
      byDay.set(key, { orders: 0, revenue: 0 });
    }
    for (const o of grouped) {
      const key = new Date(o.createdAt).toISOString().split('T')[0];
      const slot = byDay.get(key);
      if (slot) {
        slot.orders += 1;
        slot.revenue += Number(o.grandTotal || 0);
      }
    }
    return [...byDay.entries()].map(([date, v]) => ({ date, revenue: v.revenue, orders: v.orders }));
  }

  async getOrdersByStatus() {
    // Must include every OrderStatus so rejected (and intermediate) orders
    // never disappear from admin counts.
    const statuses = ['pending_payment', 'placed', 'confirmed', 'preparing', 'ready', 'rider_assigned', 'picked_up', 'out_for_delivery', 'delivered', 'cancelled', 'rejected'];
    const results = await Promise.all(
      statuses.map(async (status) => {
        const count = await this.prisma.order.count({ where: { status: status as any } });
        return { status, count };
      }),
    );
    return results.filter((r) => r.count > 0);
  }

  async getTopDishes(limit: number = 10) {
    const safeLimit = Math.min(Math.max(Math.floor(limit) || 10, 1), 50);
    const items = await this.prisma.orderItem.groupBy({
      by: ['foodItemId'],
      _count: { id: true },
      _sum: { quantity: true },
      orderBy: { _count: { id: 'desc' } },
      take: safeLimit,
    });

    if (items.length === 0) return [];
    const ids = items.map((i) => i.foodItemId);
    const foods = await this.prisma.foodItem.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true },
    });
    const nameById = new Map(foods.map((f) => [f.id, f.name]));

    return items.map((item) => ({
      id: item.foodItemId,
      name: nameById.get(item.foodItemId) || 'Unknown',
      orderCount: item._count.id,
      quantity: item._sum.quantity || 0,
    }));
  }

  async getRecentOrders(limit: number = 5) {
    const safeLimit = Math.min(Math.max(Math.floor(limit) || 5, 1), 50);
    const orders = await this.prisma.order.findMany({
      take: safeLimit,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, fullName: true, phoneNumber: true } },
      },
    });

    return orders.map((o) => ({
      id: o.id,
      orderNumber: o.id.slice(0, 8).toUpperCase(),
      customerName: o.user.fullName || o.user.phoneNumber,
      total: Number(o.grandTotal),
      status: o.status,
      createdAt: o.createdAt,
    }));
  }

  async getOrders(params: { skip?: number; take?: number; status?: string; paymentStatus?: string; search?: string }) {
    const where: any = {};
    // Single visible "Cancelled" filter covers both internal statuses:
    // customer cancels (cancelled) and admin/chef rejections (rejected).
    if (params.status) {
      if (params.status === 'cancelled') {
        where.status = { in: ['cancelled', 'rejected'] };
      } else {
        where.status = params.status;
      }
    }
    if (params.paymentStatus) where.paymentStatus = params.paymentStatus;
    if (params.search) {
      where.OR = [
        { id: { contains: params.search, mode: 'insensitive' } },
        { user: { fullName: { contains: params.search, mode: 'insensitive' } } },
      ];
    }

    const take = Math.min(params.take || 20, 100);
    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        include: {
          user: { select: { id: true, fullName: true, phoneNumber: true } },
          items: { include: { foodItem: { select: { name: true } } } },
        },
        orderBy: { createdAt: 'desc' },
        skip: params.skip || 0,
        take,
      }),
      this.prisma.order.count({ where }),
    ]);
    // Delivery OTPs are never exposed in list responses.
    return { data: orders.map(({ otpCode, ...o }) => o), total };
  }

  async updateOrderStatus(orderId: string, status: string, triggeredBy?: string) {
    if (!VALID_ORDER_STATUSES.includes(status)) {
      throw new BadRequestException(`Invalid order status: ${status}`);
    }
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    const allowed = ORDER_TRANSITIONS[order.status] || [];
    if (!allowed.includes(status)) {
      throw new BadRequestException(
        `Cannot transition order from ${order.status} to ${status}`,
      );
    }

    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: status as any },
    });

    await this.prisma.orderStatusHistory.create({
      data: {
        orderId,
        fromStatus: order.status,
        toStatus: status as any,
        triggeredBy,
      },
    });

    if (triggeredBy) {
      await this.logAudit(triggeredBy, {
        action: 'order.status',
        entity: 'order',
        entityId: orderId,
        oldValue: { status: order.status },
        newValue: { status },
      });
    }

    // Notify the customer about the new status (best-effort).
    await this.notificationsService.sendOrderStatusUpdate(order.userId, orderId, status);

    return updated;
  }

  /**
   * Admin announcement / offer broadcast.
   * When userIds is omitted, all customers are targeted.
   */
  async broadcastAnnouncement(
    title: string,
    body: string,
    type: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' | 'BROADCAST' = 'ANNOUNCEMENT',
    userIds?: string[],
    referenceId?: string,
  ) {
    let targets = userIds;
    if (!targets || targets.length === 0) {
      const customers = await this.prisma.user.findMany({
        where: { role: 'customer' },
        select: { id: true },
      });
      targets = customers.map((c) => c.id);
    }
    return this.notificationsService.sendBulkNotification(targets, title, body, type, referenceId);
  }

  async logAudit(adminId: string, data: { action: string; entity: string; entityId?: string; oldValue?: any; newValue?: any; ipAddress?: string }) {
    return this.prisma.adminAuditLog.create({ data: { adminId, ...data } });
  }

  async getAuditLogs(params: { skip?: number; take?: number; entity?: string; action?: string; search?: string }) {
    const where: any = {};
    if (params.entity) where.entity = params.entity;
    if (params.action) where.action = { contains: params.action, mode: 'insensitive' };
    if (params.search) {
      where.OR = [
        { entityId: { contains: params.search, mode: 'insensitive' } },
        { admin: { fullName: { contains: params.search, mode: 'insensitive' } } },
      ];
    }
    const take = Math.min(params.take || 20, 100);
    const [data, total] = await Promise.all([
      this.prisma.adminAuditLog.findMany({
        where,
        include: { admin: { select: { id: true, fullName: true, email: true } } },
        orderBy: { createdAt: 'desc' },
        skip: params.skip || 0,
        take,
      }),
      this.prisma.adminAuditLog.count({ where }),
    ]);
    return { data, total };
  }

  // ── Order detail (admin): full operational view, OTP never exposed ──
  async getOrderDetail(orderId: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        user: { select: { id: true, fullName: true, phoneNumber: true, email: true, walletBalance: true, isBlocked: true } },
        address: true,
        chef: { select: { id: true, fullName: true, phoneNumber: true } },
        deliveryBoy: { select: { id: true, fullName: true, phoneNumber: true } },
        items: {
          include: {
            foodItem: { select: { id: true, name: true, imageUrls: true, isVeg: true, price: true } },
            customizations: true,
          },
        },
        statusHistory: { orderBy: { createdAt: 'desc' } },
        couponUsages: { include: { coupon: { select: { id: true, code: true, discountType: true, discountValue: true } } } },
      },
    });
    if (!order) throw new NotFoundException('Order not found');
    const { otpCode, ...rest } = order as any;
    const num = (v: any) => Number(v || 0);
    return {
      ...rest,
      itemTotal: num(order.itemTotal),
      taxAmount: num(order.taxAmount),
      deliveryFee: num(order.deliveryFee),
      platformFee: num(order.platformFee),
      discountAmount: num(order.discountAmount),
      grandTotal: num(order.grandTotal),
      items: order.items.map((i) => ({
        ...i,
        unitPrice: num(i.unitPrice),
        total: num(i.unitPrice) * i.quantity,
        customizations: i.customizations.map((c) => ({ ...c, additionalPrice: num((c as any).price ?? 0) })),
      })),
    };
  }

  // ── Customers ──
  async getCustomers(params: { search?: string; skip?: number; take?: number }) {
    const where: any = { role: 'customer' };
    if (params.search) {
      where.OR = [
        { fullName: { contains: params.search, mode: 'insensitive' } },
        { phoneNumber: { contains: params.search, mode: 'insensitive' } },
        { email: { contains: params.search, mode: 'insensitive' } },
      ];
    }
    const take = Math.min(params.take || 20, 100);
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true, fullName: true, phoneNumber: true, email: true,
          walletBalance: true, isBlocked: true, createdAt: true,
          _count: { select: { orders: true, subscriptions: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip: params.skip || 0,
        take,
      }),
      this.prisma.user.count({ where }),
    ]);
    const ids = users.map((u) => u.id);
    const spend = ids.length
      ? await this.prisma.order.groupBy({
          by: ['userId'],
          where: { userId: { in: ids }, paymentStatus: 'paid' },
          _sum: { grandTotal: true },
        })
      : [];
    const spendById = new Map(spend.map((s) => [s.userId, Number(s._sum.grandTotal || 0)]));
    return {
      data: users.map((u) => ({
        ...u,
        walletBalance: Number(u.walletBalance),
        orderCount: u._count.orders,
        subscriptionCount: u._count.subscriptions,
        totalSpend: spendById.get(u.id) || 0,
      })),
      total,
    };
  }

  async getCustomerDetail(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        addresses: true,
        subscriptions: { include: { subscription: true }, orderBy: { createdAt: 'desc' }, take: 10 },
        orders: {
          orderBy: { createdAt: 'desc' },
          take: 10,
          select: { id: true, status: true, paymentStatus: true, grandTotal: true, createdAt: true, deliverySlot: true },
        },
        _count: { select: { orders: true } },
      },
    });
    if (!user || user.role !== 'customer') throw new NotFoundException('Customer not found');
    const { passwordHash, ...safe } = user as any;
    const spend = await this.prisma.order.aggregate({
      where: { userId: id, paymentStatus: 'paid' },
      _sum: { grandTotal: true },
    });
    return {
      ...safe,
      walletBalance: Number((user as any).walletBalance),
      totalSpend: Number(spend._sum.grandTotal || 0),
    };
  }

  async setCustomerBlocked(id: string, isBlocked: boolean, adminId: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user || user.role !== 'customer') throw new NotFoundException('Customer not found');
    const updated = await this.prisma.user.update({ where: { id }, data: { isBlocked } });
    await this.logAudit(adminId, {
      action: isBlocked ? 'customer.block' : 'customer.unblock',
      entity: 'user',
      entityId: id,
      oldValue: { isBlocked: user.isBlocked },
      newValue: { isBlocked },
    });
    const { passwordHash, ...safe } = updated as any;
    return safe;
  }

  // ── Staff (chefs / riders) ──
  async getStaff(role: 'chef' | 'delivery', search?: string) {
    const where: any = { role };
    if (search) {
      where.OR = [
        { fullName: { contains: search, mode: 'insensitive' } },
        { phoneNumber: { contains: search, mode: 'insensitive' } },
      ];
    }
    const staff = await this.prisma.user.findMany({
      where,
      select: { id: true, fullName: true, phoneNumber: true, email: true, isBlocked: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    const ids = staff.map((s) => s.id);
    const [assigned, delivered] = ids.length
      ? await Promise.all([
          this.prisma.order.groupBy({
            by: role === 'chef' ? ['chefId'] : ['deliveryBoyId'],
            where: role === 'chef'
              ? { chefId: { in: ids }, status: { notIn: ['delivered', 'cancelled', 'rejected'] } }
              : { deliveryBoyId: { in: ids }, status: { notIn: ['delivered', 'cancelled', 'rejected'] } },
            _count: { id: true },
          }),
          this.prisma.order.groupBy({
            by: role === 'chef' ? ['chefId'] : ['deliveryBoyId'],
            where: role === 'chef'
              ? { chefId: { in: ids }, status: 'delivered' }
              : { deliveryBoyId: { in: ids }, status: 'delivered' },
            _count: { id: true },
          }),
        ])
      : [[], []];
    const key = role === 'chef' ? 'chefId' : 'deliveryBoyId';
    const activeById = new Map(assigned.map((a: any) => [a[key], a._count.id]));
    const doneById = new Map(delivered.map((a: any) => [a[key], a._count.id]));
    return staff.map((s) => ({
      ...s,
      activeOrders: activeById.get(s.id) || 0,
      completedOrders: doneById.get(s.id) || 0,
    }));
  }

  async createStaff(data: { fullName: string; phoneNumber: string; email?: string; role: 'chef' | 'delivery' }, adminId: string) {
    if (!['chef', 'delivery'].includes(data.role)) {
      throw new BadRequestException('Role must be chef or delivery');
    }
    const existing = await this.prisma.user.findUnique({ where: { phoneNumber: data.phoneNumber } });
    if (existing) throw new BadRequestException('Phone number already registered');
    const created = await this.prisma.user.create({
      data: { fullName: data.fullName, phoneNumber: data.phoneNumber, email: data.email || null, role: data.role as any },
    });
    await this.logAudit(adminId, { action: 'staff.create', entity: 'user', entityId: created.id, newValue: { fullName: data.fullName, role: data.role } });
    const { passwordHash, ...safe } = created as any;
    return safe;
  }

  async updateStaff(id: string, data: { fullName?: string; email?: string; isBlocked?: boolean; role?: 'chef' | 'delivery' }, adminId: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user || !['chef', 'delivery', 'admin'].includes(user.role)) {
      throw new NotFoundException('Staff member not found');
    }
    if (data.role && !['chef', 'delivery'].includes(data.role)) {
      throw new BadRequestException('Role must be chef or delivery');
    }
    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        ...(data.fullName !== undefined ? { fullName: data.fullName } : {}),
        ...(data.email !== undefined ? { email: data.email || null } : {}),
        ...(data.isBlocked !== undefined ? { isBlocked: data.isBlocked } : {}),
        ...(data.role ? { role: data.role as any } : {}),
      },
    });
    await this.logAudit(adminId, { action: 'staff.update', entity: 'user', entityId: id, oldValue: { fullName: user.fullName, isBlocked: user.isBlocked, role: user.role }, newValue: data });
    const { passwordHash, ...safe } = updated as any;
    return safe;
  }

  // ── Wallet / loyalty overview ──
  async getWalletTransactions(params: { skip?: number; take?: number; search?: string }) {
    const where: any = {};
    if (params.search) {
      where.OR = [
        { description: { contains: params.search, mode: 'insensitive' } },
        { user: { phoneNumber: { contains: params.search, mode: 'insensitive' } } },
        { user: { fullName: { contains: params.search, mode: 'insensitive' } } },
      ];
    }
    const take = Math.min(params.take || 20, 100);
    const [data, total] = await Promise.all([
      this.prisma.walletTransaction.findMany({
        where,
        include: { user: { select: { id: true, fullName: true, phoneNumber: true } } },
        orderBy: { createdAt: 'desc' },
        skip: params.skip || 0,
        take,
      }),
      this.prisma.walletTransaction.count({ where }),
    ]);
    return { data: data.map((t) => ({ ...t, amount: Number(t.amount) })), total };
  }

  async getLoyaltyTransactions(params: { skip?: number; take?: number; search?: string }) {
    const where: any = {};
    if (params.search) {
      where.OR = [
        { description: { contains: params.search, mode: 'insensitive' } },
        { user: { phoneNumber: { contains: params.search, mode: 'insensitive' } } },
        { user: { fullName: { contains: params.search, mode: 'insensitive' } } },
      ];
    }
    const take = Math.min(params.take || 20, 100);
    const [data, total] = await Promise.all([
      this.prisma.loyaltyPoint.findMany({
        where,
        include: { user: { select: { id: true, fullName: true, phoneNumber: true } } },
        orderBy: { createdAt: 'desc' },
        skip: params.skip || 0,
        take,
      }),
      this.prisma.loyaltyPoint.count({ where }),
    ]);
    return { data, total };
  }

  async getRecentNotifications(take = 50) {
    const safeTake = Math.min(Math.max(take || 50, 1), 100);
    return this.prisma.notification.findMany({
      include: { user: { select: { id: true, fullName: true, phoneNumber: true } } },
      orderBy: { createdAt: 'desc' },
      take: safeTake,
    });
  }  async getReports(days = 30) {
    const safeDays = Math.min(Math.max(Math.floor(days) || 30, 1), 365);
    const start = new Date();
    start.setDate(start.getDate() - (safeDays - 1));
    start.setHours(0, 0, 0, 0);
    const [orders, newCustomers, revenue] = await Promise.all([
      this.prisma.order.findMany({
        where: { createdAt: { gte: start } },
        select: { createdAt: true, grandTotal: true, status: true, paymentStatus: true },
      }),
      this.prisma.user.findMany({
        where: { role: 'customer', createdAt: { gte: start } },
        select: { createdAt: true },
      }),
      this.getRevenueChart(safeDays),
    ]);
    const paidOrders = orders.filter((o) => o.paymentStatus === 'paid');
    const totalRevenue = paidOrders.reduce((s, o) => s + Number(o.grandTotal || 0), 0);
    return {
      totalOrders: orders.length,
      totalRevenue,
      avgOrderValue: paidOrders.length ? totalRevenue / paidOrders.length : 0,
      newCustomers: newCustomers.length,
      byDay: revenue,
    };
  }
}
