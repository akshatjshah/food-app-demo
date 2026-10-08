export declare class CreateFoodDto {
    categoryId: string;
    name: string;
    description?: string;
    price: number;
    originalPrice?: number;
    imageUrls?: string[];
    videoUrl?: string;
    calories?: number;
    preparationTimeMinutes?: number;
    isVeg?: boolean;
    isJainAvailable?: boolean;
    isFastingFriendly?: boolean;
    isBestseller?: boolean;
    isFeatured?: boolean;
    isAvailable?: boolean;
    subcategory?: string;
    mealTags?: string[];
    isHealthyPick?: boolean;
    stock?: number;
    displayOrder?: number;
    tags?: string[];
    isActive?: boolean;
}
