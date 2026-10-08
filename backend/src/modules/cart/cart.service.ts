import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../config/prisma.service';

@Injectable()
export class CartService {
  constructor(private prisma: PrismaService) {}

  private foodItemSelect = {
    id: true, name: true, price: true, imageUrls: true,
    isVeg: true, isActive: true, deletedAt: true,
    preparationTimeMinutes: true,
  };

  private isFoodAvailable(foodItem: any): boolean {
    return !!foodItem.isActive && (foodItem as any).isAvailable !== false && !foodItem.deletedAt;
  }

  /** Server-authoritative customization validation.
   *  Returns the normalized snapshot [{customization_item_id,id,name,additional_price,group}]
   *  and the total additional price. Throws BadRequestException on any violation. */
  private async validateCustomizations(foodItemId: string, customizationItems?: any[]) {
    const list = Array.isArray(customizationItems) ? customizationItems : [];
    const groups = await this.prisma.customizationGroup.findMany({
      where: { foodItemId, isActive: true },
      include: { items: true },
    });
    const groupById = new Map(groups.map((g) => [g.id, g]));
    const itemById = new Map<string, { item: any; group: any }>();
    for (const g of groups) {
      for (const it of g.items) itemById.set(it.id, { item: it, group: g });
    }

    // Group submitted option ids by group id.
    const selectedByGroup = new Map<string, string[]>();
    const normalized: any[] = [];
    let additionalTotal = 0;

    for (const ci of list) {
      const groupId: string | undefined = ci.customization_group_id || ci.groupId || ci.group_id;
      const itemId: string | undefined =
        ci.customization_item_id || ci.customizationItemId || ci.id;
      if (!itemId) throw new BadRequestException('Invalid customization option: missing id');
      const found = itemById.get(itemId);
      if (!found) throw new BadRequestException(`Invalid customization option: ${itemId}`);
      if (!found.item.isActive) throw new BadRequestException(`Option "${found.item.name}" is not available`);
      if (!found.group.isActive) throw new BadRequestException(`Option group "${found.group.name}" is not active`);
      // If client sent a group id, it must match the option's real group.
      if (groupId && groupId !== found.group.id) {
        throw new BadRequestException(`Option "${found.item.name}" does not belong to the given group`);
      }
      const gid = found.group.id;
      if (!selectedByGroup.has(gid)) selectedByGroup.set(gid, []);
      const arr = selectedByGroup.get(gid)!;
      if (arr.includes(itemId)) throw new BadRequestException(`Duplicate option "${found.item.name}"`);
      arr.push(itemId);
      const price = Number(found.item.additionalPrice);
      additionalTotal += price;
      normalized.push({
        customization_group_id: gid,
        customization_item_id: found.item.id,
        id: found.item.id,
        name: found.item.name,
        additional_price: price,
        group: found.group.name,
      });
    }

    // Required / min / max enforcement over ALL active groups.
    for (const g of groups) {
      const count = selectedByGroup.get(g.id)?.length ?? 0;
      if (count < g.minSelections) {
        if (g.minSelections > 0) {
          throw new BadRequestException(
            `"${g.name}" requires at least ${g.minSelections} selection(s)`,
          );
        }
      }
      if (count > g.maxSelections) {
        throw new BadRequestException(
          `"${g.name}" allows at most ${g.maxSelections} selection(s)`,
        );
      }
    }

    // Deterministic order so identical configs hash identically.
    normalized.sort((a, b) => String(a.customization_item_id).localeCompare(String(b.customization_item_id)));
    return { normalized, additionalTotal };
  }

  private customizationSignature(items: any[]): string {
    const ids = (Array.isArray(items) ? items : [])
      .map((c: any) => String(c.customization_item_id || c.id || ''))
      .filter(Boolean)
      .sort();
    return ids.join('|');
  }

  async getCart(userId: string) {
    let cart = await this.prisma.cart.findUnique({
      where: { userId },
      include: {
        items: {
          include: {
            foodItem: { select: this.foodItemSelect },
          },
        },
      },
    });

    if (!cart) {
      cart = await this.prisma.cart.create({
        data: { userId },
        include: {
          items: {
            include: {
              foodItem: { select: this.foodItemSelect },
            },
          },
        },
      });
    }

    const items = cart.items.map((i) => {
      const basePrice = Number(i.foodItem.price);
      const customizationTotal = Array.isArray(i.customizationItems)
        ? (i.customizationItems as any[]).reduce(
            (s: number, c: any) => s + Number(c.additional_price || 0),
            0,
          )
        : 0;
      const unitPrice = basePrice + customizationTotal;
      const itemTotal = unitPrice * i.quantity;
      const isAvailable = this.isFoodAvailable(i.foodItem);

      return {
        id: i.id,
        foodItemId: i.foodItemId,
        quantity: i.quantity,
        customizationItems: Array.isArray(i.customizationItems)
          ? i.customizationItems
          : [],
        specialInstructions: i.specialInstructions,
        createdAt: i.createdAt,
        foodItem: {
          id: i.foodItem.id,
          name: i.foodItem.name,
          price: basePrice,
          imageUrls: i.foodItem.imageUrls,
          isVeg: i.foodItem.isVeg,
          preparationTimeMinutes: i.foodItem.preparationTimeMinutes,
        },
        unitPrice,
        itemTotal,
        isAvailable,
      };
    });

    const availableItems = items.filter((i) => i.isAvailable);
    const unavailableItems = items.filter((i) => !i.isAvailable);

    const itemTotal = availableItems.reduce((sum, i) => sum + i.itemTotal, 0);
    const itemCount = availableItems.reduce((sum, i) => sum + i.quantity, 0);

    return {
      id: cart.id,
      items: availableItems,
      unavailableItems,
      itemTotal,
      itemCount,
      hasUnavailableItems: unavailableItems.length > 0,
    };
  }

  async addItem(
    userId: string,
    dto: {
      foodItemId: string;
      quantity: number;
      customizationItems?: any[];
      specialInstructions?: string;
    },
  ) {
    if (dto.quantity < 1) {
      throw new BadRequestException('Quantity must be at least 1');
    }

    const foodItem = await this.prisma.foodItem.findUnique({
      where: { id: dto.foodItemId },
    });

    if (!foodItem) {
      throw new NotFoundException('Food item not found');
    }

    if (!foodItem.isActive || (foodItem as any).isAvailable === false) {
      throw new BadRequestException('This item is no longer available');
    }

    if (foodItem.deletedAt) {
      throw new BadRequestException('This item has been removed');
    }

    const { normalized } = await this.validateCustomizations(dto.foodItemId, dto.customizationItems);

    let cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) {
      cart = await this.prisma.cart.create({ data: { userId } });
    }

    // Different customization selections are different lines: only merge
    // when food + customization signature match exactly.
    const signature = this.customizationSignature(normalized);
    const siblings = await this.prisma.cartItem.findMany({
      where: { cartId: cart.id, foodItemId: dto.foodItemId },
    });
    const existingItem = siblings.find(
      (s) => this.customizationSignature((s.customizationItems as any[]) || []) === signature,
    );

    if (existingItem) {
      return this.prisma.cartItem.update({
        where: { id: existingItem.id },
        data: {
          quantity: existingItem.quantity + dto.quantity,
          customizationItems: normalized as any,
          specialInstructions: dto.specialInstructions || existingItem.specialInstructions,
        },
      });
    }

    return this.prisma.cartItem.create({
      data: {
        cartId: cart.id,
        foodItemId: dto.foodItemId,
        quantity: dto.quantity,
        customizationItems: normalized as any,
        specialInstructions: dto.specialInstructions,
      },
    });
  }

  async updateItem(userId: string, itemId: string, quantity: number) {
    const cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) throw new NotFoundException('Cart not found');

    const cartItem = await this.prisma.cartItem.findFirst({
      where: { id: itemId, cartId: cart.id },
    });
    if (!cartItem) throw new NotFoundException('Cart item not found');

    if (quantity <= 0) {
      return this.prisma.cartItem.delete({ where: { id: itemId } });
    }

    return this.prisma.cartItem.update({
      where: { id: itemId },
      data: { quantity },
    });
  }

  async removeItem(userId: string, itemId: string) {
    const cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) throw new NotFoundException('Cart not found');

    const cartItem = await this.prisma.cartItem.findFirst({
      where: { id: itemId, cartId: cart.id },
    });
    if (!cartItem) throw new NotFoundException('Cart item not found');

    return this.prisma.cartItem.delete({ where: { id: itemId } });
  }

  async clearCart(userId: string) {
    const cart = await this.prisma.cart.findUnique({ where: { userId } });
    if (!cart) return;

    await this.prisma.cartItem.deleteMany({ where: { cartId: cart.id } });
    return { message: 'Cart cleared' };
  }

  async validateCartForCheckout(userId: string) {
    const cart = await this.prisma.cart.findUnique({
      where: { userId },
      include: {
        items: {
          include: {
            foodItem: true,
          },
        },
      },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    const errors: string[] = [];
    let itemTotal = 0;

    for (const item of cart.items) {
      if (!item.foodItem.isActive || (item.foodItem as any).isAvailable === false) {
        errors.push(`${item.foodItem.name} is no longer available`);
        continue;
      }
      if (item.foodItem.deletedAt) {
        errors.push(`${item.foodItem.name} has been removed`);
        continue;
      }
      const basePrice = Number(item.foodItem.price);
      const customizationTotal = Array.isArray(item.customizationItems)
        ? (item.customizationItems as any[]).reduce(
            (s: number, c: any) => s + Number(c.additional_price || 0),
            0,
          )
        : 0;
      itemTotal += (basePrice + customizationTotal) * item.quantity;
    }

    if (errors.length > 0) {
      throw new BadRequestException({
        message: 'Some items in your cart are no longer available',
        errors,
      });
    }

    if (itemTotal < 1) {
      throw new BadRequestException(
        `Minimum order value is ₹1. Current total: ₹${itemTotal}`,
      );
    }

    return {
      isValid: true,
      itemTotal,
      itemCount: cart.items.reduce((sum, i) => sum + i.quantity, 0),
      taxAmount: itemTotal * 0.05,
      platformFee: 2,
      deliveryFee: itemTotal >= 200 ? 0 : 30,
      grandTotal:
        itemTotal + itemTotal * 0.05 + 2 + (itemTotal >= 200 ? 0 : 30),
    };
  }
}
