import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
    credentials: true,
  },
  namespace: '/',
  transports: ['websocket', 'polling'],
})
export class OrderGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(OrderGateway.name);

  private readonly connectedClients = new Map<string, { userId: string; role: string }>();

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: Socket): Promise<void> {
    try {
      const token =
        client.handshake.auth?.token ||
        client.handshake.query?.token ||
        client.handshake.headers?.authorization?.replace('Bearer ', '');

      if (!token) {
        this.logger.warn(`Client ${client.id} connected without token — disconnecting`);
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token as string);
      const userId: string = payload.sub ?? payload.userId ?? payload.id;
      const role: string = payload.role ?? 'user';

      client.data = { userId, role };
      this.connectedClients.set(client.id, { userId, role });

      // Per-user room so server can push notifications/order alerts to a
      // specific customer without polling. Admins also join the admins room.
      try {
        client.join(`user_${userId}`);
        if (role === 'admin') client.join('admins');
      } catch {
        // join failures must never break auth flow
      }

      this.logger.log(`Client connected: ${client.id} (user: ${userId}, role: ${role})`);
    } catch (error) {
      this.logger.warn(`Client ${client.id} failed authentication — disconnecting`);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket): void {
    const clientData = this.connectedClients.get(client.id);
    if (clientData) {
      this.logger.log(
        `Client disconnected: ${client.id} (user: ${clientData.userId})`,
      );
    } else {
      this.logger.log(`Client disconnected: ${client.id}`);
    }
    this.connectedClients.delete(client.id);
  }

  @SubscribeMessage('join_order_room')
  handleJoinOrderRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { orderId: string },
  ): { event: string; data: { success: boolean; orderId: string } } {
    const room = `order_${data.orderId}`;
    client.join(room);

    this.logger.log(`Client ${client.id} joined room ${room}`);

    return {
      event: 'joined_order_room',
      data: { success: true, orderId: data.orderId },
    };
  }

  @SubscribeMessage('leave_order_room')
  handleLeaveOrderRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { orderId: string },
  ): { event: string; data: { success: boolean; orderId: string } } {
    const room = `order_${data.orderId}`;
    client.leave(room);

    this.logger.log(`Client ${client.id} left room ${room}`);

    return {
      event: 'left_order_room',
      data: { success: true, orderId: data.orderId },
    };
  }

  emitOrderStatusUpdate(
    orderId: string,
    status: string,
    data: Record<string, unknown> = {},
  ): void {
    const room = `order_${orderId}`;
    this.server.to(room).emit('order_status_update', {
      orderId,
      status,
      timestamp: new Date().toISOString(),
      ...data,
    });

    this.logger.log(`Emitted order_status_update to room ${room}: ${status}`);
  }

  emitNewOrderAlert(chefId: string, order: Record<string, unknown>): void {
    const room = `chef_${chefId}`;
    this.server.to(room).emit('new_order', {
      order,
      timestamp: new Date().toISOString(),
    });

    this.logger.log(`Emitted new_order alert to chef ${chefId}`);
  }

  broadcastToAdmins(event: string, data: Record<string, unknown>): void {
    this.server.to('admins').emit(event, {
      ...data,
      timestamp: new Date().toISOString(),
    });

    this.logger.log(`Broadcast ${event} to admins`);
  }

  /**
   * Realtime notification push to a single customer.
   * Best-effort: FCM + inbox polling remain fallbacks, so emit failures
   * must never throw.
   */
  emitNotificationToUser(
    userId: string,
    notification: Record<string, unknown>,
  ): void {
    try {
      this.server.to(`user_${userId}`).emit('notification', {
        ...notification,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      this.logger.warn(
        `Failed to emit notification to user ${userId}: ${(error as Error).message}`,
      );
    }
  }

  /**
   * Realtime push of an admin broadcast to every targeted customer room.
   */
  emitNotificationBroadcast(
    userIds: string[],
    notification: Record<string, unknown>,
  ): void {
    try {
      for (const userId of userIds) {
        this.server.to(`user_${userId}`).emit('notification', {
          ...notification,
          timestamp: new Date().toISOString(),
        });
      }
    } catch (error) {
      this.logger.warn(
        `Failed to emit broadcast notification: ${(error as Error).message}`,
      );
    }
  }

  joinChefRoom(client: Socket, chefId: string): void {
    const room = `chef_${chefId}`;
    client.join(room);
    this.logger.log(`Client ${client.id} joined chef room ${room}`);
  }

  joinAdminRoom(client: Socket): void {
    client.join('admins');
    this.logger.log(`Client ${client.id} joined admins room`);
  }

  getClientsByUserId(userId: string): Socket[] {
    const sockets: Socket[] = [];
    this.connectedClients.forEach((data, clientId) => {
      if (data.userId === userId) {
        const socket = this.server.sockets.sockets.get(clientId);
        if (socket) {
          sockets.push(socket);
        }
      }
    });
    return sockets;
  }
}
