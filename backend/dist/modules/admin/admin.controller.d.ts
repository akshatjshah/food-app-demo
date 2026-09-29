import { AdminService } from './admin.service';
export declare class AdminController {
    private adminService;
    constructor(adminService: AdminService);
    getDashboard(): Promise<{
        totalOrders: number;
        revenueToday: number;
        activeSubscriptions: number;
        pendingOrders: number;
        totalUsers: number;
    }>;
    getRevenue(days?: string): Promise<{
        date: string;
        revenue: number;
    }[]>;
    getOrdersByStatus(): Promise<{
        status: string;
        count: number;
    }[]>;
    getTopDishes(limit?: string): Promise<{
        id: string;
        name: string;
        orderCount: number;
    }[]>;
    getRecentOrders(limit?: string): Promise<{
        id: string;
        orderNumber: string;
        customerName: string;
        total: number;
        status: import(".prisma/client").$Enums.OrderStatus;
        createdAt: Date;
    }[]>;
    getOrders(skip?: string, take?: string, status?: string, search?: string): Promise<({
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
        type?: 'OFFER' | 'MENU_UPDATE' | 'ANNOUNCEMENT';
        userIds?: string[];
        referenceId?: string;
    }): Promise<{
        sent: number;
        failed: number;
    }>;
    getAuditLogs(skip?: string, take?: string): Promise<({
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
