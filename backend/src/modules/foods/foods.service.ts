import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class FoodsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: {
    skip?: number;
    take?: number;
    categoryId?: string;
    search?: string;
    isVeg?: boolean;
    isJainAvailable?: boolean;
    isFastingFriendly?: boolean;
    isBestseller?: boolean;
    isHealthyPick?: boolean;
    minPrice?: number;
    maxPrice?: number;
    includeInactive?: boolean;
  }) {
    const {
      skip,
      take,
      categoryId,
      search,
      isVeg,
      isJainAvailable,
      isFastingFriendly,
      isBestseller,
      isHealthyPick,
      minPrice,
      maxPrice,
      includeInactive,
    } = params;

    const where: any = { deletedAt: null };

    if (!includeInactive) {
      where.isActive = true;
    }

    if (categoryId) where.categoryId = categoryId;
    if (isVeg !== undefined) where.isVeg = isVeg;
    if (isJainAvailable !== undefined) where.isJainAvailable = isJainAvailable;
    if (isFastingFriendly !== undefined) where.isFastingFriendly = isFastingFriendly;
    if (isBestseller !== undefined) where.isBestseller = isBestseller;
    if (isHealthyPick !== undefined) where.isHealthyPick = isHealthyPick;
    if (search) where.name = { contains: search, mode: 'insensitive' };
    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) where.price.gte = minPrice;
      if (maxPrice !== undefined) where.price.lte = maxPrice;
    }

    const foods = await this.prisma.foodItem.findMany({
      where,
      skip: skip || 0,
      take: take || 50,
      include: {
        category: { select: { id: true, name: true, icon: true } },
        customizationGroups: {
          where: includeInactive ? undefined : { isActive: true },
          include: { items: { where: { isActive: true } } },
          orderBy: { displayOrder: 'asc' },
        },
      },
      orderBy: [{ displayOrder: 'asc' }, { createdAt: 'desc' }],
    });

    return foods.map((f) => ({
      ...f,
      price: Number(f.price),
      originalPrice: f.originalPrice ? Number(f.originalPrice) : null,
      rating: Number(f.rating),
      customizationGroups: f.customizationGroups.map((g) => ({
        ...g,
        items: g.items.map((i) => ({ ...i, additionalPrice: Number(i.additionalPrice) })),
      })),
    }));
  }

  async findSpecials() {
    return this.findAll({ isBestseller: true, includeInactive: false });
  }

  async findOne(id: string) {
    const food = await this.prisma.foodItem.findUnique({
      where: { id, deletedAt: null },
      include: {
        category: { select: { id: true, name: true, icon: true } },
        customizationGroups: {
          where: { isActive: true },
          include: { items: { where: { isActive: true } } },
          orderBy: { displayOrder: 'asc' },
        },
      },
    });
    if (!food) throw new NotFoundException('Food item not found');
    return {
      ...food,
      price: Number(food.price),
      originalPrice: food.originalPrice ? Number(food.originalPrice) : null,
      rating: Number(food.rating),
      customizationGroups: food.customizationGroups.map((g) => ({
        ...g,
        items: g.items.map((i) => ({ ...i, additionalPrice: Number(i.additionalPrice) })),
      })),
    };
  }

  async create(data: any) {
    if (data.isVeg === false) {
      throw new BadRequestException('Parabdi is pure vegetarian. Non-veg items are not allowed.');
    }

    if (data.price !== undefined && data.price <= 0) {
      throw new BadRequestException('Price must be a positive number.');
    }

    if (data.originalPrice !== undefined && data.originalPrice <= 0) {
      throw new BadRequestException('Original price must be a positive number.');
    }

    const category = await this.prisma.category.findUnique({
      where: { id: data.categoryId },
    });
    if (!category) throw new BadRequestException('Invalid category reference.');
    if (!category.isActive) throw new BadRequestException('Cannot add food to an inactive category.');

    return this.prisma.foodItem.create({
      data: { ...data, isVeg: true },
    });
  }

  async update(id: string, data: any) {
    const existing = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
    if (!existing) throw new NotFoundException('Food item not found');

    if (data.isVeg === false) {
      throw new BadRequestException('Parabdi is pure vegetarian. Non-veg items are not allowed.');
    }

    if (data.price !== undefined && data.price <= 0) {
      throw new BadRequestException('Price must be a positive number.');
    }

    if (data.originalPrice !== undefined && data.originalPrice <= 0) {
      throw new BadRequestException('Original price must be a positive number.');
    }

    if (data.categoryId) {
      const category = await this.prisma.category.findUnique({
        where: { id: data.categoryId },
      });
      if (!category) throw new BadRequestException('Invalid category reference.');
      if (!category.isActive) throw new BadRequestException('Cannot move food to an inactive category.');
    }

    return this.prisma.foodItem.update({
      where: { id },
      data: { ...data, isVeg: true },
    });
  }

  async remove(id: string) {
    const existing = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
    if (!existing) throw new NotFoundException('Food item not found');

    return this.prisma.foodItem.update({
      where: { id },
      data: { deletedAt: new Date(), isActive: false },
    });
  }

  async toggleActive(id: string) {
    const food = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
    if (!food) throw new NotFoundException('Food item not found');

    return this.prisma.foodItem.update({
      where: { id },
      data: { isActive: !food.isActive },
    });
  }

  async toggleBestseller(id: string) {
    const food = await this.prisma.foodItem.findUnique({ where: { id, deletedAt: null } });
    if (!food) throw new NotFoundException('Food item not found');

    return this.prisma.foodItem.update({
      where: { id },
      data: { isBestseller: !food.isBestseller },
    });
  }

  // ========== CUSTOMIZATION GROUPS ==========

  async getCustomizationGroups(foodItemId: string) {
    const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId, deletedAt: null } });
    if (!food) throw new NotFoundException('Food item not found');

    return this.prisma.customizationGroup.findMany({
      where: { foodItemId },
      include: { items: { orderBy: { displayOrder: 'asc' } } },
      orderBy: { displayOrder: 'asc' },
    });
  }

  async createCustomizationGroup(foodItemId: string, data: {
    name: string;
    minSelections?: number;
    maxSelections?: number;
    displayOrder?: number;
    isActive?: boolean;
  }) {
    const food = await this.prisma.foodItem.findUnique({ where: { id: foodItemId, deletedAt: null } });
    if (!food) throw new NotFoundException('Food item not found');

    const maxOrder = await this.prisma.customizationGroup.aggregate({
      where: { foodItemId },
      _max: { displayOrder: true },
    });

    return this.prisma.customizationGroup.create({
      data: {
        foodItemId,
        name: data.name,
        minSelections: data.minSelections ?? 0,
        maxSelections: data.maxSelections ?? 1,
        displayOrder: data.displayOrder ?? (maxOrder._max.displayOrder ?? 0) + 1,
        isActive: data.isActive !== false,
      },
    });
  }

  async updateCustomizationGroup(groupId: string, data: {
    name?: string;
    minSelections?: number;
    maxSelections?: number;
    displayOrder?: number;
    isActive?: boolean;
  }) {
    const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Customization group not found');

    if (data.minSelections !== undefined && data.maxSelections !== undefined) {
      if (data.minSelections > data.maxSelections) {
        throw new BadRequestException('minSelections cannot be greater than maxSelections');
      }
    }

    return this.prisma.customizationGroup.update({ where: { id: groupId }, data });
  }

  async deleteCustomizationGroup(groupId: string) {
    const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Customization group not found');

    await this.prisma.customizationGroup.delete({ where: { id: groupId } });
    return { message: 'Customization group deleted' };
  }

  // ========== CUSTOMIZATION ITEMS ==========

  async createCustomizationItem(groupId: string, data: {
    name: string;
    additionalPrice?: number;
    displayOrder?: number;
    isActive?: boolean;
  }) {
    const group = await this.prisma.customizationGroup.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Customization group not found');

    if (data.additionalPrice !== undefined && data.additionalPrice < 0) {
      throw new BadRequestException('Additional price cannot be negative.');
    }

    const maxOrder = await this.prisma.customizationItem.aggregate({
      where: { groupId },
      _max: { displayOrder: true },
    });

    return this.prisma.customizationItem.create({
      data: {
        groupId,
        name: data.name,
        additionalPrice: data.additionalPrice ?? 0,
        displayOrder: data.displayOrder ?? (maxOrder._max.displayOrder ?? 0) + 1,
        isActive: data.isActive !== false,
      },
    });
  }

  async updateCustomizationItem(itemId: string, data: {
    name?: string;
    additionalPrice?: number;
    isActive?: boolean;
    displayOrder?: number;
  }) {
    const item = await this.prisma.customizationItem.findUnique({ where: { id: itemId } });
    if (!item) throw new NotFoundException('Customization item not found');

    if (data.additionalPrice !== undefined && data.additionalPrice < 0) {
      throw new BadRequestException('Additional price cannot be negative.');
    }

    return this.prisma.customizationItem.update({ where: { id: itemId }, data });
  }

  async deleteCustomizationItem(itemId: string) {
    const item = await this.prisma.customizationItem.findUnique({ where: { id: itemId } });
    if (!item) throw new NotFoundException('Customization item not found');

    await this.prisma.customizationItem.delete({ where: { id: itemId } });
    return { message: 'Customization item deleted' };
  }
}
