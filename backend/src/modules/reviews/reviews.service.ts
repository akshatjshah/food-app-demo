import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class ReviewsService {
  constructor(private prisma: PrismaService) {}

  async findByFood(foodItemId: string) {
    return this.prisma.review.findMany({
      where: { foodItemId, isApproved: true },
      include: { user: { select: { id: true, fullName: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(userId: string, dto: { foodItemId: string; orderId: string; rating: number; comment?: string; images?: string[] }) {
    // Reviews are only allowed on delivered orders owned by the customer.
    // One review per (order, food item, user) per existing backend rules.
    const order = await this.prisma.order.findUnique({ where: { id: dto.orderId } });
    if (!order || order.userId !== userId) {
      throw new ForbiddenException('You can only review your own orders');
    }
    if (order.status !== 'delivered') {
      throw new BadRequestException('You can review only after the order is delivered');
    }
    const existing = await this.prisma.review.findFirst({
      where: { userId, orderId: dto.orderId, foodItemId: dto.foodItemId },
    });
    if (existing) {
      throw new BadRequestException('You have already reviewed this item for this order');
    }
    if (dto.rating < 1 || dto.rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }
    return this.prisma.$transaction(async (tx) => {
      const review = await tx.review.create({
        data: { userId, ...dto },
      });

      const stats = await tx.review.aggregate({
        where: { foodItemId: dto.foodItemId, isApproved: true },
        _avg: { rating: true },
        _count: { rating: true },
      });

      await tx.foodItem.update({
        where: { id: dto.foodItemId },
        data: {
          rating: Number(stats._avg.rating || 0),
          reviewsCount: stats._count.rating,
        },
      });

      return review;
    });
  }

  async findAll() {
    return this.prisma.review.findMany({
      include: {
        user: { select: { id: true, fullName: true } },
        foodItem: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async moderate(id: string, isApproved: boolean) {
    return this.prisma.review.update({ where: { id }, data: { isApproved } });
  }
}
