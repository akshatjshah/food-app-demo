import { WishlistService } from './wishlist.service';
export declare class WishlistController {
    private wishlistService;
    constructor(wishlistService: WishlistService);
    findAll(req: any): Promise<{
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
    toggle(req: any, foodItemId: string): Promise<{
        added: boolean;
    }>;
}
