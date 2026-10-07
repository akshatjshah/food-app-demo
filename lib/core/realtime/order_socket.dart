import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../storage/local_storage.dart';

/// Genuine realtime order channel (Socket.IO, no polling/timers).
///
/// Backend emits `order_status_update` with { orderId, newStatus|status }
/// to the order room, the owner's user room, and the admins room.
/// The customer app authenticates with its JWT, so user-room events arrive
/// without joining per-order rooms. The tracking screen additionally joins
/// its order room for targeted updates.
///
/// Usage:
///   OrderSocket.instance.connect();
///   OrderSocket.instance.statusStream.listen((e) => ...);
class OrderStatusEvent {
  final String orderId;
  final String status;
  OrderStatusEvent({required this.orderId, required this.status});
}

class OrderSocket {
  OrderSocket._();
  static final OrderSocket instance = OrderSocket._();

  io.Socket? _socket;
  final StreamController<OrderStatusEvent> _controller =
      StreamController<OrderStatusEvent>.broadcast();
  final Set<String> _joinedOrders = {};

  Stream<OrderStatusEvent> get statusStream => _controller.stream;
  bool get isConnected => _socket?.connected ?? false;

  static String socketUrl() {
    final base = ApiConstants.baseUrl;
    // Socket.IO serves at the server root, not under /api/v1.
    return base.replaceAll(RegExp(r'/api/v1/?$'), '');
  }

  /// Connect (or re-authenticate) with the current access token.
  /// Safe to call repeatedly; only one socket ever lives.
  void connect() {
    final token = LocalStorage.getAccessToken();
    if (token == null || token.isEmpty) return;
    if (_socket?.connected == true) return;
    try {
      _socket?.dispose();
    } catch (_) {}
    _joinedOrders.clear();

    final socket = io.io(
      socketUrl(),
      io.OptionBuilder()
          .setAuth({'token': token})
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );
    _socket = socket;

    socket.on('order_status_update', (dynamic payload) {
      try {
        final map = payload is Map
            ? Map<String, dynamic>.from(payload)
            : <String, dynamic>{};
        final orderId = map['orderId']?.toString() ?? '';
        final status = (map['newStatus'] ?? map['status'])?.toString() ?? '';
        if (orderId.isEmpty || status.isEmpty) return;
        if (!_controller.isClosed) {
          _controller.add(OrderStatusEvent(orderId: orderId, status: status));
        }
      } catch (_) {}
    });

    socket.on('reconnect', (_) {
      // Re-join order rooms after reconnect so tracking keeps streaming.
      for (final orderId in _joinedOrders.toList()) {
        try {
          socket.emit('join_order_room', {'orderId': orderId});
        } catch (_) {}
      }
    });

    socket.connect();
  }

  void joinOrder(String orderId) {
    _joinedOrders.add(orderId);
    try {
      _socket?.emit('join_order_room', {'orderId': orderId});
    } catch (_) {}
  }

  void leaveOrder(String orderId) {
    _joinedOrders.remove(orderId);
    try {
      _socket?.emit('leave_order_room', {'orderId': orderId});
    } catch (_) {}
  }

  void disconnect() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _joinedOrders.clear();
  }
}
