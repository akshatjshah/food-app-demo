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
exports.ChefsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const chefs_service_1 = require("./chefs.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../auth/guards/roles.guard");
const roles_decorator_1 = require("../../guards/roles.decorator");
const client_1 = require("@prisma/client");
let ChefsController = class ChefsController {
    constructor(chefsService) {
        this.chefsService = chefsService;
    }
    async getDashboard(req) {
        return this.chefsService.getDashboard(req.user.id);
    }
    async getOrders(req, status) {
        return this.chefsService.getOrders(req.user.id, status);
    }
    async acceptOrder(orderId, req) {
        return this.chefsService.acceptOrder(orderId, req.user.id);
    }
    async startPreparing(orderId, req) {
        return this.chefsService.startPreparing(orderId, req.user.id);
    }
    async markReady(orderId, req) {
        return this.chefsService.markReady(orderId, req.user.id);
    }
    async toggleStock(foodItemId) {
        return this.chefsService.toggleFoodStock(foodItemId);
    }
};
exports.ChefsController = ChefsController;
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)('dashboard'),
    (0, swagger_1.ApiOperation)({ summary: 'Get chef dashboard stats' }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "getDashboard", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)('orders'),
    (0, swagger_1.ApiOperation)({ summary: 'Get chef orders' }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "getOrders", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('orders/:orderId/accept'),
    (0, swagger_1.ApiOperation)({ summary: 'Accept order' }),
    __param(0, (0, common_1.Param)('orderId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "acceptOrder", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('orders/:orderId/start'),
    (0, swagger_1.ApiOperation)({ summary: 'Start preparing order' }),
    __param(0, (0, common_1.Param)('orderId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "startPreparing", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('orders/:orderId/ready'),
    (0, swagger_1.ApiOperation)({ summary: 'Mark order as ready' }),
    __param(0, (0, common_1.Param)('orderId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "markReady", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.chef),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)('foods/:foodItemId/stock'),
    (0, swagger_1.ApiOperation)({ summary: 'Toggle food stock' }),
    __param(0, (0, common_1.Param)('foodItemId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ChefsController.prototype, "toggleStock", null);
exports.ChefsController = ChefsController = __decorate([
    (0, swagger_1.ApiTags)('Chefs'),
    (0, common_1.Controller)('chefs'),
    __metadata("design:paramtypes", [chefs_service_1.ChefsService])
], ChefsController);
//# sourceMappingURL=chefs.controller.js.map