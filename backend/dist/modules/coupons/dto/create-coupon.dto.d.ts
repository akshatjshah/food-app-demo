export declare class CreateCouponDto {
    code: string;
    description?: string;
    discountType: string;
    discountValue: number;
    minOrderValue?: number;
    maxDiscountValue?: number;
    maxUses?: number;
    maxUsesPerUser?: number;
    isFirstOrderOnly?: boolean;
    isActive?: boolean;
    expiresAt: string;
}
