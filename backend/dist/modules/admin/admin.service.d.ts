import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export declare class AdminService {
    private prisma;
    private notificationsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService);
    getDashboard(): Promise<{
        totalOrders: number;
        revenueToday: number;
        activeSubscriptions: number;
        pendingOrders: number;
        totalUsers: number;
    }>;
    getRevenueChart(days?: number): Promise<{
        date: string;
        revenue: number;
    }[]>;
    getOrdersByStatus(): Promise<{
        status: string;
        count: number;
    }[]>;
    getTopDishes(limit?: number): Promise<{
        id: string;
        name: string;
        orderCount: number;
    }[]>;
    getRecentOrders(limit?: number): Promise<{
        id: string;
        orderNumber: string;
        customerName: string;
        total: number;
        status: import(".prisma/client").$Enums.OrderStatus;
        createdAt: Date;
    }[]>;
    getOrders(params: {
        skip?: number;
        take?: number;
        status?: string;
        search?: string;
    }): Promise<({
        user: {
            id: string;
            phoneNumber: string;
            fullName: string | null;
        };
        items: ({
            foodItem: {
                name: string;
            };
        } & {
            id: string;
            createdAt: Date;
            foodItemId: string;
            quantity: number;
            unitPrice: import("@prisma/client/runtime/library").Decimal;
            orderId: string;
        })[];
    } & {
        deliverySlot: string;
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        specialInstructions: string | null;
        status: import(".prisma/client").$Enums.OrderStatus;
        paymentMethod: import(".prisma/client").$Enums.PaymentMethod;
        paymentStatus: import(".prisma/client").$Enums.PaymentStatus;
        paymentReferenceId: string | null;
        itemTotal: import("@prisma/client/runtime/library").Decimal;
        taxAmount: import("@prisma/client/runtime/library").Decimal;
        deliveryFee: import("@prisma/client/runtime/library").Decimal;
        platformFee: import("@prisma/client/runtime/library").Decimal;
        discountAmount: import("@prisma/client/runtime/library").Decimal;
        grandTotal: import("@prisma/client/runtime/library").Decimal;
        otpCode: string;
        addressId: string | null;
        chefId: string | null;
        deliveryBoyId: string | null;
    })[]>;
    updateOrderStatus(orderId: string, status: string, triggeredBy?: string): Promise<{
        deliverySlot: string;
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        specialInstructions: string | null;
        status: import(".prisma/client").$Enums.OrderStatus;
        paymentMethod: import(".prisma/client").$Enums.PaymentMethod;
        paymentStatus: import(".prisma/client").$Enums.PaymentStatus;
        paymentReferenceId: string | null;
        itemTotal: import("@prisma/client/runtime/library").Decimal;
        taxAmount: import("@prisma/client/runtime/library").Decimal;
        deliveryFee: import("@prisma/client/runtime/library").Decimal;
        platformFee: import("@prisma/client/runtime/library").Decimal;
        discountAmount: import("@prisma/client/runtime/library").Decimal;
        grandTotal: import("@prisma/client/runtime/library").Decimal;
        otpCode: string;
        addressId: string | null;
        chefId: string | null;
        deliveryBoyId: string | null;
    }>;
    broadcastAnnouncement(title: string, body: string, type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT', userIds?: string[], referenceId?: string): Promise<{
        sent: number;
        failed: number;
    }>;
    logAudit(adminId: string, data: {
        action: string;
        entity: string;
        entityId?: string;
        oldValue?: any;
        newValue?: any;
        ipAddress?: string;
    }): Promise<{
        id: string;
        createdAt: Date;
        action: string;
        entity: string;
        entityId: string | null;
        oldValue: import("@prisma/client/runtime/library").JsonValue | null;
        newValue: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        adminId: string;
    }>;
    getAuditLogs(params: {
        skip?: number;
        take?: number;
    }): Promise<({
        admin: {
            id: string;
            fullName: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        action: string;
        entity: string;
        entityId: string | null;
        oldValue: import("@prisma/client/runtime/library").JsonValue | null;
        newValue: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        adminId: string;
    })[]>;
}
