import { CouponsService } from './coupons.service';
import { CreateCouponDto } from './dto/create-coupon.dto';
export declare class CouponsController {
    private couponsService;
    constructor(couponsService: CouponsService);
    validate(body: {
        code: string;
        orderValue: number;
    }, req: any): Promise<{
        valid: boolean;
        message: string;
        discount?: undefined;
        couponCode?: undefined;
    } | {
        valid: boolean;
        discount: number;
        couponCode: string;
        message?: undefined;
    }>;
    findAll(): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        isActive: boolean;
        expiresAt: Date;
        code: string;
        discountType: string;
        discountValue: import("@prisma/client/runtime/library").Decimal;
        minOrderValue: import("@prisma/client/runtime/library").Decimal | null;
        maxDiscountValue: import("@prisma/client/runtime/library").Decimal | null;
        maxUses: number | null;
        maxUsesPerUser: number | null;
        currentUses: number;
        isFirstOrderOnly: boolean;
    }[]>;
    create(dto: CreateCouponDto): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        isActive: boolean;
        expiresAt: Date;
        code: string;
        discountType: string;
        discountValue: import("@prisma/client/runtime/library").Decimal;
        minOrderValue: import("@prisma/client/runtime/library").Decimal | null;
        maxDiscountValue: import("@prisma/client/runtime/library").Decimal | null;
        maxUses: number | null;
        maxUsesPerUser: number | null;
        currentUses: number;
        isFirstOrderOnly: boolean;
    }>;
    update(id: string, dto: any): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        isActive: boolean;
        expiresAt: Date;
        code: string;
        discountType: string;
        discountValue: import("@prisma/client/runtime/library").Decimal;
        minOrderValue: import("@prisma/client/runtime/library").Decimal | null;
        maxDiscountValue: import("@prisma/client/runtime/library").Decimal | null;
        maxUses: number | null;
        maxUsesPerUser: number | null;
        currentUses: number;
        isFirstOrderOnly: boolean;
    }>;
    remove(id: string): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        isActive: boolean;
        expiresAt: Date;
        code: string;
        discountType: string;
        discountValue: import("@prisma/client/runtime/library").Decimal;
        minOrderValue: import("@prisma/client/runtime/library").Decimal | null;
        maxDiscountValue: import("@prisma/client/runtime/library").Decimal | null;
        maxUses: number | null;
        maxUsesPerUser: number | null;
        currentUses: number;
        isFirstOrderOnly: boolean;
    }>;
}
