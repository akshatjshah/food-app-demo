import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export declare class PaymentsService {
    private prisma;
    private configService;
    private notificationsService;
    constructor(prisma: PrismaService, configService: ConfigService, notificationsService: NotificationsService);
    createOrder(orderId: string, amount: number): Promise<{
        orderId: string;
        amount: number;
        currency: string;
        keyId: string | undefined;
    }>;
    verifyPayment(orderId: string, razorpayOrderId: string, razorpayPaymentId: string, razorpaySignature: string): Promise<{
        verified: boolean;
    }>;
    handleWebhook(event: string, data: any): Promise<{
        received: boolean;
    }>;
}
