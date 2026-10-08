import { PrismaService } from '../../config/prisma.service';
export declare class CartService {
    private prisma;
    constructor(prisma: PrismaService);
    private foodItemSelect;
    private isFoodAvailable;
    private validateCustomizations;
    private customizationSignature;
    getCart(userId: string): Promise<{
        id: string;
        items: {
            id: string;
            foodItemId: string;
            quantity: number;
            customizationItems: import("@prisma/client/runtime/library").JsonArray;
            specialInstructions: string | null;
            createdAt: Date;
            foodItem: {
                id: string;
                name: string;
                price: number;
                imageUrls: import("@prisma/client/runtime/library").JsonValue;
                isVeg: boolean;
                preparationTimeMinutes: number;
            };
            unitPrice: any;
            itemTotal: number;
            isAvailable: boolean;
        }[];
        unavailableItems: {
            id: string;
            foodItemId: string;
            quantity: number;
            customizationItems: import("@prisma/client/runtime/library").JsonArray;
            specialInstructions: string | null;
            createdAt: Date;
            foodItem: {
                id: string;
                name: string;
                price: number;
                imageUrls: import("@prisma/client/runtime/library").JsonValue;
                isVeg: boolean;
                preparationTimeMinutes: number;
            };
            unitPrice: any;
            itemTotal: number;
            isAvailable: boolean;
        }[];
        itemTotal: number;
        itemCount: number;
        hasUnavailableItems: boolean;
    }>;
    addItem(userId: string, dto: {
        foodItemId: string;
        quantity: number;
        customizationItems?: any[];
        specialInstructions?: string;
    }): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        foodItemId: string;
        cartId: string;
        quantity: number;
        customizationItems: import("@prisma/client/runtime/library").JsonValue;
        specialInstructions: string | null;
    }>;
    updateItem(userId: string, itemId: string, quantity: number): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        foodItemId: string;
        cartId: string;
        quantity: number;
        customizationItems: import("@prisma/client/runtime/library").JsonValue;
        specialInstructions: string | null;
    }>;
    removeItem(userId: string, itemId: string): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        foodItemId: string;
        cartId: string;
        quantity: number;
        customizationItems: import("@prisma/client/runtime/library").JsonValue;
        specialInstructions: string | null;
    }>;
    clearCart(userId: string): Promise<{
        message: string;
    } | undefined>;
    validateCartForCheckout(userId: string): Promise<{
        isValid: boolean;
        itemTotal: number;
        itemCount: number;
        taxAmount: number;
        platformFee: number;
        deliveryFee: number;
        grandTotal: number;
    }>;
}
