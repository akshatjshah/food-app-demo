import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
export declare class OrdersController {
    private ordersService;
    constructor(ordersService: OrdersService);
    create(req: any, dto: CreateOrderDto): Promise<{
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
    findAll(req: any, skip?: string, take?: string, status?: string): Promise<any[]>;
    findOne(id: string, req: any): Promise<any>;
    cancel(id: string, req: any): Promise<{
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
    reorder(id: string, req: any): Promise<{
        message: string;
    }>;
}
