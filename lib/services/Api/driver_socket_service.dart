import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_constants.dart';

class DriverSocketService {
  late IO.Socket socket;
  final List<IncomingOrder> _orders = [];
  final StreamController<List<IncomingOrder>> _orderController = StreamController.broadcast();

  Stream<List<IncomingOrder>> get orderStream => _orderController.stream;

  void connect(String token) {
    socket = IO.io(
      "https://api.hungzo.in/drivers",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print("✅ Socket Connected: ${socket.id}"));
    socket.onDisconnect((_) => print("❌ Socket Disconnected"));

    socket.on("newOrder", (data) {
      print("Data = $data");
      final order = IncomingOrder.fromJson(data);
      _orders.add(order);
      _orderController.add(List.from(_orders));
    });

    socket.on("orderTaken", (data) {
      _orders.removeWhere((o) => o.id == data["orderId"]);
      _orderController.add(List.from(_orders));
    });

    socket.on("orderDelivered", (data) {
      _orders.removeWhere((o) => o.id == data["orderId"]);
      _orderController.add(List.from(_orders));
    });
  }

  Future<bool> acceptOrder(String orderId, String token) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseURL}driver/orders/$orderId/accept"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(res.body);
    if (data["success"] == true) {
      _orders.removeWhere((o) => o.id == orderId);
      _orderController.add(List.from(_orders));
      return true;
    }
    return false;
  }

  Future<bool> skipOrder(String orderId, String token) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseURL}driver/orders/$orderId/reject"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(res.body);
    if (data["success"] == true) {
      _orders.removeWhere((o) => o.id == orderId);
      _orderController.add(List.from(_orders));
      return true;
    }
    return false;
  }

  void dispose() {
    socket.dispose();
    _orderController.close();
  }
}

class IncomingOrder {
  final String id;
  final String phone;
  final String address;
  final double amount;

  IncomingOrder({
    required this.id,
    required this.phone,
    required this.address,
    required this.amount,
  });

  factory IncomingOrder.fromJson(Map<String, dynamic> json) {
    return IncomingOrder(
      id: json["orderId"],
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      amount: double.tryParse(json["amount"].toString()) ?? 0,
    );
  }
}
