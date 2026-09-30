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
exports.ShortsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let ShortsService = class ShortsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(params) {
        const where = { isActive: true };
        if (params?.categoryId)
            where.categoryId = params.categoryId;
        return this.prisma.short.findMany({
            where,
            include: {
                foodItem: { select: { id: true, name: true, price: true, imageUrls: true } },
                category: { select: { id: true, name: true } },
            },
            orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
            skip: params?.skip || 0,
            take: params?.take || 20,
        });
    }
    async toggleLike(userId, shortId) {
        const existing = await this.prisma.foodShortLike.findUnique({
            where: { userId_shortId: { userId, shortId } },
        });
        if (existing) {
            await this.prisma.foodShortLike.delete({ where: { id: existing.id } });
            await this.prisma.short.update({ where: { id: shortId }, data: { likesCount: { decrement: 1 } } });
            return { liked: false };
        }
        await this.prisma.foodShortLike.create({ data: { userId, shortId } });
        await this.prisma.short.update({ where: { id: shortId }, data: { likesCount: { increment: 1 } } });
        return { liked: true };
    }
    async incrementViews(shortId) {
        await this.prisma.short.update({ where: { id: shortId }, data: { viewsCount: { increment: 1 } } });
    }
    async findAllAdmin() {
        return this.prisma.short.findMany({
            include: {
                foodItem: { select: { id: true, name: true } },
                category: { select: { id: true, name: true } },
            },
            orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
            take: 100,
        });
    }
    async create(data) {
        if (!data.videoUrl || !data.thumbnailUrl) {
            throw new common_1.BadRequestException('videoUrl and thumbnailUrl are required');
        }
        return this.prisma.short.create({
            data: {
                videoUrl: data.videoUrl,
                thumbnailUrl: data.thumbnailUrl,
                caption: data.caption || null,
                foodItemId: data.foodItemId || null,
                categoryId: data.categoryId || null,
                isActive: data.isActive !== false,
                displayOrder: data.displayOrder ?? 0,
            },
        });
    }
    async update(id, data) {
        const existing = await this.prisma.short.findUnique({ where: { id } });
        if (!existing)
            throw new common_1.BadRequestException('Short not found');
        return this.prisma.short.update({
            where: { id },
            data: {
                ...(data.videoUrl !== undefined ? { videoUrl: data.videoUrl } : {}),
                ...(data.thumbnailUrl !== undefined ? { thumbnailUrl: data.thumbnailUrl } : {}),
                ...(data.caption !== undefined ? { caption: data.caption || null } : {}),
                ...(data.foodItemId !== undefined ? { foodItemId: data.foodItemId || null } : {}),
                ...(data.categoryId !== undefined ? { categoryId: data.categoryId || null } : {}),
                ...(data.isActive !== undefined ? { isActive: data.isActive } : {}),
                ...(data.displayOrder !== undefined ? { displayOrder: data.displayOrder } : {}),
            },
        });
    }
    async remove(id) {
        return this.prisma.short.delete({ where: { id } });
    }
};
exports.ShortsService = ShortsService;
exports.ShortsService = ShortsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ShortsService);
//# sourceMappingURL=shorts.service.js.map