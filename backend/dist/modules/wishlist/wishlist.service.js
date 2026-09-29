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
exports.WishlistService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let WishlistService = class WishlistService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(userId) {
        const items = await this.prisma.wishlist.findMany({
            where: { userId },
            include: {
                foodItem: {
                    select: { id: true, name: true, price: true, imageUrls: true, rating: true, isVeg: true },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
        return items.map((w) => ({
            ...w,
            foodItem: w.foodItem
                ? {
                    ...w.foodItem,
                    price: Number(w.foodItem.price),
                    rating: w.foodItem.rating === null ||
                        w.foodItem.rating === undefined
                        ? null
                        : Number(w.foodItem.rating),
                }
                : w.foodItem,
        }));
    }
    async toggle(userId, foodItemId) {
        const existing = await this.prisma.wishlist.findUnique({
            where: { userId_foodItemId: { userId, foodItemId } },
        });
        if (existing) {
            await this.prisma.wishlist.delete({ where: { id: existing.id } });
            return { added: false };
        }
        await this.prisma.wishlist.create({ data: { userId, foodItemId } });
        return { added: true };
    }
};
exports.WishlistService = WishlistService;
exports.WishlistService = WishlistService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], WishlistService);
//# sourceMappingURL=wishlist.service.js.map