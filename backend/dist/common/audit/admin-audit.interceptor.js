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
exports.AdminAuditInterceptor = void 0;
const common_1 = require("@nestjs/common");
const rxjs_1 = require("rxjs");
const prisma_service_1 = require("../../config/prisma.service");
const SENSITIVE_KEYS = ['password', 'otp', 'token', 'secret', 'hash', 'pin'];
function sanitize(value) {
    if (Array.isArray(value))
        return value.map(sanitize);
    if (value && typeof value === 'object') {
        const out = {};
        for (const [k, v] of Object.entries(value)) {
            out[k] = SENSITIVE_KEYS.some((s) => k.toLowerCase().includes(s)) ? '[REDACTED]' : sanitize(v);
        }
        return out;
    }
    return value;
}
let AdminAuditInterceptor = class AdminAuditInterceptor {
    constructor(prisma) {
        this.prisma = prisma;
    }
    intercept(context, next) {
        const req = context.switchToHttp().getRequest();
        const method = req.method;
        const user = req.user;
        return next.handle().pipe((0, rxjs_1.tap)({
            next: () => {
                if (!user || user.role !== 'admin')
                    return;
                if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(method))
                    return;
                if (req.path?.includes('/auth/') || req.path?.includes('/audit-logs'))
                    return;
                const segments = (req.path || '').split('/').filter(Boolean);
                const entity = segments.length >= 3 ? segments[2] : segments[segments.length - 1] || 'unknown';
                const entityId = req.params?.id || req.params?.orderId || req.params?.groupId || req.params?.itemId || undefined;
                this.prisma.adminAuditLog
                    .create({
                    data: {
                        adminId: user.id,
                        action: `${method.toLowerCase()}`,
                        entity,
                        entityId,
                        newValue: sanitize(req.body ?? {}),
                        ipAddress: req.ip,
                    },
                })
                    .catch(() => {
                });
            },
        }));
    }
};
exports.AdminAuditInterceptor = AdminAuditInterceptor;
exports.AdminAuditInterceptor = AdminAuditInterceptor = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdminAuditInterceptor);
//# sourceMappingURL=admin-audit.interceptor.js.map