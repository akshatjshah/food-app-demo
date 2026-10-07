import { Injectable, Logger, NotFoundException, OnModuleInit, Inject, Optional, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
import { initializeApp, cert, App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { OrderGateway } from '../../gateway/gateway.service';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseApp: App | null = null;

  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
    @Optional()
    @Inject(forwardRef(() => OrderGateway))
    private gateway?: OrderGateway,
  ) {}

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    const projectId = this.config.get<string>('FIREBASE_PROJECT_ID');
    const privateKey = this.config.get<string>('FIREBASE_PRIVATE_KEY');
    const clientEmail = this.config.get<string>('FIREBASE_CLIENT_EMAIL');

    if (projectId && privateKey && clientEmail) {
      this.firebaseApp = initializeApp({
        credential: cert({
          projectId,
          privateKey: privateKey.replace(/\\n/g, '\n'),
          clientEmail,
        }),
      });
      this.logger.log('Firebase Admin initialized with service account credentials');
    } else {
      this.logger.warn(
        'Firebase credentials not configured. FCM push notifications will be disabled. ' +
        'Set FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL env vars.',
      );
    }
  }

  /**
   * Serialize a notification to the public API shape.
   * API JSON keys are snake_case (see AGENTS.md) to match the Flutter client.
   */
  private toPublic(n: {
    id: string;
    title: string;
    body: string;
    type: string;
    referenceId: string | null;
    isRead: boolean;
    createdAt: Date;
  }) {
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

  async findAll(userId: string, params?: { skip?: number; take?: number }) {
    const items = await this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      skip: params?.skip || 0,
      take: params?.take || 20,
    });
    return items.map((n) => this.toPublic(n));
  }

  async markRead(id: string, userId: string) {
    // Customers can only touch their own notifications.
    const existing = await this.prisma.notification.findFirst({
      where: { id, userId },
    });
    if (!existing) {
      throw new NotFoundException('Notification not found');
    }
    const updated = await this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
    return this.toPublic(updated);
  }

  async markAllRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return { message: 'All notifications marked as read' };
  }

  async create(userId: string, data: { title: string; body: string; type: string; referenceId?: string }) {
    const created = await this.prisma.notification.create({ data: { userId, ...data } });
    return this.toPublic(created);
  }

  /**
   * Create an in-app notification and best-effort push it via FCM.
   * Never throws: notifications must not break order/payment flows.
   * When Firebase credentials are missing, only the in-app record is kept
   * (push delivery is NOT faked).
   */
  async notify(
    userId: string,
    data: { title: string; body: string; type: string; referenceId?: string },
  ) {
    try {
      const created = await this.prisma.notification.create({
        data: { userId, ...data },
      });
      const publicNotif = this.toPublic(created);
      // Realtime socket push so an open Home shows the bell popup instantly
      // (FCM + polling are fallbacks, never the only path).
      try {
        this.gateway?.emitNotificationToUser(userId, publicNotif);
      } catch {
        // socket emit is best-effort only
      }
      // FCM data keys must match Flutter's reader (reference_id snake_case).
      // Include title/body in data so background/terminated taps still carry context.
      await this.sendPushNotification(userId, data.title, data.body, {
        type: data.type,
        reference_id: data.referenceId || '',
        title: data.title,
        body: data.body,
      });
      return publicNotif;
    } catch (error) {
      this.logger.warn(`Failed to create notification for user ${userId}: ${error.message}`);
      return null;
    }
  }

  async getUnreadCount(userId: string) {
    const count = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });
    return { count };
  }

  /**
   * Delete ALL notifications belonging to the signed-in customer only.
   * Scoped by userId so other customers are never affected.
   */
  async removeAll(userId: string) {
    const result = await this.prisma.notification.deleteMany({
      where: { userId },
    });
    return { message: 'All notifications removed', count: result.count };
  }

  async sendPushNotification(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
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

      const messaging = getMessaging(this.firebaseApp);
      const tokenList = tokens.map((t) => t.token);

      const response = await messaging.sendEachForMulticast({
        tokens: tokenList,
        notification: { title, body },
        data: data || {},
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      });

      const failedTokens: string[] = [];
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
    } catch (error) {
      this.logger.error(`Failed to send push notification to user ${userId}: ${error.message}`);
      return false;
    }
  }

  private orderStatusContent(status: string, orderLabel: string): { title: string; body: string; type: string } {
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
        // Legacy internal status only (no Ready-for-Pickup step exists in
        // the Parabdi workflow). Surfaced as out-for-delivery copy.
        return { title: 'Out for Delivery', body: `Your order #${short} is on its way to you!`, type: 'ORDER_ON_WAY' };
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
        return { title: 'Order Not Accepted', body: `Your order #${short} could not be accepted. Please try again.`, type: 'ORDER_REJECTED' };
      default:
        return { title: 'Order Update', body: `Your order #${short} status: ${status}.`, type: 'ORDER_UPDATE' };
    }
  }

  async sendOrderStatusUpdate(
    userId: string,
    orderId: string,
    status: string,
  ): Promise<void> {
    const message = this.orderStatusContent(status, orderId);

    await this.notify(userId, {
      title: message.title,
      body: message.body,
      type: message.type,
      referenceId: orderId,
    });

    // Genuine realtime: push order_status_update to the order room, the
    // owner's user room, and the admins room so My Orders, Tracking, and
    // Admin update live with no refresh/polling.
    try {
      this.gateway?.emitOrderStatusUpdate(orderId, status, { userId });
    } catch {
      // socket emit is best-effort only
    }
  }

  /**
   * New order placed → Admin Orders list must prepend it live.
   * Emitted alongside the 'placed' status update above.
   */
  emitNewOrderToAdmins(order: Record<string, unknown>): void {
    try {
      this.gateway?.emitNewOrder(order);
    } catch {
      // best-effort only
    }
  }

  async sendPaymentUpdate(
    userId: string,
    orderId: string,
    outcome: 'paid' | 'failed' | 'refunded',
    amount?: number,
  ): Promise<void> {
    const amountText = amount !== undefined ? ` of ₹${amount}` : '';
    const content =
      outcome === 'paid'
        ? { title: 'Payment Successful', body: `Payment${amountText} for your order was successful.`, type: 'PAYMENT_SUCCESS' }
        : outcome === 'refunded'
          ? { title: 'Refund Initiated', body: `A refund${amountText} for your order has been initiated.`, type: 'PAYMENT_REFUNDED' }
          : { title: 'Payment Failed', body: `Payment${amountText} for your order failed. Please try again.`, type: 'PAYMENT_FAILED' };
    await this.notify(userId, { ...content, referenceId: orderId });
  }

  async sendSubscriptionUpdate(
    userId: string,
    action: 'created' | 'paused' | 'resumed' | 'skipped' | 'cancelled' | 'renewed',
    planName: string,
    referenceId?: string,
  ): Promise<void> {
    const titles: Record<string, string> = {
      created: 'Subscription Activated',
      paused: 'Subscription Paused',
      resumed: 'Subscription Resumed',
      skipped: 'Meal Skipped',
      cancelled: 'Subscription Cancelled',
      renewed: 'Subscription Renewed',
    };
    await this.notify(userId, {
      title: titles[action] || 'Subscription Update',
      body:
        action === 'created'
          ? `Your "${planName}" subscription is now active.`
          : action === 'skipped'
            ? `You skipped a meal on your "${planName}" subscription.`
            : `Your "${planName}" subscription: ${action}.`,
      type: 'SUBSCRIPTION_UPDATE',
      referenceId,
    });
  }

  async sendAnnouncement(
    userId: string,
    title: string,
    body: string,
    type: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' = 'ANNOUNCEMENT',
    referenceId?: string,
  ): Promise<void> {
    await this.notify(userId, { title, body, type, referenceId });
  }

  async sendBulkNotification(
    userIds: string[],
    title: string,
    body: string,
    type: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' | 'BROADCAST' = 'ANNOUNCEMENT',
    referenceId?: string,
  ): Promise<{ sent: number; failed: number }> {
    let sent = 0;
    let failed = 0;

    // Deduplicate targets so retries/double-clicks don't create duplicate rows.
    const uniqueIds = [...new Set(userIds)];
    const createdPublic: ReturnType<NotificationsService['toPublic']>[] = [];
    for (const userId of uniqueIds) {
      try {
        const created = await this.prisma.notification.create({ data: { userId, title, body, type, referenceId } });
        createdPublic.push(this.toPublic(created));
        sent++;
      } catch {
        failed++;
      }
    }

    // Realtime socket push per targeted customer so open apps update
    // the bell badge + popup instantly without refresh (FCM is fallback).
    try {
      for (let i = 0; i < uniqueIds.length; i++) {
        const payload = createdPublic[i] ?? { title, body, type, reference_id: referenceId ?? null };
        this.gateway?.emitNotificationToUser(uniqueIds[i], payload as Record<string, unknown>);
      }
    } catch {
      // best-effort only
    }

    if (this.firebaseApp) {
      const tokens = await this.prisma.fcmToken.findMany({
        where: { userId: { in: uniqueIds }, isActive: true },
        select: { token: true },
      });

      const validTokens = tokens.map((t) => t.token);

      if (validTokens.length > 0) {
        const messaging = getMessaging(this.firebaseApp);
        const response = await messaging.sendEachForMulticast({
          tokens: validTokens,
          notification: { title, body },
          // Keep data keys identical to single notify() so Flutter tap handling works.
          data: {
            type,
            reference_id: referenceId || '',
            title,
            body,
          },
          android: { priority: 'high' },
          apns: { payload: { aps: { sound: 'default' } } },
        });

        const failedTokens: string[] = [];
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
}
