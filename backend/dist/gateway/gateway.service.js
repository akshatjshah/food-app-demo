"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var OrderGateway_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderGateway = void 0;
const websockets_1 = require("@nestjs/websockets");
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const socket_io_1 = require("socket.io");
let OrderGateway = OrderGateway_1 = class OrderGateway {
    constructor(jwtService, configService) {
        this.jwtService = jwtService;
        this.configService = configService;
        this.logger = new common_1.Logger(OrderGateway_1.name);
        this.connectedClients = new Map();
    }
    async handleConnection(client) {
        try {
            const token = client.handshake.auth?.token ||
                client.handshake.query?.token ||
                client.handshake.headers?.authorization?.replace('Bearer ', '');
            if (!token) {
                this.logger.warn(`Client ${client.id} connected without token — disconnecting`);
                client.disconnect();
                return;
            }
            const payload = this.jwtService.verify(token);
            const userId = payload.sub ?? payload.userId ?? payload.id;
            const role = payload.role ?? 'user';
            client.data = { userId, role };
            this.connectedClients.set(client.id, { userId, role });
            try {
                client.join(`user_${userId}`);
                if (role === 'admin')
                    client.join('admins');
            }
            catch {
            }
            this.logger.log(`Client connected: ${client.id} (user: ${userId}, role: ${role})`);
        }
        catch (error) {
            this.logger.warn(`Client ${client.id} failed authentication — disconnecting`);
            client.disconnect();
        }
    }
    handleDisconnect(client) {
        const clientData = this.connectedClients.get(client.id);
        if (clientData) {
            this.logger.log(`Client disconnected: ${client.id} (user: ${clientData.userId})`);
        }
        else {
            this.logger.log(`Client disconnected: ${client.id}`);
        }
        this.connectedClients.delete(client.id);
    }
    handleJoinOrderRoom(client, data) {
        const room = `order_${data.orderId}`;
        client.join(room);
        this.logger.log(`Client ${client.id} joined room ${room}`);
        return {
            event: 'joined_order_room',
            data: { success: true, orderId: data.orderId },
        };
    }
    handleLeaveOrderRoom(client, data) {
        const room = `order_${data.orderId}`;
        client.leave(room);
        this.logger.log(`Client ${client.id} left room ${room}`);
        return {
            event: 'left_order_room',
            data: { success: true, orderId: data.orderId },
        };
    }
    emitOrderStatusUpdate(orderId, status, data = {}) {
        const room = `order_${orderId}`;
        this.server.to(room).emit('order_status_update', {
            orderId,
            status,
            timestamp: new Date().toISOString(),
            ...data,
        });
        this.logger.log(`Emitted order_status_update to room ${room}: ${status}`);
    }
    emitNewOrderAlert(chefId, order) {
        const room = `chef_${chefId}`;
        this.server.to(room).emit('new_order', {
            order,
            timestamp: new Date().toISOString(),
        });
        this.logger.log(`Emitted new_order alert to chef ${chefId}`);
    }
    broadcastToAdmins(event, data) {
        this.server.to('admins').emit(event, {
            ...data,
            timestamp: new Date().toISOString(),
        });
        this.logger.log(`Broadcast ${event} to admins`);
    }
    emitNotificationToUser(userId, notification) {
        try {
            this.server.to(`user_${userId}`).emit('notification', {
                ...notification,
                timestamp: new Date().toISOString(),
            });
        }
        catch (error) {
            this.logger.warn(`Failed to emit notification to user ${userId}: ${error.message}`);
        }
    }
    emitNotificationBroadcast(userIds, notification) {
        try {
            for (const userId of userIds) {
                this.server.to(`user_${userId}`).emit('notification', {
                    ...notification,
                    timestamp: new Date().toISOString(),
                });
            }
        }
        catch (error) {
            this.logger.warn(`Failed to emit broadcast notification: ${error.message}`);
        }
    }
    joinChefRoom(client, chefId) {
        const room = `chef_${chefId}`;
        client.join(room);
        this.logger.log(`Client ${client.id} joined chef room ${room}`);
    }
    joinAdminRoom(client) {
        client.join('admins');
        this.logger.log(`Client ${client.id} joined admins room`);
    }
    getClientsByUserId(userId) {
        const sockets = [];
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
};
exports.OrderGateway = OrderGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], OrderGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)('join_order_room'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Object)
], OrderGateway.prototype, "handleJoinOrderRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('leave_order_room'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Object)
], OrderGateway.prototype, "handleLeaveOrderRoom", null);
exports.OrderGateway = OrderGateway = OrderGateway_1 = __decorate([
    (0, websockets_1.WebSocketGateway)({
        cors: {
            origin: '*',
            methods: ['GET', 'POST'],
            credentials: true,
        },
        namespace: '/',
        transports: ['websocket', 'polling'],
    }),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        config_1.ConfigService])
], OrderGateway);
//# sourceMappingURL=gateway.service.js.map