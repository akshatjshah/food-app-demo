import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class WishlistService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    const items = await this.prisma.wishlist.findMany({
      where: { userId },
      include: {
        foodItem: {
          select: { id: true, name: true, price: true, imageUrls: true, rating: true, isVeg: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    // Serialize Decimal (price/rating) to plain numbers so the Flutter
    // client can parse them as num (Prisma Decimals serialize as strings).
    return items.map((w) => ({
      ...w,
      foodItem: w.foodItem
        ? {
            ...w.foodItem,
            price: Number((w.foodItem as any).price),
            rating:
              (w.foodItem as any).rating === null ||
              (w.foodItem as any).rating === undefined
                ? null
                : Number((w.foodItem as any).rating),
          }
        : w.foodItem,
    }));
  }

  async toggle(userId: string, foodItemId: string) {
    const existing = await this.prisma.wishlist.findUnique({
      where: { userId_foodItemId: { userId, foodItemId } },
    });
    if (existing) {
      await this.prisma.wishlist.delete({ where: { id: existing.id } });
      return { added: false };
    }
    await this.prisma.wishlist.create({ data: { userId, foodItemId } });
    return { added: true };
  }
}
