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
exports.CartService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let CartService = class CartService {
    constructor(prisma) {
        this.prisma = prisma;
        this.foodItemSelect = {
            id: true, name: true, price: true, imageUrls: true,
            isVeg: true, isActive: true, deletedAt: true,
            preparationTimeMinutes: true,
        };
    }
    isFoodAvailable(foodItem) {
        return !!foodItem.isActive && foodItem.isAvailable !== false && !foodItem.deletedAt;
    }
    async validateCustomizations(foodItemId, customizationItems) {
        const list = Array.isArray(customizationItems) ? customizationItems : [];
        const groups = await this.prisma.customizationGroup.findMany({
            where: { foodItemId, isActive: true },
            include: { items: true },
        });
        const groupById = new Map(groups.map((g) => [g.id, g]));
        const itemById = new Map();
        for (const g of groups) {
            for (const it of g.items)
                itemById.set(it.id, { item: it, group: g });
        }
        const selectedByGroup = new Map();
        const normalized = [];
        let additionalTotal = 0;
        for (const ci of list) {
            const groupId = ci.customization_group_id || ci.groupId || ci.group_id;
            const itemId = ci.customization_item_id || ci.customizationItemId || ci.id;
            if (!itemId)
                throw new common_1.BadRequestException('Invalid customization option: missing id');
            const found = itemById.get(itemId);
            if (!found)
                throw new common_1.BadRequestException(`Invalid customization option: ${itemId}`);
            if (!found.item.isActive)
                throw new common_1.BadRequestException(`Option "${found.item.name}" is not available`);
            if (!found.group.isActive)
                throw new common_1.BadRequestException(`Option group "${found.group.name}" is not active`);
            if (groupId && groupId !== found.group.id) {
                throw new common_1.BadRequestException(`Option "${found.item.name}" does not belong to the given group`);
            }
            const gid = found.group.id;
            if (!selectedByGroup.has(gid))
                selectedByGroup.set(gid, []);
            const arr = selectedByGroup.get(gid);
            if (arr.includes(itemId))
                throw new common_1.BadRequestException(`Duplicate option "${found.item.name}"`);
            arr.push(itemId);
            const price = Number(found.item.additionalPrice);
            additionalTotal += price;
            normalized.push({
                customization_group_id: gid,
                customization_item_id: found.item.id,
                id: found.item.id,
                name: found.item.name,
                additional_price: price,
                group: found.group.name,
            });
        }
        for (const g of groups) {
            const count = selectedByGroup.get(g.id)?.length ?? 0;
            if (count < g.minSelections) {
                if (g.minSelections > 0) {
                    throw new common_1.BadRequestException(`"${g.name}" requires at least ${g.minSelections} selection(s)`);
                }
            }
            if (count > g.maxSelections) {
                throw new common_1.BadRequestException(`"${g.name}" allows at most ${g.maxSelections} selection(s)`);
            }
        }
        normalized.sort((a, b) => String(a.customization_item_id).localeCompare(String(b.customization_item_id)));
        return { normalized, additionalTotal };
    }
    customizationSignature(items) {
        const ids = (Array.isArray(items) ? items : [])
            .map((c) => String(c.customization_item_id || c.id || ''))
            .filter(Boolean)
            .sort();
        return ids.join('|');
    }
    async getCart(userId) {
        let cart = await this.prisma.cart.findUnique({
            where: { userId },
            include: {
                items: {
                    include: {
                        foodItem: { select: this.foodItemSelect },
                    },
                },
            },
        });
        if (!cart) {
            cart = await this.prisma.cart.create({
                data: { userId },
                include: {
                    items: {
                        include: {
                            foodItem: { select: this.foodItemSelect },
                        },
                    },
                },
            });
        }
        const items = cart.items.map((i) => {
            const basePrice = Number(i.foodItem.price);
            const customizationTotal = Array.isArray(i.customizationItems)
                ? i.customizationItems.reduce((s, c) => s + Number(c.additional_price || 0), 0)
                : 0;
            const unitPrice = basePrice + customizationTotal;
            const itemTotal = unitPrice * i.quantity;
            const isAvailable = this.isFoodAvailable(i.foodItem);
            return {
                id: i.id,
                foodItemId: i.foodItemId,
                quantity: i.quantity,
                customizationItems: Array.isArray(i.customizationItems)
                    ? i.customizationItems
                    : [],
                specialInstructions: i.specialInstructions,
                createdAt: i.createdAt,
                foodItem: {
                    id: i.foodItem.id,
                    name: i.foodItem.name,
                    price: basePrice,
                    imageUrls: i.foodItem.imageUrls,
                    isVeg: i.foodItem.isVeg,
                    preparationTimeMinutes: i.foodItem.preparationTimeMinutes,
                },
                unitPrice,
                itemTotal,
                isAvailable,
            };
        });
        const availableItems = items.filter((i) => i.isAvailable);
        const unavailableItems = items.filter((i) => !i.isAvailable);
        const itemTotal = availableItems.reduce((sum, i) => sum + i.itemTotal, 0);
        const itemCount = availableItems.reduce((sum, i) => sum + i.quantity, 0);
        return {
            id: cart.id,
            items: availableItems,
            unavailableItems,
            itemTotal,
            itemCount,
            hasUnavailableItems: unavailableItems.length > 0,
        };
    }
    async addItem(userId, dto) {
        if (dto.quantity < 1) {
            throw new common_1.BadRequestException('Quantity must be at least 1');
        }
        const foodItem = await this.prisma.foodItem.findUnique({
            where: { id: dto.foodItemId },
        });
        if (!foodItem) {
            throw new common_1.NotFoundException('Food item not found');
        }
        if (!foodItem.isActive || foodItem.isAvailable === false) {
            throw new common_1.BadRequestException('This item is no longer available');
        }
        if (foodItem.deletedAt) {
            throw new common_1.BadRequestException('This item has been removed');
        }
        const { normalized } = await this.validateCustomizations(dto.foodItemId, dto.customizationItems);
        let cart = await this.prisma.cart.findUnique({ where: { userId } });
        if (!cart) {
            cart = await this.prisma.cart.create({ data: { userId } });
        }
        const signature = this.customizationSignature(normalized);
        const siblings = await this.prisma.cartItem.findMany({
            where: { cartId: cart.id, foodItemId: dto.foodItemId },
        });
        const existingItem = siblings.find((s) => this.customizationSignature(s.customizationItems || []) === signature);
        if (existingItem) {
            return this.prisma.cartItem.update({
                where: { id: existingItem.id },
                data: {
                    quantity: existingItem.quantity + dto.quantity,
                    customizationItems: normalized,
                    specialInstructions: dto.specialInstructions || existingItem.specialInstructions,
                },
            });
        }
        return this.prisma.cartItem.create({
            data: {
                cartId: cart.id,
                foodItemId: dto.foodItemId,
                quantity: dto.quantity,
                customizationItems: normalized,
                specialInstructions: dto.specialInstructions,
            },
        });
    }
    async updateItem(userId, itemId, quantity) {
        const cart = await this.prisma.cart.findUnique({ where: { userId } });
        if (!cart)
            throw new common_1.NotFoundException('Cart not found');
        const cartItem = await this.prisma.cartItem.findFirst({
            where: { id: itemId, cartId: cart.id },
        });
        if (!cartItem)
            throw new common_1.NotFoundException('Cart item not found');
        if (quantity <= 0) {
            return this.prisma.cartItem.delete({ where: { id: itemId } });
        }
        return this.prisma.cartItem.update({
            where: { id: itemId },
            data: { quantity },
        });
    }
    async removeItem(userId, itemId) {
        const cart = await this.prisma.cart.findUnique({ where: { userId } });
        if (!cart)
            throw new common_1.NotFoundException('Cart not found');
        const cartItem = await this.prisma.cartItem.findFirst({
            where: { id: itemId, cartId: cart.id },
        });
        if (!cartItem)
            throw new common_1.NotFoundException('Cart item not found');
        return this.prisma.cartItem.delete({ where: { id: itemId } });
    }
    async clearCart(userId) {
        const cart = await this.prisma.cart.findUnique({ where: { userId } });
        if (!cart)
            return;
        await this.prisma.cartItem.deleteMany({ where: { cartId: cart.id } });
        return { message: 'Cart cleared' };
    }
    async validateCartForCheckout(userId) {
        const cart = await this.prisma.cart.findUnique({
            where: { userId },
            include: {
                items: {
                    include: {
                        foodItem: true,
                    },
                },
            },
        });
        if (!cart || cart.items.length === 0) {
            throw new common_1.BadRequestException('Cart is empty');
        }
        const errors = [];
        let itemTotal = 0;
        for (const item of cart.items) {
            if (!item.foodItem.isActive || item.foodItem.isAvailable === false) {
                errors.push(`${item.foodItem.name} is no longer available`);
                continue;
            }
            if (item.foodItem.deletedAt) {
                errors.push(`${item.foodItem.name} has been removed`);
                continue;
            }
            const basePrice = Number(item.foodItem.price);
            const customizationTotal = Array.isArray(item.customizationItems)
                ? item.customizationItems.reduce((s, c) => s + Number(c.additional_price || 0), 0)
                : 0;
            itemTotal += (basePrice + customizationTotal) * item.quantity;
        }
        if (errors.length > 0) {
            throw new common_1.BadRequestException({
                message: 'Some items in your cart are no longer available',
                errors,
            });
        }
        if (itemTotal < 1) {
            throw new common_1.BadRequestException(`Minimum order value is ₹1. Current total: ₹${itemTotal}`);
        }
        return {
            isValid: true,
            itemTotal,
            itemCount: cart.items.reduce((sum, i) => sum + i.quantity, 0),
            taxAmount: itemTotal * 0.05,
            platformFee: 2,
            deliveryFee: itemTotal >= 200 ? 0 : 30,
            grandTotal: itemTotal + itemTotal * 0.05 + 2 + (itemTotal >= 200 ? 0 : 30),
        };
    }
};
exports.CartService = CartService;
exports.CartService = CartService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], CartService);
//# sourceMappingURL=cart.service.js.map