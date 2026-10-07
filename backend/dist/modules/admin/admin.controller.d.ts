import { AdminService } from './admin.service';
export declare class AdminController {
    private adminService;
    constructor(adminService: AdminService);
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
    getRevenue(days?: string): Promise<{
        date: string;
        revenue: number;
        orders: number;
    }[]>;
    getOrdersByStatus(): Promise<{
        status: string;
        count: number;
    }[]>;
    getTopDishes(limit?: string): Promise<{
        id: string;
        name: string;
        orderCount: number;
        quantity: number;
    }[]>;
    getRecentOrders(limit?: string): Promise<{
        id: string;
        orderNumber: string;
        customerName: string;
        total: number;
        status: import(".prisma/client").$Enums.OrderStatus;
        createdAt: Date;
    }[]>;
    getOrders(skip?: string, take?: string, status?: string, paymentStatus?: string, search?: string): Promise<{
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
    getOrderDetail(orderId: string): Promise<any>;
    updateOrderStatus(orderId: string, status: string, req: any): Promise<{
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
    broadcast(body: {
        title: string;
        body: string;
        type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT' | 'BROADCAST';
        userIds?: string[];
        referenceId?: string;
    }): Promise<{
        sent: number;
        failed: number;
    }>;
    getAuditLogs(skip?: string, take?: string, entity?: string, action?: string, search?: string): Promise<{
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
    getCustomers(search?: string, skip?: string, take?: string): Promise<{
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
    setCustomerBlocked(id: string, isBlocked: boolean, req: any): Promise<any>;
    getStaff(role?: string, search?: string): Promise<{
        activeOrders: any;
        completedOrders: any;
        id: string;
        phoneNumber: string;
        email: string | null;
        fullName: string | null;
        isBlocked: boolean;
        createdAt: Date;
    }[]>;
    createStaff(body: {
        fullName: string;
        phoneNumber: string;
        email?: string;
        role: 'chef' | 'delivery';
    }, req: any): Promise<any>;
    updateStaff(id: string, body: {
        fullName?: string;
        email?: string;
        isBlocked?: boolean;
        role?: 'chef' | 'delivery';
    }, req: any): Promise<any>;
    getWalletTransactions(skip?: string, take?: string, search?: string): Promise<{
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
    getReports(days?: string): Promise<{
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
    getLoyaltyTransactions(skip?: string, take?: string, search?: string): Promise<{
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
    getRecentNotifications(take?: string): Promise<({
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
}
