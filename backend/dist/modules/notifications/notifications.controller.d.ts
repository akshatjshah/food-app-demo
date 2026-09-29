import { NotificationsService } from './notifications.service';
declare class SendTestDto {
    userId: string;
    title: string;
    body: string;
}
export declare class NotificationsController {
    private notificationsService;
    constructor(notificationsService: NotificationsService);
    findAll(req: any, skip?: string, take?: string): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    }[]>;
    getUnreadCount(req: any): Promise<{
        count: number;
    }>;
    markRead(req: any, id: string): Promise<{
        id: string;
        title: string;
        body: string;
        type: string;
        reference_id: string | null;
        is_read: boolean;
        created_at: Date;
    }>;
    markAllRead(req: any): Promise<{
        message: string;
    }>;
    removeAll(req: any): Promise<{
        message: string;
        count: number;
    }>;
    sendTest(dto: SendTestDto): Promise<{
        success: boolean;
        message: string;
    }>;
}
export {};
