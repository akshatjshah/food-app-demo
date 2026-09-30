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
var SettingsController_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SettingsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const settings_service_1 = require("./settings.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../auth/guards/roles.guard");
const roles_decorator_1 = require("../../guards/roles.decorator");
const public_decorator_1 = require("../../guards/public.decorator");
const client_1 = require("@prisma/client");
let SettingsController = SettingsController_1 = class SettingsController {
    constructor(settingsService) {
        this.settingsService = settingsService;
    }
    async getPublic(key) {
        if (!SettingsController_1.PUBLIC_KEYS.has(key)) {
            throw new (require('@nestjs/common').ForbiddenException)('Setting is not public');
        }
        return this.settingsService.get(key);
    }
    async getAllPublic() {
        const all = await this.settingsService.getAll();
        return all.filter((s) => SettingsController_1.PUBLIC_KEYS.has(s.key));
    }
    async get(key) {
        return this.settingsService.get(key);
    }
    async getAll() {
        return this.settingsService.getAll();
    }
    async set(body) {
        return this.settingsService.set(body.key, body.value, body.valueType, body.description);
    }
    async delete(key) {
        return this.settingsService.delete(key);
    }
};
exports.SettingsController = SettingsController;
SettingsController.PUBLIC_KEYS = new Set([
    'delivery_fee',
    'min_order_value',
    'platform_fee',
    'tax_rate',
    'business_hours',
    'support_phone',
    'support_email',
    'service_availability',
    'cod_enabled',
    'razorpay_enabled',
    'app_notice',
    'cancellation_policy',
    'delivery_info',
    'about_us',
    'contact_info',
    'faq',
    'terms_display',
    'home_promo_text',
    'subscription_promo_text',
]);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('public/:key'),
    (0, swagger_1.ApiOperation)({ summary: 'Get public setting by key' }),
    __param(0, (0, common_1.Param)('key')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getPublic", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('public'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all public settings' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getAllPublic", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)(':key'),
    (0, swagger_1.ApiOperation)({ summary: 'Get setting by key (admin)' }),
    __param(0, (0, common_1.Param)('key')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "get", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all settings (admin)' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getAll", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Set setting (admin)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "set", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.admin),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)(':key'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete setting (admin)' }),
    __param(0, (0, common_1.Param)('key')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "delete", null);
exports.SettingsController = SettingsController = SettingsController_1 = __decorate([
    (0, swagger_1.ApiTags)('Settings'),
    (0, common_1.Controller)('settings'),
    __metadata("design:paramtypes", [settings_service_1.SettingsService])
], SettingsController);
//# sourceMappingURL=settings.controller.js.map