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
exports.CategoriesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../config/prisma.service");
let CategoriesService = class CategoriesService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAllActive() {
        return this.prisma.category.findMany({
            where: { isActive: true },
            orderBy: { displayOrder: 'asc' },
        });
    }
    async findAll() {
        return this.prisma.category.findMany({
            orderBy: { displayOrder: 'asc' },
            include: { _count: { select: { foodItems: { where: { deletedAt: null } } } } },
        });
    }
    async findOne(id) {
        const category = await this.prisma.category.findUnique({ where: { id } });
        if (!category)
            throw new common_1.NotFoundException('Category not found');
        return category;
    }
    async create(data) {
        const existing = await this.prisma.category.findFirst({ where: { name: data.name } });
        if (existing)
            throw new common_1.ConflictException('Category with this name already exists');
        const maxOrder = await this.prisma.category.aggregate({ _max: { displayOrder: true } });
        return this.prisma.category.create({
            data: {
                name: data.name,
                icon: data.icon ?? '',
                displayOrder: data.displayOrder ?? (maxOrder._max.displayOrder ?? 0) + 1,
                imageUrl: data.imageUrl || null,
                description: data.description || null,
                isFeatured: data.isFeatured === true,
            },
        });
    }
    async update(id, data) {
        await this.findOne(id);
        if (data.name) {
            const existing = await this.prisma.category.findFirst({
                where: { name: data.name, id: { not: id } },
            });
            if (existing)
                throw new common_1.ConflictException('Category with this name already exists');
        }
        return this.prisma.category.update({ where: { id }, data });
    }
    async reorder(items) {
        const operations = items.map((item) => this.prisma.category.update({
            where: { id: item.id },
            data: { displayOrder: item.displayOrder },
        }));
        await this.prisma.$transaction(operations);
        return { message: 'Categories reordered successfully' };
    }
    async deactivate(id) {
        const category = await this.findOne(id);
        if (!category.isActive)
            throw new common_1.BadRequestException('Category is already inactive');
        const foodCount = await this.prisma.foodItem.count({
            where: { categoryId: id, deletedAt: null, isActive: true },
        });
        if (foodCount > 0) {
            throw new common_1.BadRequestException(`Cannot deactivate category: ${foodCount} active food item(s) still belong to it. Deactivate or reassign them first.`);
        }
        return this.prisma.category.update({
            where: { id },
            data: { isActive: false },
        });
    }
    async activate(id) {
        const category = await this.findOne(id);
        if (category.isActive)
            throw new common_1.BadRequestException('Category is already active');
        return this.prisma.category.update({
            where: { id },
            data: { isActive: true },
        });
    }
    async remove(id) {
        await this.findOne(id);
        const foodCount = await this.prisma.foodItem.count({ where: { categoryId: id } });
        if (foodCount > 0) {
            throw new common_1.BadRequestException(`Cannot delete category: ${foodCount} food item(s) still belong to it. Reassign them first.`);
        }
        const shortCount = await this.prisma.short.count({ where: { categoryId: id } });
        if (shortCount > 0) {
            throw new common_1.BadRequestException(`Cannot delete category: ${shortCount} short(s) still link to it.`);
        }
        await this.prisma.category.delete({ where: { id } });
        return { message: 'Category deleted' };
    }
};
exports.CategoriesService = CategoriesService;
exports.CategoriesService = CategoriesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], CategoriesService);
//# sourceMappingURL=categories.service.js.map