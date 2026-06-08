import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_constants.dart';

class DriverSocketService {
  io.Socket? _socket;

  void connect({
    required String token,
    required String driverId,
    void Function(Map<String, dynamic> payload)? onNewOrder,
    void Function(Map<String, dynamic> payload)? onDriverRestrictionUpdated,
    void Function(String orderId)? onOrderTaken,
    void Function(String orderId)? onOrderDelivered,
    void Function(String orderId)? onOrderCancelled,
    void Function(String orderId)? onPaymentSuccess,
    void Function(String orderId)? onOrderRefreshRequired,
    void Function(String orderId, double lat, double lng)? onLocationUpdate,
  }) {
    if (_socket?.connected == true) {
      _socket!.emit("joinDriverRoom", driverId);
      return;
    }

    _socket = io.io(
      ApiConstants.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth({"token": token})
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit("joinDriverRoom", driverId);
    });

    _socket!.on("newOrder", (data) {
      if (data is Map) {
        onNewOrder?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on("driverRestrictionUpdated", (data) {
      if (data is Map) {
        onDriverRestrictionUpdated?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on("orderTaken", (data) {
      final orderId = data is Map ? data["orderId"]?.toString() : null;
      if (orderId != null && orderId.isNotEmpty) {
        onOrderTaken?.call(orderId);
      }
    });

    _socket!.on("orderDelivered", (data) {
      final orderId = data is Map ? data["orderId"]?.toString() : null;
      if (orderId != null && orderId.isNotEmpty) {
        onOrderDelivered?.call(orderId);
      }
    });

    _socket!.on("orderCancelled", (data) {
      final orderId = data is Map ? data["orderId"]?.toString() : null;
      if (orderId != null && orderId.isNotEmpty) {
        onOrderCancelled?.call(orderId);
      }
    });

    _socket!.on("paymentSuccess", (data) {
      final orderId = data is Map ? data["orderId"]?.toString() : null;
      if (orderId != null && orderId.isNotEmpty) {
        onPaymentSuccess?.call(orderId);
      }
    });

    _socket!.on("orderRefreshRequired", (data) {
      final orderId = data is Map ? data["orderId"]?.toString() : null;
      if (orderId != null && orderId.isNotEmpty) {
        onOrderRefreshRequired?.call(orderId);
      }
    });

    _socket!.on("driverLocationUpdated", (data) {
      if (data is! Map) return;

      final orderId = data["orderId"]?.toString();
      final location = data["location"];

      if (orderId == null || location is! Map) return;

      final lat = (location["lat"] as num?)?.toDouble();
      final lng = (location["lng"] as num?)?.toDouble();

      if (lat != null && lng != null) {
        onLocationUpdate?.call(orderId, lat, lng);
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
