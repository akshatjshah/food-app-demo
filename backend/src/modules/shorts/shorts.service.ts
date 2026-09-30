import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class ShortsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params?: { skip?: number; take?: number; categoryId?: string }) {
    const where: any = { isActive: true };
    if (params?.categoryId) where.categoryId = params.categoryId;

    return this.prisma.short.findMany({
      where,
      include: {
        foodItem: { select: { id: true, name: true, price: true, imageUrls: true } },
        category: { select: { id: true, name: true } },
      },
      orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
      skip: params?.skip || 0,
      take: params?.take || 20,
    });
  }

  async toggleLike(userId: string, shortId: string) {
    const existing = await this.prisma.foodShortLike.findUnique({
      where: { userId_shortId: { userId, shortId } },
    });

    if (existing) {
      await this.prisma.foodShortLike.delete({ where: { id: existing.id } });
      await this.prisma.short.update({ where: { id: shortId }, data: { likesCount: { decrement: 1 } } });
      return { liked: false };
    }

    await this.prisma.foodShortLike.create({ data: { userId, shortId } });
    await this.prisma.short.update({ where: { id: shortId }, data: { likesCount: { increment: 1 } } });
    return { liked: true };
  }

  async incrementViews(shortId: string) {
    await this.prisma.short.update({ where: { id: shortId }, data: { viewsCount: { increment: 1 } } });
  }

  // ── Admin management ──
  async findAllAdmin() {
    return this.prisma.short.findMany({
      include: {
        foodItem: { select: { id: true, name: true } },
        category: { select: { id: true, name: true } },
      },
      orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
      take: 100,
    });
  }

  async create(data: { videoUrl: string; thumbnailUrl: string; caption?: string; foodItemId?: string; categoryId?: string; isActive?: boolean; displayOrder?: number }) {
    if (!data.videoUrl || !data.thumbnailUrl) {
      throw new BadRequestException('videoUrl and thumbnailUrl are required');
    }
    return this.prisma.short.create({
      data: {
        videoUrl: data.videoUrl,
        thumbnailUrl: data.thumbnailUrl,
        caption: data.caption || null,
        foodItemId: data.foodItemId || null,
        categoryId: data.categoryId || null,
        isActive: data.isActive !== false,
        displayOrder: data.displayOrder ?? 0,
      },
    });
  }

  async update(id: string, data: Partial<{ videoUrl: string; thumbnailUrl: string; caption: string; foodItemId: string; categoryId: string; isActive: boolean; displayOrder: number }>) {
    const existing = await this.prisma.short.findUnique({ where: { id } });
    if (!existing) throw new BadRequestException('Short not found');
    return this.prisma.short.update({
      where: { id },
      data: {
        ...(data.videoUrl !== undefined ? { videoUrl: data.videoUrl } : {}),
        ...(data.thumbnailUrl !== undefined ? { thumbnailUrl: data.thumbnailUrl } : {}),
        ...(data.caption !== undefined ? { caption: data.caption || null } : {}),
        ...(data.foodItemId !== undefined ? { foodItemId: data.foodItemId || null } : {}),
        ...(data.categoryId !== undefined ? { categoryId: data.categoryId || null } : {}),
        ...(data.isActive !== undefined ? { isActive: data.isActive } : {}),
        ...(data.displayOrder !== undefined ? { displayOrder: data.displayOrder } : {}),
      },
    });
  }

  async remove(id: string) {
    return this.prisma.short.delete({ where: { id } });
  }
}
