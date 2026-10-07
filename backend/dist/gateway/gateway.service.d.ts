import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Server, Socket } from 'socket.io';
export declare class OrderGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly jwtService;
    private readonly configService;
    server: Server;
    private readonly logger;
    private readonly connectedClients;
    constructor(jwtService: JwtService, configService: ConfigService);
    handleConnection(client: Socket): Promise<void>;
    handleDisconnect(client: Socket): void;
    handleJoinOrderRoom(client: Socket, data: {
        orderId: string;
    }): {
        event: string;
        data: {
            success: boolean;
            orderId: string;
        };
    };
    handleLeaveOrderRoom(client: Socket, data: {
        orderId: string;
    }): {
        event: string;
        data: {
            success: boolean;
            orderId: string;
        };
    };
    emitOrderStatusUpdate(orderId: string, status: string, data?: Record<string, unknown>): void;
    emitNewOrderAlert(chefId: string, order: Record<string, unknown>): void;
    broadcastToAdmins(event: string, data: Record<string, unknown>): void;
    emitNotificationToUser(userId: string, notification: Record<string, unknown>): void;
    emitNotificationBroadcast(userIds: string[], notification: Record<string, unknown>): void;
    joinChefRoom(client: Socket, chefId: string): void;
    joinAdminRoom(client: Socket): void;
    getClientsByUserId(userId: string): Socket[];
}
