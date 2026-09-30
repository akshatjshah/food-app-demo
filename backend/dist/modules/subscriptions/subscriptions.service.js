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
        return this.prisma.subscription.findMany({
            where: { isActive: true },
            orderBy: [{ displayOrder: 'asc' }, { price: 'asc' }],
        });
    }
    async findAllAdmin() {
        return this.prisma.subscription.findMany({ orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }] });
    }
    async createPlan(data) {
        const existing = await this.prisma.subscription.findUnique({ where: { name: data.name } });
        if (existing)
            throw new common_1.BadRequestException('A plan with this name already exists');
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
    async updatePlan(id, data) {
        const plan = await this.prisma.subscription.findUnique({ where: { id } });
        if (!plan)
            throw new common_1.BadRequestException('Subscription plan not found');
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
    async removePlan(id) {
        const activeSubs = await this.prisma.userSubscription.count({
            where: { subscriptionId: id, status: 'active' },
        });
        if (activeSubs > 0) {
            throw new common_1.BadRequestException('Plan has active subscribers. Deactivate it instead of deleting.');
        }
        return this.prisma.subscription.delete({ where: { id } });
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