import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { PrismaModule } from './config/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { FoodsModule } from './modules/foods/foods.module';
import { CartModule } from './modules/cart/cart.module';
import { OrdersModule } from './modules/orders/orders.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { CouponsModule } from './modules/coupons/coupons.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { AddressesModule } from './modules/addresses/addresses.module';
import { ChefsModule } from './modules/chefs/chefs.module';
import { AdminModule } from './modules/admin/admin.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { HealthModule } from './modules/health/health.module';
import { WishlistModule } from './modules/wishlist/wishlist.module';
import { ShortsModule } from './modules/shorts/shorts.module';
import { BannersModule } from './modules/banners/banners.module';
import { DeliverySlotsModule } from './modules/delivery-slots/delivery-slots.module';
import { SettingsModule } from './modules/settings/settings.module';
import { WalletModule } from './modules/wallet/wallet.module';
import { LoyaltyModule } from './modules/loyalty/loyalty.module';
import { GooglePlacesModule } from './modules/google-places/google-places.module';
import { GatewayModule } from './gateway/gateway.module';
import { MediaModule } from './modules/media/media.module';
import { AdminAuditInterceptor } from './common/audit/admin-audit.interceptor';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]),
    PrismaModule,
    AuthModule,
    UsersModule,
    CategoriesModule,
    FoodsModule,
    CartModule,
    OrdersModule,
    PaymentsModule,
    SubscriptionsModule,
    CouponsModule,
    ReviewsModule,
    AddressesModule,
    ChefsModule,
    AdminModule,
    NotificationsModule,
    HealthModule,
    WishlistModule,
    ShortsModule,
    BannersModule,
    DeliverySlotsModule,
    SettingsModule,
    WalletModule,
    LoyaltyModule,
    GooglePlacesModule,
    GatewayModule,
    MediaModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: AdminAuditInterceptor,
    },
  ],
})
export class AppModule {}
