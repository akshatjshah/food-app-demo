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
exports.OrdersService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
let OrdersService = class OrdersService {
    constructor(prisma, notificationsService) {
        this.prisma = prisma;
        this.notificationsService = notificationsService;
    }
    async create(userId, dto) {
        const address = await this.prisma.address.findFirst({
            where: { id: dto.addressId, userId },
        });
        if (!address) {
            throw new common_1.BadRequestException('Invalid delivery address');
        }
        const cart = await this.prisma.cart.findUnique({
            where: { userId },
            include: { items: { include: { foodItem: true } } },
        });
        if (!cart || cart.items.length === 0) {
            throw new common_1.BadRequestException('Cart is empty');
        }
        const errors = [];
        let itemTotal = 0;
        const orderItems = [];
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
                ? ci.customizationItems
                : [];
            const customizationTotal = customizationItems.reduce((s, c) => s + Number(c.additional_price || 0), 0);
            const unitPrice = basePrice + customizationTotal;
            itemTotal += unitPrice * ci.quantity;
            orderItems.push({
                foodItemId: ci.foodItemId,
                quantity: ci.quantity,
                unitPrice,
                customizations: customizationItems.map((c) => ({
                    customizationItemId: c.customization_item_id || c.id,
                    name: c.name || '',
                    additionalPrice: Number(c.additional_price || 0),
                })),
            });
        }
        if (errors.length > 0) {
            throw new common_1.BadRequestException({
                message: 'Some items are no longer available',
                errors,
            });
        }
        if (itemTotal < 1) {
            throw new common_1.BadRequestException(`Minimum order value is ₹1. Current total: ₹${itemTotal}`);
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
                    discountAmount = Math.min(itemTotal * (Number(coupon.discountValue) / 100), coupon.maxDiscountValue ? Number(coupon.maxDiscountValue) : Infinity);
                }
                else {
                    discountAmount = Number(coupon.discountValue);
                }
            }
        }
        const grandTotal = itemTotal + taxAmount + platformFee + deliveryFee - discountAmount;
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        const paymentMethod = (dto.paymentMethod || 'upi');
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
                                create: (oi.customizations || []).map((c) => ({
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
        await this.notificationsService.sendOrderStatusUpdate(userId, order.id, 'placed');
        try {
            this.notificationsService.emitNewOrderToAdmins({
                id: order.id,
                userId,
                status: order.status,
                grandTotal: Number(order.grandTotal),
                createdAt: order.createdAt,
            });
        }
        catch {
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
    toPlainOrder(o) {
        return {
            ...o,
            itemTotal: Number(o.itemTotal),
            grandTotal: Number(o.grandTotal),
            deliveryFee: Number(o.deliveryFee),
            platformFee: Number(o.platformFee),
            taxAmount: Number(o.taxAmount),
            discountAmount: Number(o.discountAmount),
            items: (o.items || []).map((item) => ({
                ...item,
                unitPrice: Number(item.unitPrice),
                total: Number(item.unitPrice) * item.quantity,
                customizations: (item.customizations || []).map((c) => ({
                    ...c,
                    additionalPrice: Number(c.additionalPrice),
                })),
            })),
        };
    }
    async findAll(userId, params) {
        const where = { userId };
        if (params.status)
            where.status = params.status;
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
    async findOne(id, requesterId, isAdmin = false) {
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
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (!isAdmin && requesterId) {
            const allowed = order.userId === requesterId ||
                order.chefId === requesterId ||
                order.deliveryBoyId === requesterId;
            if (!allowed)
                throw new common_1.BadRequestException('Not authorized');
        }
        const plain = this.toPlainOrder(order);
        if (order.address) {
            plain.deliveryAddress = {
                ...order.address,
                latitude: Number(order.address.latitude),
                longitude: Number(order.address.longitude),
            };
        }
        delete plain.otpCode;
        return plain;
    }
    async cancel(id, userId) {
        const order = await this.prisma.order.findUnique({ where: { id } });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (order.userId !== userId)
            throw new common_1.BadRequestException('Not authorized');
        if (!['placed', 'confirmed'].includes(order.status)) {
            throw new common_1.BadRequestException('Order cannot be cancelled');
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
    async reorder(userId, orderId) {
        const order = await this.prisma.order.findUnique({
            where: { id: orderId },
            include: { items: true },
        });
        if (!order)
            throw new common_1.NotFoundException('Order not found');
        if (order.userId !== userId)
            throw new common_1.BadRequestException('Not authorized');
        let cart = await this.prisma.cart.findUnique({ where: { userId } });
        if (!cart)
            cart = await this.prisma.cart.create({ data: { userId } });
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
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService])
], OrdersService);
//# sourceMappingURL=orders.service.js.map