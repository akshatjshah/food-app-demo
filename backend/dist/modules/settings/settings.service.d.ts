import { PrismaService } from '../../config/prisma.service';
export declare class SettingsService {
    private prisma;
    constructor(prisma: PrismaService);
    private isSecretKey;
    get(key: string): Promise<{
        key: string;
        value: string;
        valueType: string;
    } | null>;
    getAll(): Promise<{
        key: string;
        value: string;
        valueType: string;
        description: string | null;
        updatedAt: Date;
    }[]>;
    set(key: string, value: string, valueType?: string, description?: string): Promise<{
        key: string;
        value: string;
        valueType: string;
        description: string | null;
        updatedAt: Date;
    }>;
    delete(key: string): Promise<{
        key: string;
        value: string;
        valueType: string;
        description: string | null;
        updatedAt: Date;
    }>;
}
