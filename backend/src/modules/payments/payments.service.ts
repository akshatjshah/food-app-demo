import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import * as crypto from 'crypto';

@Injectable()
export class PaymentsService {
  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
    private notificationsService: NotificationsService,
  ) {}

  async createOrder(orderId: string, amount: number) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new BadRequestException('Order not found');

    return {
      orderId: order.id,
      amount: Math.round(amount * 100),
      currency: 'INR',
      keyId: this.configService.get<string>('RAZORPAY_KEY_ID'),
    };
  }

  async verifyPayment(orderId: string, razorpayOrderId: string, razorpayPaymentId: string, razorpaySignature: string) {
    const secret = this.configService.get<string>('RAZORPAY_KEY_SECRET') || '';
    const body = razorpayOrderId + '|' + razorpayPaymentId;
    const expectedSignature = crypto.createHmac('sha256', secret).update(body).digest('hex');

    if (expectedSignature !== razorpaySignature) {
      const failedOrder = await this.prisma.order.findUnique({ where: { id: orderId } });
      if (failedOrder) {
        await this.notificationsService.sendPaymentUpdate(
          failedOrder.userId,
          orderId,
          'failed',
          Number(failedOrder.grandTotal),
        );
      }
      throw new BadRequestException('Payment verification failed');
    }

    const result = await this.prisma.$transaction(async (tx) => {
      await tx.order.update({
        where: { id: orderId },
        data: { paymentStatus: 'paid', paymentReferenceId: razorpayPaymentId },
      });
      return { verified: true };
    });

    const paidOrder = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (paidOrder) {
      await this.notificationsService.sendPaymentUpdate(
        paidOrder.userId,
        orderId,
        'paid',
        Number(paidOrder.grandTotal),
      );
    }

    return result;
  }

  async handleWebhook(event: string, data: any) {
    if (event === 'payment.captured') {
      await this.prisma.order.updateMany({
        where: { id: data.order_id },
        data: { paymentStatus: 'paid' },
      });
      const order = await this.prisma.order.findUnique({ where: { id: data.order_id } });
      if (order) {
        await this.notificationsService.sendPaymentUpdate(
          order.userId,
          order.id,
          'paid',
          Number(order.grandTotal),
        );
      }
    }
    return { received: true };
  }
}
