import { PrismaService } from '../../config/prisma.service';
export declare class CategoriesService {
    private prisma;
    constructor(prisma: PrismaService);
    findAllActive(): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }[]>;
    findAll(): Promise<({
        _count: {
            foodItems: number;
        };
    } & {
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    })[]>;
    findOne(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    create(data: {
        name: string;
        icon?: string;
        displayOrder?: number;
        imageUrl?: string;
        description?: string;
        isFeatured?: boolean;
    }): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    update(id: string, data: {
        name?: string;
        icon?: string;
        displayOrder?: number;
        isActive?: boolean;
        imageUrl?: string;
        description?: string;
        isFeatured?: boolean;
    }): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    reorder(items: {
        id: string;
        displayOrder: number;
    }[]): Promise<{
        message: string;
    }>;
    deactivate(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    activate(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        icon: string;
        imageUrl: string | null;
        isFeatured: boolean;
        displayOrder: number;
    }>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
