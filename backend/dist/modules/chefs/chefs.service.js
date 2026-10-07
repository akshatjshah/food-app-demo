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
exports.ChefsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
let ChefsService = class ChefsService {
    constructor(prisma, notificationsService) {
        this.prisma = prisma;
        this.notificationsService = notificationsService;
    }
    async findByPin(pin) {
        return this.prisma.user.findFirst({ where: { role: 'chef', phoneNumber: pin } });
    }
    async getDashboard(chefId) {
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
                where: { chefId, status: { in: ['ready', 'out_for_delivery'] } },
            }),
        ]);
        return { totalOrders, preparingOrders, readyOrders };
    }
    async getOrders(chefId, status) {
        const where = {
            OR: [
                { chefId },
                { chefId: null, status: { in: ['placed', 'confirmed'] } },
            ],
        };
        if (status)
            where.status = status;
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
    async acceptOrder(orderId, chefId) {
        const order = await this.prisma.order.findUnique({ where: { id: orderId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (order.chefId && order.chefId !== chefId) {
            throw new common_1.ForbiddenException('Order already assigned to another chef');
        }
        if (!['placed', 'confirmed'].includes(order.status)) {
            throw new common_1.BadRequestException(`Cannot accept order in status ${order.status}`);
        }
        const updated = await this.prisma.order.update({
            where: { id: orderId },
            data: { status: 'confirmed', chefId },
        });
        await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'confirmed');
        return updated;
    }
    async startPreparing(orderId, chefId) {
        const order = await this.prisma.order.findUnique({ where: { id: orderId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (chefId && order.chefId && order.chefId !== chefId) {
            throw new common_1.ForbiddenException('Order assigned to another chef');
        }
        if (!['confirmed', 'placed'].includes(order.status)) {
            throw new common_1.BadRequestException(`Cannot start preparing from status ${order.status}`);
        }
        const updated = await this.prisma.order.update({
            where: { id: orderId },
            data: { status: 'preparing', ...(chefId ? { chefId } : {}) },
        });
        await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'preparing');
        return updated;
    }
    async markReady(orderId, chefId) {
        const order = await this.prisma.order.findUnique({ where: { id: orderId } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (chefId && order.chefId && order.chefId !== chefId) {
            throw new common_1.ForbiddenException('Order assigned to another chef');
        }
        if (order.status !== 'preparing' && order.status !== 'ready') {
            throw new common_1.BadRequestException(`Cannot mark ready from status ${order.status}`);
        }
        const updated = await this.prisma.order.update({
            where: { id: orderId },
            data: { status: 'out_for_delivery' },
        });
        await this.notificationsService.sendOrderStatusUpdate(updated.userId, orderId, 'out_for_delivery');
        return updated;
    }
    async toggleFoodStock(foodItemId) {
        const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId } });
        if (!food)
            throw new Error('Food item not found');
        return this.prisma.foodItem.update({
            where: { id: foodItemId },
            data: { isActive: !food.isActive },
        });
    }
};
exports.ChefsService = ChefsService;
exports.ChefsService = ChefsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService])
], ChefsService);
//# sourceMappingURL=chefs.service.js.map