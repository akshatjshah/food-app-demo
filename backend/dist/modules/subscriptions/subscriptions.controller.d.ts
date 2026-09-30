import { SubscriptionsService } from './subscriptions.service';
export declare class SubscriptionsController {
    private subscriptionsService;
    constructor(subscriptionsService: SubscriptionsService);
    findAll(): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        imageUrl: string | null;
        displayOrder: number;
        price: import("@prisma/client/runtime/library").Decimal;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: import("@prisma/client/runtime/library").JsonValue;
    }[]>;
    findAllAdmin(): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        imageUrl: string | null;
        displayOrder: number;
        price: import("@prisma/client/runtime/library").Decimal;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: import("@prisma/client/runtime/library").JsonValue;
    }[]>;
    createPlan(dto: any): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        imageUrl: string | null;
        displayOrder: number;
        price: import("@prisma/client/runtime/library").Decimal;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: import("@prisma/client/runtime/library").JsonValue;
    }>;
    updatePlan(id: string, dto: any): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        imageUrl: string | null;
        displayOrder: number;
        price: import("@prisma/client/runtime/library").Decimal;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: import("@prisma/client/runtime/library").JsonValue;
    }>;
    removePlan(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        imageUrl: string | null;
        displayOrder: number;
        price: import("@prisma/client/runtime/library").Decimal;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: import("@prisma/client/runtime/library").JsonValue;
    }>;
    getMy(req: any): Promise<({
        subscription: {
            description: string | null;
            name: string;
            id: string;
            createdAt: Date;
            isActive: boolean;
            imageUrl: string | null;
            displayOrder: number;
            price: import("@prisma/client/runtime/library").Decimal;
            durationDays: number;
            mealsCount: number;
            mealType: string;
            benefits: import("@prisma/client/runtime/library").JsonValue;
        };
    } & {
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        subscriptionId: string;
        startDate: Date;
        endDate: Date;
        mealsRemaining: number;
        skipDates: import("@prisma/client/runtime/library").JsonValue;
    })[]>;
    subscribe(req: any, subscriptionId: string): Promise<{
        subscription: {
            description: string | null;
            name: string;
            id: string;
            createdAt: Date;
            isActive: boolean;
            imageUrl: string | null;
            displayOrder: number;
            price: import("@prisma/client/runtime/library").Decimal;
            durationDays: number;
            mealsCount: number;
            mealType: string;
            benefits: import("@prisma/client/runtime/library").JsonValue;
        };
    } & {
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        subscriptionId: string;
        startDate: Date;
        endDate: Date;
        mealsRemaining: number;
        skipDates: import("@prisma/client/runtime/library").JsonValue;
    }>;
    pause(id: string, req: any): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        subscriptionId: string;
        startDate: Date;
        endDate: Date;
        mealsRemaining: number;
        skipDates: import("@prisma/client/runtime/library").JsonValue;
    }>;
    resume(id: string, req: any): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        subscriptionId: string;
        startDate: Date;
        endDate: Date;
        mealsRemaining: number;
        skipDates: import("@prisma/client/runtime/library").JsonValue;
    }>;
    skipDay(id: string, req: any, date: string): Promise<{
        updatedAt: Date;
        id: string;
        createdAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        subscriptionId: string;
        startDate: Date;
        endDate: Date;
        mealsRemaining: number;
        skipDates: import("@prisma/client/runtime/library").JsonValue;
    }>;
}
