import { DeliverySlotsService } from './delivery-slots.service';
export declare class DeliverySlotsController {
    private deliverySlotsService;
    constructor(deliverySlotsService: DeliverySlotsService);
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
    create(dto: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        isActive: boolean;
        displayOrder: number;
        startTime: string;
        endTime: string;
        maxOrders: number;
    }>;
    update(id: string, dto: any): Promise<{
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
