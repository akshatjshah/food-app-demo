import { PrismaService } from '../../config/prisma.service';
export declare class DeliverySlotsService {
    private prisma;
    constructor(prisma: PrismaService);
    findActive(): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }[]>;
    findAllAdmin(): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }[]>;
    create(data: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }>;
    update(id: string, data: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }>;
    remove(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }>;
}
