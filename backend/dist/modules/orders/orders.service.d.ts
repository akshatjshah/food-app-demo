import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export declare class OrdersService {
    private prisma;
    private notificationsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService);
    create(userId: string, dto: {
        addressId: string;
        deliverySlot: string;
        specialInstructions?: string;
        couponCode?: string;
        paymentMethod?: string;
    }): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.OrderStatus;
        itemTotal: number;
        taxAmount: number;
        platformFee: number;
        deliveryFee: number;
        discountAmount: number;
        grandTotal: number;
        otpCode: string;
        createdAt: Date;
    }>;
    private toPlainOrder;
    findAll(userId: string, params: {
        skip?: number;
        take?: number;
        status?: string;
    }): Promise<any[]>;
    findOne(id: string, requesterId?: string, isAdmin?: boolean): Promise<any>;
    cancel(id: string, userId: string): Promise<{
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
    reorder(userId: string, orderId: string): Promise<{
        message: string;
    }>;
}
