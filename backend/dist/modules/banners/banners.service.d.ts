import { PrismaService } from '../../config/prisma.service';
export declare class BannersService {
    private prisma;
    constructor(prisma: PrismaService);
    findActive(): Promise<{
        id: string;
        createdAt: Date;
        isActive: boolean;
        title: string;
        imageUrl: string;
        displayOrder: number;
        startDate: Date;
        endDate: Date;
        subtitle: string | null;
        clickAction: string | null;
        actionValue: string | null;
    }[]>;
    findAll(): Promise<{
        id: string;
        createdAt: Date;
        isActive: boolean;
        title: string;
        imageUrl: string;
        displayOrder: number;
        startDate: Date;
        endDate: Date;
        subtitle: string | null;
        clickAction: string | null;
        actionValue: string | null;
    }[]>;
    create(data: any): Promise<{
        id: string;
        createdAt: Date;
        isActive: boolean;
        title: string;
        imageUrl: string;
        displayOrder: number;
        startDate: Date;
        endDate: Date;
        subtitle: string | null;
        clickAction: string | null;
        actionValue: string | null;
    }>;
    update(id: string, data: any): Promise<{
        id: string;
        createdAt: Date;
        isActive: boolean;
        title: string;
        imageUrl: string;
        displayOrder: number;
        startDate: Date;
        endDate: Date;
        subtitle: string | null;
        clickAction: string | null;
        actionValue: string | null;
    }>;
    remove(id: string): Promise<{
        id: string;
        createdAt: Date;
        isActive: boolean;
        title: string;
        imageUrl: string;
        displayOrder: number;
        startDate: Date;
        endDate: Date;
        subtitle: string | null;
        clickAction: string | null;
        actionValue: string | null;
    }>;
}
