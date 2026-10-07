import { OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
import { OrderGateway } from '../../gateway/gateway.service';
export declare class NotificationsService implements OnModuleInit {
    private prisma;
    private config;
    private gateway?;
    private readonly logger;
    private firebaseApp;
    constructor(prisma: PrismaService, config: ConfigService, gateway?: OrderGateway | undefined);
    onModuleInit(): void;
    private initializeFirebase;
    private toPublic;
    findAll(userId: string, params?: {
        skip?: number;
        take?: number;
    }): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    }[]>;
    markRead(id: string, userId: string): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    }>;
    markAllRead(userId: string): Promise<{
        message: string;
    }>;
    create(userId: string, data: {
        title: string;
        body: string;
        type: string;
        referenceId?: string;
    }): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    }>;
    notify(userId: string, data: {
        title: string;
        body: string;
        type: string;
        referenceId?: string;
    }): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    } | null>;
    getUnreadCount(userId: string): Promise<{
        count: number;
    }>;
    removeAll(userId: string): Promise<{
        message: string;
        count: number;
    }>;
    sendPushNotification(userId: string, title: string, body: string, data?: Record<string, string>): Promise<boolean>;
    private orderStatusContent;
    sendOrderStatusUpdate(userId: string, orderId: string, status: string): Promise<void>;
    sendPaymentUpdate(userId: string, orderId: string, outcome: 'paid' | 'failed' | 'refunded', amount?: number): Promise<void>;
    sendSubscriptionUpdate(userId: string, action: 'created' | 'paused' | 'resumed' | 'skipped' | 'cancelled' | 'renewed', planName: string, referenceId?: string): Promise<void>;
    sendAnnouncement(userId: string, title: string, body: string, type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT', referenceId?: string): Promise<void>;
    sendBulkNotification(userIds: string[], title: string, body: string, type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' | 'BROADCAST', referenceId?: string): Promise<{
        sent: number;
        failed: number;
    }>;
}
