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
exports.FoodsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let FoodsService = class FoodsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(params) {
        const { skip, take, categoryId, search, isVeg, isJainAvailable, isFastingFriendly, isBestseller, isHealthyPick, minPrice, maxPrice, includeInactive, } = params;
        const where = { deletedAt: null };
        if (!includeInactive) {
            where.isActive = true;
        }
        if (categoryId)
            where.categoryId = categoryId;
        if (isVeg !== undefined)
            where.isVeg = isVeg;
        if (isJainAvailable !== undefined)
            where.isJainAvailable = isJainAvailable;
        if (isFastingFriendly !== undefined)
            where.isFastingFriendly = isFastingFriendly;
        if (isBestseller !== undefined)
            where.isBestseller = isBestseller;
        if (isHealthyPick !== undefined)
            where.isHealthyPick = isHealthyPick;
        if (search)
            where.name = { contains: search, mode: 'insensitive' };
        if (minPrice !== undefined || maxPrice !== undefined) {
            where.price = {};
            if (minPrice !== undefined)
                where.price.gte = minPrice;
            if (maxPrice !== undefined)
                where.price.lte = maxPrice;
        }
        const foods = await this.prisma.foodItem.findMany({
            where,
            skip: skip || 0,
            take: take || 50,
            include: {
                category: { select: { id: true, name: true, icon: true } },
                customizationGroups: {
                    where: includeInactive ? undefined : { isActive: true },
                    include: { items: { where: { isActive: true } } },
                    orderBy: { displayOrder: 'asc' },
                },
            },
            orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
        });
        return foods.map((f) => ({
            ...f,
            price: Number(f.price),
            originalPrice: f.originalPrice ? Number(f.originalPrice) : null,
            rating: Number(f.rating),
            customizationGroups: f.customizationGroups.map((g) => ({
                ...g,
                items: g.items.map((i) => ({ ...i, additionalPrice: Number(i.additionalPrice) })),
            })),
        }));
    }
    async findSpecials() {
        return this.findAll({ isBestseller: true, includeInactive: false });
    }
    async findOne(id) {
        const food = await this.prisma.foodItem.findUnique({
            where: { id, deletedAt: null },
            include: {
                category: { select: { id: true, name: true, icon: true } },
                customizationGroups: {
                    where: { isActive: true },
                    include: { items: { where: { isActive: true } } },
                    orderBy: { displayOrder: 'asc' },
                },
            },
        });
        if (!food)
            throw new common_1.NotFoundException('Food item not found');
        return {
            ...food,
            price: Number(food.price),
            originalPrice: food.originalPrice ? Number(food.originalPrice) : null,
            rating: Number(food.rating),
            customizationGroups: food.customizationGroups.map((g) => ({
                ...g,
                items: g.items.map((i) => ({ ...i, additionalPrice: Number(i.additionalPrice) })),
            })),
        };
    }
    async create(data) {
        if (data.isVeg === false) {
            throw new common_1.BadRequestException('Parabdi is pure vegetarian. Non-veg items are not allowed.');
        }
        if (data.price !== undefined && data.price <= 0) {
            throw new common_1.BadRequestException('Price must be a positive number.');
        }
        if (data.originalPrice !== undefined && data.originalPrice <= 0) {
            throw new common_1.BadRequestException('Original price must be a positive number.');
        }
        const category = await this.prisma.category.findUnique({
            where: { id: data.categoryId },
        });
        if (!category)
            throw new common_1.BadRequestException('Invalid category reference.');
        if (!category.isActive)
            throw new common_1.BadRequestException('Cannot add food to an inactive category.');
        return this.prisma.foodItem.create({
            data: { ...data, isVeg: true },
        });
    }
    async update(id, data) {
        const existing = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
        if (!existing)
            throw new common_1.NotFoundException('Food item not found');
        if (data.isVeg === false) {
            throw new common_1.BadRequestException('Parabdi is pure vegetarian. Non-veg items are not allowed.');
        }
        if (data.price !== undefined && data.price <= 0) {
            throw new common_1.BadRequestException('Price must be a positive number.');
        }
        if (data.originalPrice !== undefined && data.originalPrice <= 0) {
            throw new common_1.BadRequestException('Original price must be a positive number.');
        }
        if (data.categoryId) {
            const category = await this.prisma.category.findUnique({
                where: { id: data.categoryId },
            });
            if (!category)
                throw new common_1.BadRequestException('Invalid category reference.');
            if (!category.isActive)
                throw new common_1.BadRequestException('Cannot move food to an inactive category.');
        }
        return this.prisma.foodItem.update({
            where: { id },
            data: { ...data, isVeg: true },
        });
    }
    async remove(id) {
        const existing = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
        if (!existing)
            throw new common_1.NotFoundException('Food item not found');
        return this.prisma.foodItem.update({
            where: { id },
            data: { deletedAt: new Date(), isActive: false },
        });
    }
    async toggleActive(id) {
        const food = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
        if (!food)
            throw new common_1.NotFoundException('Food item not found');
        return this.prisma.foodItem.update({
            where: { id },
            data: { isActive: !food.isActive },
        });
    }
    async toggleBestseller(id) {
        const food = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
        if (!food)
            throw new common_1.NotFoundException('Food item not found');
        return this.prisma.foodItem.update({
            where: { id },
            data: { isBestseller: !food.isBestseller },
        });
    }
    async getCustomizationGroups(foodItemId) {
        const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId, deletedAt: null } });
        if (!food)
            throw new common_1.NotFoundException('Food item not found');
        return this.prisma.customizationGroup.findMany({
            where: { foodItemId },
            include: { items: { orderBy: { displayOrder: 'asc' } } },
            orderBy: { displayOrder: 'asc' },
        });
    }
    async createCustomizationGroup(foodItemId, data) {
        const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId, deletedAt: null } });
        if (!food)
            throw new common_1.NotFoundException('Food item not found');
        const maxOrder = await this.prisma.customizationGroup.aggregate({
            where: { foodItemId },
            _max: { displayOrder: true },
        });
        return this.prisma.customizationGroup.create({
            data: {
                foodItemId,
                name: data.name,
                minSelections: data.minSelections ?? 0,
                maxSelections: data.maxSelections ?? 1,
                displayOrder: data.displayOrder ?? (maxOrder._max.displayOrder ?? 0) + 1,
                isActive: data.isActive !== false,
            },
        });
    }
    async updateCustomizationGroup(groupId, data) {
        const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
        if (!group)
            throw new common_1.NotFoundException('Customization group not found');
        if (data.minSelections !== undefined && data.maxSelections !== undefined) {
            if (data.minSelections > data.maxSelections) {
                throw new common_1.BadRequestException('minSelections cannot be greater than maxSelections');
            }
        }
        return this.prisma.customizationGroup.update({ where: { id: groupId }, data });
    }
    async deleteCustomizationGroup(groupId) {
        const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
        if (!group)
            throw new common_1.NotFoundException('Customization group not found');
        await this.prisma.customizationGroup.delete({ where: { id: groupId } });
        return { message: 'Customization group deleted' };
    }
    async createCustomizationItem(groupId, data) {
        const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
        if (!group)
            throw new common_1.NotFoundException('Customization group not found');
        if (data.additionalPrice !== undefined && data.additionalPrice < 0) {
            throw new common_1.BadRequestException('Additional price cannot be negative.');
        }
        const maxOrder = await this.prisma.customizationItem.aggregate({
            where: { groupId },
            _max: { displayOrder: true },
        });
        return this.prisma.customizationItem.create({
            data: {
                groupId,
                name: data.name,
                additionalPrice: data.additionalPrice ?? 0,
                displayOrder: data.displayOrder ?? (maxOrder._max.displayOrder ?? 0) + 1,
            },
        });
    }
    async updateCustomizationItem(itemId, data) {
        const item = await this.prisma.customizationItem.findUnique({ where: { id: itemId } });
        if (!item)
            throw new common_1.NotFoundException('Customization item not found');
        if (data.additionalPrice !== undefined && data.additionalPrice < 0) {
            throw new common_1.BadRequestException('Additional price cannot be negative.');
        }
        return this.prisma.customizationItem.update({ where: { id: itemId }, data });
    }
    async deleteCustomizationItem(itemId) {
        const item = await this.prisma.customizationItem.findUnique({ where: { id: itemId } });
        if (!item)
            throw new common_1.NotFoundException('Customization item not found');
        await this.prisma.customizationItem.delete({ where: { id: itemId } });
        return { message: 'Customization item deleted' };
    }
};
exports.FoodsService = FoodsService;
exports.FoodsService = FoodsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FoodsService);
//# sourceMappingURL=foods.service.js.map