import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export declare class AdminService {
    private prisma;
    private notificationsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService);
    getDashboard(): Promise<{
        totalOrders: number;
        todayOrders: number;
        pendingOrders: number;
        completedOrders: number;
        cancelledOrders: number;
        totalRevenue: number;
        revenueToday: number;
        activeSubscriptions: number;
        totalUsers: number;
        activeCustomers: number;
        activeFoods: number;
        lowStockFoods: number;
        activeChefs: number;
        activeRiders: number;
    }>;
    getRevenueChart(days?: number): Promise<{
        date: string;
        revenue: number;
        orders: number;
    }[]>;
    getOrdersByStatus(): Promise<{
        status: string;
        count: number;
    }[]>;
    getTopDishes(limit?: number): Promise<{
        id: string;
        name: string;
        orderCount: number;
        quantity: number;
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
        paymentStatus?: string;
        search?: string;
    }): Promise<{
        data: {
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
                foodName: string | null;
                basePrice: import("@prisma/client/runtime/library").Decimal | null;
                orderId: string;
            })[];
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
            addressId: string | null;
            chefId: string | null;
            deliveryBoyId: string | null;
        }[];
        total: number;
    }>;
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
    broadcastAnnouncement(title: string, body: string, type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' | 'BROADCAST', userIds?: string[], referenceId?: string): Promise<{
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
        entity?: string;
        action?: string;
        search?: string;
    }): Promise<{
        data: ({
            admin: {
                id: string;
                email: string | null;
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
        })[];
        total: number;
    }>;
    getOrderDetail(orderId: string): Promise<any>;
    getCustomers(params: {
        search?: string;
        skip?: number;
        take?: number;
    }): Promise<{
        data: {
            walletBalance: number;
            orderCount: number;
            subscriptionCount: number;
            totalSpend: number;
            id: string;
            phoneNumber: string;
            email: string | null;
            fullName: string | null;
            isBlocked: boolean;
            createdAt: Date;
            _count: {
                orders: number;
                subscriptions: number;
            };
        }[];
        total: number;
    }>;
    getCustomerDetail(id: string): Promise<any>;
    setCustomerBlocked(id: string, isBlocked: boolean, adminId: string): Promise<any>;
    getStaff(role: 'chef' | 'delivery', search?: string): Promise<{
        activeOrders: any;
        completedOrders: any;
        id: string;
        phoneNumber: string;
        email: string | null;
        fullName: string | null;
        isBlocked: boolean;
        createdAt: Date;
    }[]>;
    createStaff(data: {
        fullName: string;
        phoneNumber: string;
        email?: string;
        role: 'chef' | 'delivery';
    }, adminId: string): Promise<any>;
    updateStaff(id: string, data: {
        fullName?: string;
        email?: string;
        isBlocked?: boolean;
        role?: 'chef' | 'delivery';
    }, adminId: string): Promise<any>;
    getWalletTransactions(params: {
        skip?: number;
        take?: number;
        search?: string;
    }): Promise<{
        data: {
            amount: number;
            user: {
                id: string;
                phoneNumber: string;
                fullName: string | null;
            };
            description: string;
            id: string;
            createdAt: Date;
            userId: string;
            type: import(".prisma/client").$Enums.WalletTransactionType;
            referenceOrderId: string | null;
        }[];
        total: number;
    }>;
    getLoyaltyTransactions(params: {
        skip?: number;
        take?: number;
        search?: string;
    }): Promise<{
        data: ({
            user: {
                id: string;
                phoneNumber: string;
                fullName: string | null;
            };
        } & {
            description: string;
            id: string;
            createdAt: Date;
            userId: string;
            referenceOrderId: string | null;
            points: number;
            transactionType: string;
        })[];
        total: number;
    }>;
    getRecentNotifications(take?: number): Promise<({
        user: {
            id: string;
            phoneNumber: string;
            fullName: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        userId: string;
        type: string;
        title: string;
        body: string;
        referenceId: string | null;
        isRead: boolean;
    })[]>;
    getReports(days?: number): Promise<{
        totalOrders: number;
        totalRevenue: number;
        avgOrderValue: number;
        newCustomers: number;
        byDay: {
            date: string;
            revenue: number;
            orders: number;
        }[];
    }>;
}
