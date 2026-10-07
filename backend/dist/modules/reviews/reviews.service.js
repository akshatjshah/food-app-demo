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
exports.ReviewsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let ReviewsService = class ReviewsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findByFood(foodItemId) {
        return this.prisma.review.findMany({
            where: { foodItemId, isApproved: true },
            include: { user: { select: { id: true, fullName: true } } },
            orderBy: { createdAt: 'desc' },
        });
    }
    async create(userId, dto) {
        const order = await this.prisma.order.findUnique({ where: { id: dto.orderId } });
        if (!order || order.userId !== userId) {
            throw new common_1.ForbiddenException('You can only review your own orders');
        }
        if (order.status !== 'delivered') {
            throw new common_1.BadRequestException('You can review only after the order is delivered');
        }
        const existing = await this.prisma.review.findFirst({
            where: { userId, orderId: dto.orderId, foodItemId: dto.foodItemId },
        });
        if (existing) {
            throw new common_1.BadRequestException('You have already reviewed this item for this order');
        }
        if (dto.rating < 1 || dto.rating > 5) {
            throw new common_1.BadRequestException('Rating must be between 1 and 5');
        }
        return this.prisma.$transaction(async (tx) => {
            const review = await tx.review.create({
                data: { userId, ...dto },
            });
            const stats = await tx.review.aggregate({
                where: { foodItemId: dto.foodItemId, isApproved: true },
                _avg: { rating: true },
                _count: { rating: true },
            });
            await tx.foodItem.update({
                where: { id: dto.foodItemId },
                data: {
                    rating: Number(stats._avg.rating || 0),
                    reviewsCount: stats._count.rating,
                },
            });
            return review;
        });
    }
    async findAll() {
        return this.prisma.review.findMany({
            include: {
                user: { select: { id: true, fullName: true } },
                foodItem: { select: { id: true, name: true } },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async moderate(id, isApproved) {
        return this.prisma.review.update({ where: { id }, data: { isApproved } });
    }
};
exports.ReviewsService = ReviewsService;
exports.ReviewsService = ReviewsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ReviewsService);
//# sourceMappingURL=reviews.service.js.map