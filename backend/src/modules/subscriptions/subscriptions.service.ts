import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class SubscriptionsService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async findAll() {
    return this.prisma.subscription.findMany({
      where: { isActive: true },
      orderBy: [{ displayOrder: 'asc' }, { price: 'asc' }],
    });
  }

  // ── Admin plan management. Existing user subscriptions reference the plan
  // by id and snapshot nothing, so edits apply to new subscriptions only in
  // effect; historical user_subscriptions keep their own dates/meals/status.
  // Deactivation (not delete) is the safe path when subscribers exist. ──
  async findAllAdmin() {
    return this.prisma.subscription.findMany({ orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }] });
  }

  async createPlan(data: {
    name: string; description?: string; price: number; durationDays: number;
    mealsCount: number; mealType: string; benefits?: string[]; isActive?: boolean;
    displayOrder?: number; imageUrl?: string;
  }) {
    const existing = await this.prisma.subscription.findUnique({ where: { name: data.name } });
    if (existing) throw new BadRequestException('A plan with this name already exists');
    return this.prisma.subscription.create({
      data: {
        name: data.name,
        description: data.description || null,
        price: data.price,
        durationDays: data.durationDays,
        mealsCount: data.mealsCount,
        mealType: data.mealType,
        benefits: data.benefits || [],
        isActive: data.isActive !== false,
        displayOrder: data.displayOrder ?? 0,
        imageUrl: data.imageUrl || null,
      },
    });
  }

  async updatePlan(id: string, data: Partial<{
    name: string; description: string; price: number; durationDays: number;
    mealsCount: number; mealType: string; benefits: string[]; isActive: boolean;
    displayOrder: number; imageUrl: string;
  }>) {
    const plan = await this.prisma.subscription.findUnique({ where: { id } });
    if (!plan) throw new BadRequestException('Subscription plan not found');
    return this.prisma.subscription.update({
      where: { id },
      data: {
        ...(data.name !== undefined ? { name: data.name } : {}),
        ...(data.description !== undefined ? { description: data.description || null } : {}),
        ...(data.price !== undefined ? { price: data.price } : {}),
        ...(data.durationDays !== undefined ? { durationDays: data.durationDays } : {}),
        ...(data.mealsCount !== undefined ? { mealsCount: data.mealsCount } : {}),
        ...(data.mealType !== undefined ? { mealType: data.mealType } : {}),
        ...(data.benefits !== undefined ? { benefits: data.benefits } : {}),
        ...(data.isActive !== undefined ? { isActive: data.isActive } : {}),
        ...(data.displayOrder !== undefined ? { displayOrder: data.displayOrder } : {}),
        ...(data.imageUrl !== undefined ? { imageUrl: data.imageUrl || null } : {}),
      },
    });
  }

  async removePlan(id: string) {
    const activeSubs = await this.prisma.userSubscription.count({
      where: { subscriptionId: id, status: 'active' },
    });
    if (activeSubs > 0) {
      throw new BadRequestException(
        'Plan has active subscribers. Deactivate it instead of deleting.',
      );
    }
    return this.prisma.subscription.delete({ where: { id } });
  }

  async getMy(userId: string) {
    return this.prisma.userSubscription.findMany({
      where: { userId },
      include: { subscription: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async subscribe(userId: string, subscriptionId: string) {
    const subscription = await this.prisma.subscription.findUnique({ where: { id: subscriptionId } });
    if (!subscription) throw new BadRequestException('Subscription not found');

    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + subscription.durationDays);

    const created = await this.prisma.userSubscription.create({
      data: {
        userId,
        subscriptionId,
        startDate,
        endDate,
        mealsRemaining: subscription.mealsCount,
        status: 'active',
      },
      include: { subscription: true },
    });

    await this.notificationsService.sendSubscriptionUpdate(
      userId,
      'created',
      subscription.name || 'Subscription',
      created.id,
    );

    return created;
  }

  async pause(id: string, userId: string) {
    const sub = await this.prisma.userSubscription.findUnique({
      where: { id },
      include: { subscription: true },
    });
    if (!sub || sub.userId !== userId) throw new BadRequestException('Not found');
    const updated = await this.prisma.userSubscription.update({ where: { id }, data: { status: 'paused' } });
    await this.notificationsService.sendSubscriptionUpdate(
      userId,
      'paused',
      sub.subscription?.name || 'Subscription',
      id,
    );
    return updated;
  }

  async resume(id: string, userId: string) {
    const sub = await this.prisma.userSubscription.findUnique({
      where: { id },
      include: { subscription: true },
    });
    if (!sub || sub.userId !== userId) throw new BadRequestException('Not found');
    const updated = await this.prisma.userSubscription.update({ where: { id }, data: { status: 'active' } });
    await this.notificationsService.sendSubscriptionUpdate(
      userId,
      'resumed',
      sub.subscription?.name || 'Subscription',
      id,
    );
    return updated;
  }

  async skipDay(id: string, userId: string, date: string) {
    const sub = await this.prisma.userSubscription.findUnique({
      where: { id },
      include: { subscription: true },
    });
    if (!sub || sub.userId !== userId) throw new BadRequestException('Not found');
    const skipDates = Array.isArray(sub.skipDates) ? sub.skipDates : [];
    const updated = await this.prisma.userSubscription.update({
      where: { id },
      data: { skipDates: [...skipDates, date] },
    });
    await this.notificationsService.sendSubscriptionUpdate(
      userId,
      'skipped',
      sub.subscription?.name || 'Subscription',
      id,
    );
    return updated;
  }
}
