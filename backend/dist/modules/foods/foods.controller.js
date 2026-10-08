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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FoodsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const foods_service_1 = require("./foods.service");
const create_food_dto_1 = require("./dto/create-food.dto");
const update_food_dto_1 = require("./dto/update-food.dto");
const create_customization_group_dto_1 = require("./dto/create-customization-group.dto");
const update_customization_group_dto_1 = require("./dto/update-customization-group.dto");
const create_customization_item_dto_1 = require("./dto/create-customization-item.dto");
const update_customization_item_dto_1 = require("./dto/update-customization-item.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../auth/guards/roles.guard");
const roles_decorator_1 = require("../../guards/roles.decorator");
const public_decorator_1 = require("../../guards/public.decorator");
const client_1 = require("@prisma/client");
let FoodsController = class FoodsController {
    constructor(foodsService) {
        this.foodsService = foodsService;
    }
    async findAll(categoryId, search, subcategory, isVeg, isJainAvailable, isFastingFriendly, isBestseller, isFeatured, isHealthyPick, isAvailable, mealTag, hasCustomization, minPrice, maxPrice, sort, skip, take) {
        const bool = (v) => (v !== undefined ? v === 'true' : undefined);
        return this.foodsService.findAll({
            categoryId,
            subcategory,
            search,
            isVeg: bool(isVeg),
            isJainAvailable: bool(isJainAvailable),
            isFastingFriendly: bool(isFastingFriendly),
            isBestseller: bool(isBestseller),
            isFeatured: bool(isFeatured),
            isHealthyPick: bool(isHealthyPick),
            isAvailable: bool(isAvailable),
            mealTag,
            hasCustomization: hasCustomization !== undefined ? hasCustomization === 'true' : undefined,
            minPrice: minPrice ? parseFloat(minPrice) : undefined,
            maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
            sort,
            skip: skip ? parseInt(skip) : 0,
            take: take ? parseInt(take) : 50,
        });
    }
    async findSpecials() {
        return this.foodsService.findSpecials();
    }
    async findOne(id) {
        return this.foodsService.findOne(id);
    }
    async findAllAdmin(categoryId, subcategory, search, isActive, isAvailable, isFeatured, isBestseller, mealTag, hasCustomization, minPrice, maxPrice, sort, skip, take) {
        const bool = (v) => (v !== undefined && v !== '' ? v === 'true' : undefined);
        return this.foodsService.findAll({
            categoryId,
            subcategory,
            search,
            isActive: bool(isActive),
            isAvailable: bool(isAvailable),
            isFeatured: bool(isFeatured),
            isBestseller: bool(isBestseller),
            mealTag,
            hasCustomization: hasCustomization !== undefined && hasCustomization !== '' ? hasCustomization === 'true' : undefined,
            minPrice: minPrice ? parseFloat(minPrice) : undefined,
            maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
            sort,
            skip: skip ? parseInt(skip) : 0,
            take: take ? parseInt(take) : 500,
            includeInactive: true,
        });
    }
    async create(dto) {
        return this.foodsService.create(dto);
    }
    async update(id, dto) {
        return this.foodsService.update(id, dto);
    }
    async remove(id) {
        return this.foodsService.remove(id);
    }
    async toggleActive(id) {
        return this.foodsService.toggleActive(id);
    }
    async toggleBestseller(id) {
        return this.foodsService.toggleBestseller(id);
    }
    async getCustomizationGroups(foodItemId) {
        return this.foodsService.getCustomizationGroups(foodItemId);
    }
    async createCustomizationGroup(foodItemId, dto) {
        return this.foodsService.createCustomizationGroup(foodItemId, dto);
    }
    async updateCustomizationGroup(groupId, dto) {
        return this.foodsService.updateCustomizationGroup(groupId, dto);
    }
    async deleteCustomizationGroup(groupId) {
        return this.foodsService.deleteCustomizationGroup(groupId);
    }
    async createCustomizationItem(groupId, dto) {
        return this.foodsService.createCustomizationItem(groupId, dto);
    }
    async updateCustomizationItem(itemId, dto) {
        return this.foodsService.updateCustomizationItem(itemId, dto);
    }
    async deleteCustomizationItem(itemId) {
        return this.foodsService.deleteCustomizationItem(itemId);
    }
};
exports.FoodsController = FoodsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get available food items (public)' }),
    (0, swagger_1.ApiQuery)({ name: 'categoryId', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'subcategory', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'search', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isVeg', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isJainAvailable', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isFastingFriendly', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isBestseller', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isFeatured', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isHealthyPick', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isAvailable', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'mealTag', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'hasCustomization', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'minPrice', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'maxPrice', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'sort', required: false, description: 'recommended|popular|priceAsc|priceDesc|nameAsc' }),
    (0, swagger_1.ApiQuery)({ name: 'skip', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'take', required: false }),
    __param(0, (0, common_1.Query)('categoryId')),
    __param(1, (0, common_1.Query)('search')),
    __param(2, (0, common_1.Query)('subcategory')),
    __param(3, (0, common_1.Query)('isVeg')),
    __param(4, (0, common_1.Query)('isJainAvailable')),
    __param(5, (0, common_1.Query)('isFastingFriendly')),
    __param(6, (0, common_1.Query)('isBestseller')),
    __param(7, (0, common_1.Query)('isFeatured')),
    __param(8, (0, common_1.Query)('isHealthyPick')),
    __param(9, (0, common_1.Query)('isAvailable')),
    __param(10, (0, common_1.Query)('mealTag')),
    __param(11, (0, common_1.Query)('hasCustomization')),
    __param(12, (0, common_1.Query)('minPrice')),
    __param(13, (0, common_1.Query)('maxPrice')),
    __param(14, (0, common_1.Query)('sort')),
    __param(15, (0, common_1.Query)('skip')),
    __param(16, (0, common_1.Query)('take')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "findAll", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('specials'),
    (0, swagger_1.ApiOperation)({ summary: 'Get today\'s special dishes (public)' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "findSpecials", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get food item details with customizations (public)' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "findOne", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)('admin/all'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all food items including inactive (admin/chef)' }),
    (0, swagger_1.ApiQuery)({ name: 'categoryId', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'subcategory', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'search', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isActive', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isAvailable', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isFeatured', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'isBestseller', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'mealTag', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'hasCustomization', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'minPrice', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'maxPrice', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'sort', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'skip', required: false }),
    (0, swagger_1.ApiQuery)({ name: 'take', required: false }),
    __param(0, (0, common_1.Query)('categoryId')),
    __param(1, (0, common_1.Query)('subcategory')),
    __param(2, (0, common_1.Query)('search')),
    __param(3, (0, common_1.Query)('isActive')),
    __param(4, (0, common_1.Query)('isAvailable')),
    __param(5, (0, common_1.Query)('isFeatured')),
    __param(6, (0, common_1.Query)('isBestseller')),
    __param(7, (0, common_1.Query)('mealTag')),
    __param(8, (0, common_1.Query)('hasCustomization')),
    __param(9, (0, common_1.Query)('minPrice')),
    __param(10, (0, common_1.Query)('maxPrice')),
    __param(11, (0, common_1.Query)('sort')),
    __param(12, (0, common_1.Query)('skip')),
    __param(13, (0, common_1.Query)('take')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String, String, String, String, String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "findAllAdmin", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Create food item (admin/chef)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_food_dto_1.CreateFoodDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "create", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Update food item (admin/chef)' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_food_dto_1.UpdateFoodDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "update", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete food item (admin only)' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "remove", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)(':id/toggle-active'),
    (0, swagger_1.ApiOperation)({ summary: 'Toggle food item availability (admin/chef)' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "toggleActive", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)(':id/toggle-bestseller'),
    (0, swagger_1.ApiOperation)({ summary: 'Toggle bestseller/special status (admin)' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "toggleBestseller", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)(':foodItemId/customizations'),
    (0, swagger_1.ApiOperation)({ summary: 'Get customization groups for food item (admin/chef)' }),
    __param(0, (0, common_1.Param)('foodItemId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "getCustomizationGroups", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)(':foodItemId/customizations'),
    (0, swagger_1.ApiOperation)({ summary: 'Create customization group (admin/chef)' }),
    __param(0, (0, common_1.Param)('foodItemId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_customization_group_dto_1.CreateCustomizationGroupDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "createCustomizationGroup", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)('customizations/groups/:groupId'),
    (0, swagger_1.ApiOperation)({ summary: 'Update customization group (admin/chef)' }),
    __param(0, (0, common_1.Param)('groupId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_customization_group_dto_1.UpdateCustomizationGroupDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "updateCustomizationGroup", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)('customizations/groups/:groupId'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete customization group (admin only)' }),
    __param(0, (0, common_1.Param)('groupId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "deleteCustomizationGroup", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('customizations/groups/:groupId/items'),
    (0, swagger_1.ApiOperation)({ summary: 'Create customization option (admin/chef)' }),
    __param(0, (0, common_1.Param)('groupId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_customization_item_dto_1.CreateCustomizationItemDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "createCustomizationItem", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin, client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)('customizations/items/:itemId'),
    (0, swagger_1.ApiOperation)({ summary: 'Update customization option (admin/chef)' }),
    __param(0, (0, common_1.Param)('itemId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_customization_item_dto_1.UpdateCustomizationItemDto]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "updateCustomizationItem", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)('customizations/items/:itemId'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete customization option (admin only)' }),
    __param(0, (0, common_1.Param)('itemId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FoodsController.prototype, "deleteCustomizationItem", null);
exports.FoodsController = FoodsController = __decorate([
    (0, swagger_1.ApiTags)('Foods'),
    (0, common_1.Controller)('foods'),
    __metadata("design:paramtypes", [foods_service_1.FoodsService])
], FoodsController);
//# sourceMappingURL=foods.controller.js.map