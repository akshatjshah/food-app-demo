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
var NotificationsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../../config/prisma.service");
const app_1 = require("firebase-admin/app");
const messaging_1 = require("firebase-admin/messaging");
let NotificationsService = NotificationsService_1 = class NotificationsService {
    constructor(prisma, config) {
        this.prisma = prisma;
        this.config = config;
        this.logger = new common_1.Logger(NotificationsService_1.name);
        this.firebaseApp = null;
    }
    onModuleInit() {
        this.initializeFirebase();
    }
    initializeFirebase() {
        const projectId = this.config.get('FIREBASE_PROJECT_ID');
        const privateKey = this.config.get('FIREBASE_PRIVATE_KEY');
        const clientEmail = this.config.get('FIREBASE_CLIENT_EMAIL');
        if (projectId && privateKey && clientEmail) {
            this.firebaseApp = (0, app_1.initializeApp)({
                credential: (0, app_1.cert)({
                    projectId,
                    privateKey: privateKey.replace(/\\n/g, '\n'),
                    clientEmail,
                }),
            });
            this.logger.log('Firebase Admin initialized with service account credentials');
        }
        else {
            this.logger.warn('Firebase credentials not configured. FCM push notifications will be disabled. ' +
                'Set FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL env vars.');
        }
    }
    toPublic(n) {
        return {
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            reference_id: n.referenceId,
            is_read: n.isRead,
            created_at: n.createdAt,
        };
    }
    async findAll(userId, params) {
        const items = await this.prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            skip: params?.skip || 0,
            take: params?.take || 20,
        });
        return items.map((n) => this.toPublic(n));
    }
    async markRead(id, userId) {
        const existing = await this.prisma.notification.findFirst({
            where: { id, userId },
        });
        if (!existing) {
            throw new common_1.NotFoundException('Notification not found');
        }
        const updated = await this.prisma.notification.update({
            where: { id },
            data: { isRead: true },
        });
        return this.toPublic(updated);
    }
    async markAllRead(userId) {
        await this.prisma.notification.updateMany({
            where: { userId, isRead: false },
            data: { isRead: true },
        });
        return { message: 'All notifications marked as read' };
    }
    async create(userId, data) {
        const created = await this.prisma.notification.create({ data: { userId, ...data } });
        return this.toPublic(created);
    }
    async notify(userId, data) {
        try {
            const created = await this.prisma.notification.create({
                data: { userId, ...data },
            });
            await this.sendPushNotification(userId, data.title, data.body, {
                type: data.type,
                referenceId: data.referenceId || '',
            });
            return this.toPublic(created);
        }
        catch (error) {
            this.logger.warn(`Failed to create notification for user ${userId}: ${error.message}`);
            return null;
        }
    }
    async getUnreadCount(userId) {
        const count = await this.prisma.notification.count({
            where: { userId, isRead: false },
        });
        return { count };
    }
    async removeAll(userId) {
        const result = await this.prisma.notification.deleteMany({
            where: { userId },
        });
        return { message: 'All notifications removed', count: result.count };
    }
    async sendPushNotification(userId, title, body, data) {
        if (!this.firebaseApp) {
            this.logger.debug('Firebase not initialized. Skipping push notification.');
            return false;
        }
        try {
            const tokens = await this.prisma.fcmToken.findMany({
                where: { userId, isActive: true },
                select: { token: true },
            });
            if (tokens.length === 0) {
                this.logger.debug(`No active FCM tokens for user ${userId}. Skipping push notification.`);
                return false;
            }
            const messaging = (0, messaging_1.getMessaging)(this.firebaseApp);
            const tokenList = tokens.map((t) => t.token);
            const response = await messaging.sendEachForMulticast({
                tokens: tokenList,
                notification: { title, body },
                data: data || {},
                android: { priority: 'high' },
                apns: { payload: { aps: { sound: 'default' } } },
            });
            const failedTokens = [];
            response.responses.forEach((res, idx) => {
                if (!res.success) {
                    failedTokens.push(tokenList[idx]);
                    this.logger.warn(`FCM send failed for token: ${res.error?.message}`);
                }
            });
            if (failedTokens.length > 0) {
                await this.prisma.fcmToken.updateMany({
                    where: { token: { in: failedTokens } },
                    data: { isActive: false },
                });
            }
            this.logger.log(`Push notification sent to user ${userId}: ${response.successCount}/${tokenList.length} succeeded`);
            return response.successCount > 0;
        }
        catch (error) {
            this.logger.error(`Failed to send push notification to user ${userId}: ${error.message}`);
            return false;
        }
    }
    orderStatusContent(status, orderLabel) {
        const short = orderLabel.slice(0, 8).toUpperCase();
        switch (status) {
            case 'placed':
                return { title: 'Order Placed', body: `Your order #${short} has been placed successfully.`, type: 'ORDER_PLACED' };
            case 'pending_payment':
                return { title: 'Payment Pending', body: `Your order #${short} is waiting for payment.`, type: 'PAYMENT_PENDING' };
            case 'confirmed':
                return { title: 'Order Confirmed', body: `Your order #${short} has been confirmed and will be prepared soon.`, type: 'ORDER_CONFIRMED' };
            case 'preparing':
                return { title: 'Order Being Prepared', body: `Your order #${short} is being prepared fresh for you.`, type: 'ORDER_PREPARING' };
            case 'ready':
                return { title: 'Order Ready', body: `Your order #${short} is ready and will be picked up shortly.`, type: 'ORDER_READY' };
            case 'rider_assigned':
                return { title: 'Delivery Partner Assigned', body: `A delivery partner has been assigned to your order #${short}.`, type: 'DELIVERY_UPDATE' };
            case 'picked_up':
            case 'out_for_delivery':
                return { title: 'Out for Delivery', body: `Your order #${short} is on its way to you!`, type: 'ORDER_ON_WAY' };
            case 'delivered':
                return { title: 'Order Delivered', body: `Your order #${short} has been delivered. Enjoy your meal!`, type: 'ORDER_DELIVERED' };
            case 'cancelled':
                return { title: 'Order Cancelled', body: `Your order #${short} has been cancelled.`, type: 'ORDER_CANCELLED' };
            case 'rejected':
                return { title: 'Order Not Accepted', body: `Your order #${short} could not be accepted. Please try again.`, type: 'ORDER_CANCELLED' };
            default:
                return { title: 'Order Update', body: `Your order #${short} status: ${status}.`, type: 'ORDER_UPDATE' };
        }
    }
    async sendOrderStatusUpdate(userId, orderId, status) {
        const message = this.orderStatusContent(status, orderId);
        await this.notify(userId, {
            title: message.title,
            body: message.body,
            type: message.type,
            referenceId: orderId,
        });
    }
    async sendPaymentUpdate(userId, orderId, outcome, amount) {
        const amountText = amount !== undefined ? ` of ₹${amount}` : '';
        const content = outcome === 'paid'
            ? { title: 'Payment Successful', body: `Payment${amountText} for your order was successful.`, type: 'PAYMENT_SUCCESS' }
            : outcome === 'refunded'
                ? { title: 'Refund Initiated', body: `A refund${amountText} for your order has been initiated.`, type: 'PAYMENT_REFUNDED' }
                : { title: 'Payment Failed', body: `Payment${amountText} for your order failed. Please try again.`, type: 'PAYMENT_FAILED' };
        await this.notify(userId, { ...content, referenceId: orderId });
    }
    async sendSubscriptionUpdate(userId, action, planName, referenceId) {
        const titles = {
            created: 'Subscription Activated',
            paused: 'Subscription Paused',
            resumed: 'Subscription Resumed',
            skipped: 'Meal Skipped',
            cancelled: 'Subscription Cancelled',
            renewed: 'Subscription Renewed',
        };
        await this.notify(userId, {
            title: titles[action] || 'Subscription Update',
            body: action === 'created'
                ? `Your "${planName}" subscription is now active.`
                : action === 'skipped'
                    ? `You skipped a meal on your "${planName}" subscription.`
                    : `Your "${planName}" subscription: ${action}.`,
            type: 'SUBSCRIPTION_UPDATE',
            referenceId,
        });
    }
    async sendAnnouncement(userId, title, body, type = 'ANNOUNCEMENT', referenceId) {
        await this.notify(userId, { title, body, type, referenceId });
    }
    async sendBulkNotification(userIds, title, body, type = 'ANNOUNCEMENT', referenceId) {
        let sent = 0;
        let failed = 0;
        for (const userId of userIds) {
            try {
                await this.prisma.notification.create({ data: { userId, title, body, type, referenceId } });
                sent++;
            }
            catch {
                failed++;
            }
        }
        if (this.firebaseApp) {
            const tokens = await this.prisma.fcmToken.findMany({
                where: { userId: { in: userIds }, isActive: true },
                select: { token: true },
            });
            const validTokens = tokens.map((t) => t.token);
            if (validTokens.length > 0) {
                const messaging = (0, messaging_1.getMessaging)(this.firebaseApp);
                const response = await messaging.sendEachForMulticast({
                    tokens: validTokens,
                    notification: { title, body },
                    android: { priority: 'high' },
                    apns: { payload: { aps: { sound: 'default' } } },
                });
                const failedTokens = [];
                response.responses.forEach((res, idx) => {
                    if (!res.success) {
                        failedTokens.push(validTokens[idx]);
                        this.logger.warn(`FCM multicast failed for token: ${res.error?.message}`);
                    }
                });
                if (failedTokens.length > 0) {
                    await this.prisma.fcmToken.updateMany({
                        where: { token: { in: failedTokens } },
                        data: { isActive: false },
                    });
                }
                this.logger.log(`Bulk push: ${response.successCount} sent, ${response.failureCount} failed`);
            }
        }
        return { sent, failed };
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = NotificationsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map