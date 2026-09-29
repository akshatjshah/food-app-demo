import { PrismaService } from '../../config/prisma.service';
export declare class WishlistService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(userId: string): Promise<{
        foodItem: {
            price: number;
            rating: number | null;
            id: string;
            name: string;
            imageUrls: import("@prisma/client/runtime/library").JsonValue;
            isVeg: boolean;
        };
        id: string;
        userId: string;
        foodItemId: string;
        createdAt: Date;
    }[]>;
    toggle(userId: string, foodItemId: string): Promise<{
        added: boolean;
    }>;
}
