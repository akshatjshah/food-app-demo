"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const throttler_1 = require("@nestjs/throttler");
const core_1 = require("@nestjs/core");
const prisma_module_1 = require("./config/prisma.module");
const auth_module_1 = require("./modules/auth/auth.module");
const users_module_1 = require("./modules/users/users.module");
const categories_module_1 = require("./modules/categories/categories.module");
const foods_module_1 = require("./modules/foods/foods.module");
const cart_module_1 = require("./modules/cart/cart.module");
const orders_module_1 = require("./modules/orders/orders.module");
const payments_module_1 = require("./modules/payments/payments.module");
const subscriptions_module_1 = require("./modules/subscriptions/subscriptions.module");
const coupons_module_1 = require("./modules/coupons/coupons.module");
const reviews_module_1 = require("./modules/reviews/reviews.module");
const addresses_module_1 = require("./modules/addresses/addresses.module");
const chefs_module_1 = require("./modules/chefs/chefs.module");
const admin_module_1 = require("./modules/admin/admin.module");
const notifications_module_1 = require("./modules/notifications/notifications.module");
const health_module_1 = require("./modules/health/health.module");
const wishlist_module_1 = require("./modules/wishlist/wishlist.module");
const shorts_module_1 = require("./modules/shorts/shorts.module");
const banners_module_1 = require("./modules/banners/banners.module");
const delivery_slots_module_1 = require("./modules/delivery-slots/delivery-slots.module");
const settings_module_1 = require("./modules/settings/settings.module");
const wallet_module_1 = require("./modules/wallet/wallet.module");
const loyalty_module_1 = require("./modules/loyalty/loyalty.module");
const google_places_module_1 = require("./modules/google-places/google-places.module");
const gateway_module_1 = require("./gateway/gateway.module");
const media_module_1 = require("./modules/media/media.module");
const admin_audit_interceptor_1 = require("./common/audit/admin-audit.interceptor");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            throttler_1.ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]),
            prisma_module_1.PrismaModule,
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            categories_module_1.CategoriesModule,
            foods_module_1.FoodsModule,
            cart_module_1.CartModule,
            orders_module_1.OrdersModule,
            payments_module_1.PaymentsModule,
            subscriptions_module_1.SubscriptionsModule,
            coupons_module_1.CouponsModule,
            reviews_module_1.ReviewsModule,
            addresses_module_1.AddressesModule,
            chefs_module_1.ChefsModule,
            admin_module_1.AdminModule,
            notifications_module_1.NotificationsModule,
            health_module_1.HealthModule,
            wishlist_module_1.WishlistModule,
            shorts_module_1.ShortsModule,
            banners_module_1.BannersModule,
            delivery_slots_module_1.DeliverySlotsModule,
            settings_module_1.SettingsModule,
            wallet_module_1.WalletModule,
            loyalty_module_1.LoyaltyModule,
            google_places_module_1.GooglePlacesModule,
            gateway_module_1.GatewayModule,
            media_module_1.MediaModule,
        ],
        providers: [
            {
                provide: core_1.APP_GUARD,
                useClass: throttler_1.ThrottlerGuard,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: admin_audit_interceptor_1.AdminAuditInterceptor,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map