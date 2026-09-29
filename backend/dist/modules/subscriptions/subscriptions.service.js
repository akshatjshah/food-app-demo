"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SubscriptionsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
let SubscriptionsService = class SubscriptionsService {
    constructor(prisma, notificationsService) {
        this.prisma = prisma;
        this.notificationsService = notificationsService;
    }
    async findAll() {
        return this.prisma.subscription.findMany({ where: { isActive: true } });
    }
    async getMy(userId) {
        return this.prisma.userSubscription.findMany({
            where: { userId },
            include: { subscription: true },
            orderBy: { createdAt: 'desc' },
        });
    }
    async subscribe(userId, subscriptionId) {
        const subscription = await this.prisma.subscription.findUnique({ where: { id: subscriptionId } });
        if (!subscription)
            throw new common_1.BadRequestException('Subscription not found');
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
        await this.notificationsService.sendSubscriptionUpdate(userId, 'created', subscription.name || 'Subscription', created.id);
        return created;
    }
    async pause(id, userId) {
        const sub = await this.prisma.userSubscription.findUnique({
            where: { id },
            include: { subscription: true },
        });
        if (!sub || sub.userId !== userId)
            throw new common_1.BadRequestException('Not found');
        const updated = await this.prisma.userSubscription.update({ where: { id }, data: { status: 'paused' } });
        await this.notificationsService.sendSubscriptionUpdate(userId, 'paused', sub.subscription?.name || 'Subscription', id);
        return updated;
    }
    async resume(id, userId) {
        const sub = await this.prisma.userSubscription.findUnique({
            where: { id },
            include: { subscription: true },
        });
        if (!sub || sub.userId !== userId)
            throw new common_1.BadRequestException('Not found');
        const updated = await this.prisma.userSubscription.update({ where: { id }, data: { status: 'active' } });
        await this.notificationsService.sendSubscriptionUpdate(userId, 'resumed', sub.subscription?.name || 'Subscription', id);
        return updated;
    }
    async skipDay(id, userId, date) {
        const sub = await this.prisma.userSubscription.findUnique({
            where: { id },
            include: { subscription: true },
        });
        if (!sub || sub.userId !== userId)
            throw new common_1.BadRequestException('Not found');
        const skipDates = Array.isArray(sub.skipDates) ? sub.skipDates : [];
        const updated = await this.prisma.userSubscription.update({
            where: { id },
            data: { skipDates: [...skipDates, date] },
        });
        await this.notificationsService.sendSubscriptionUpdate(userId, 'skipped', sub.subscription?.name || 'Subscription', id);
        return updated;
    }
};
exports.SubscriptionsService = SubscriptionsService;
exports.SubscriptionsService = SubscriptionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService])
], SubscriptionsService);
//# sourceMappingURL=subscriptions.service.js.map