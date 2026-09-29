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
    return this.prisma.subscription.findMany({ where: { isActive: true } });
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
