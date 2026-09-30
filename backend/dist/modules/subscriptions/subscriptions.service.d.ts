import { PrismaService } from '../../config/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export declare class SubscriptionsService {
    private prisma;
    private notificationsService;
    constructor(prisma: PrismaService, notificationsService: NotificationsService);
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
    createPlan(data: {
        name: string;
        description?: string;
        price: number;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits?: string[];
        isActive?: boolean;
        displayOrder?: number;
        imageUrl?: string;
    }): Promise<{
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
    updatePlan(id: string, data: Partial<{
        name: string;
        description: string;
        price: number;
        durationDays: number;
        mealsCount: number;
        mealType: string;
        benefits: string[];
        isActive: boolean;
        displayOrder: number;
        imageUrl: string;
    }>): Promise<{
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
    getMy(userId: string): Promise<({
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
    subscribe(userId: string, subscriptionId: string): Promise<{
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
    pause(id: string, userId: string): Promise<{
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
    resume(id: string, userId: string): Promise<{
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
    skipDay(id: string, userId: string, date: string): Promise<{
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
