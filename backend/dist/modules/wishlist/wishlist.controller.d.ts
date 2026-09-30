import { WishlistService } from './wishlist.service';
export declare class WishlistController {
    private wishlistService;
    constructor(wishlistService: WishlistService);
    findAll(req: any): Promise<{
        foodItem: {
            price: number;
            rating: number | null;
            name: string;
            id: string;
            isVeg: boolean;
            imageUrls: import("@prisma/client/runtime/library").JsonValue;
        };
        id: string;
        createdAt: Date;
        userId: string;
        foodItemId: string;
    }[]>;
    toggle(req: any, foodItemId: string): Promise<{
        added: boolean;
    }>;
}
