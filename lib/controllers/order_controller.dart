import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/driver_order_model.dart';
import '../services/Api/driver_socket_service.dart';

class OrderController extends GetxController {
  static const Set<String> _visibleIncomingStatuses = {
    "Packed",
  };

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DriverSocketService socketService = DriverSocketService();

  final RxBool isLoading = false.obs;
  final RxBool isDashboardLoading = true.obs;
  final RxBool isActionLoading = false.obs;
  final RxBool isLocationSyncing = false.obs;
  final RxBool paymentCompleted = false.obs;

  final RxList<DriverOrderModel> incomingOrders = <DriverOrderModel>[].obs;
  final RxList<DriverOrderModel> orderHistory = <DriverOrderModel>[].obs;
  final Rxn<DriverOrderModel> activeOrder = Rxn<DriverOrderModel>();
  final RxString actionLabel = "".obs;

  final RxList<IncomingOrder> orders = <IncomingOrder>[].obs;

  Razorpay? _razorpay;
  String? _razorpayOrderId;
  String? _driverId;
  bool _socketConnected = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  @override
  void onReady() {
    super.onReady();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay?.clear();
    socketService.disconnect();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await _loadDriverIdentity();
    await refreshDashboard(showLoader: true);
    await _ensureSocketConnection();
  }

  Future<void> initializeDriverSession() async {
    await _bootstrap();
  }

  Future<void> _loadDriverIdentity() async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) return;

    final response = await http.get(
      Uri.parse("${ApiConstants.baseURL}driver/myProfile"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _driverId = data["profile"]?["driverId"]?.toString();
  }

  Future<void> _ensureSocketConnection() async {
    if (_socketConnected || _driverId == null) return;

    final token = await _storage.read(key: "accessToken");
    if (token == null) return;

    socketService.connect(
      token: token,
      driverId: _driverId!,
      onNewOrder: (payload) {
        final order = DriverOrderModel.fromJson(payload);
        if (!_shouldShowIncomingOrder(order)) return;
        final exists = incomingOrders.any(
          (item) => item.orderId == order.orderId,
        );
        if (!exists) {
          incomingOrders.insert(0, order);
          _syncIncomingOrderCards();
        }
      },
      onOrderTaken: (orderId) {
        incomingOrders.removeWhere((item) => item.orderId == orderId);
        _syncIncomingOrderCards();
      },
      onOrderDelivered: (orderId) async {
        if (activeOrder.value?.orderId == orderId) {
          activeOrder.value = null;
        }
        await refreshDashboard();
      },
      onOrderCancelled: (orderId) async {
        if (activeOrder.value?.orderId == orderId) {
          activeOrder.value = null;
        }
        await refreshDashboard();
      },
      onPaymentSuccess: (orderId) async {
        if (activeOrder.value?.orderId == orderId) {
          await refreshDashboard();
        }
      },
      onLocationUpdate: (orderId, lat, lng) {
        final current = activeOrder.value;
        if (current != null && current.orderId == orderId) {
          activeOrder.value = current.copyWith(driverLat: lat, driverLng: lng);
        }
      },
    );

    _socketConnected = true;
  }

  Future<void> refreshDashboard({bool showLoader = false}) async {
    if (showLoader) {
      isDashboardLoading.value = true;
    }

    try {
      await Future.wait([
        fetchIncomingOrders(),
        fetchCurrentOrder(),
        fetchOrderHistory(),
      ]);
    } finally {
      isDashboardLoading.value = false;
    }
  }

  Future<void> fetchIncomingOrders() async {
    final data = await _getJson(
      "${ApiConstants.baseURL}driver/orders/incoming",
    );
    if (data == null) return;

    final list = (data["orders"] as List<dynamic>? ?? const [])
        .map(
          (item) => DriverOrderModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(_shouldShowIncomingOrder)
        .toList();

    incomingOrders.assignAll(list);
    _syncIncomingOrderCards();
  }

  Future<void> fetchCurrentOrder() async {
    final data = await _getJson("${ApiConstants.baseURL}driver/orders/current");
    if (data == null) return;

    final rawOrder = data["order"];
    if (rawOrder == null) {
      activeOrder.value = null;
      return;
    }

    activeOrder.value = DriverOrderModel.fromJson(
      Map<String, dynamic>.from(rawOrder),
    );
  }

  Future<void> fetchOrderHistory() async {
    final data = await _getJson(
      "${ApiConstants.baseURL}driver/orders/history?limit=20",
    );
    if (data == null) return;

    final list = (data["orders"] as List<dynamic>? ?? const [])
        .map(
          (item) => DriverOrderModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    orderHistory.assignAll(list);
  }

  Future<bool> acceptIncomingOrder(String orderId) async {
    return _runOrderAction(
      label: "Accepting order...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/$orderId/accept",
        );
        if (data == null) return false;

        activeOrder.value = DriverOrderModel.fromJson(
          Map<String, dynamic>.from(data["order"]),
        );
        incomingOrders.removeWhere((item) => item.orderId == orderId);
        _syncIncomingOrderCards();
        return true;
      },
    );
  }

  Future<bool> pickActiveOrder() async {
    final order = activeOrder.value;
    if (order == null) return false;

    return _runOrderAction(
      label: "Marking order as picked up...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/${order.orderId}/pick",
        );
        if (data == null) return false;

        activeOrder.value = DriverOrderModel.fromJson(
          Map<String, dynamic>.from(data["order"]),
        );
        return true;
      },
    );
  }

  Future<bool> rejectActiveOrderDueToUser({String? reasonNote}) async {
    final order = activeOrder.value;
    if (order == null) return false;

    return _runOrderAction(
      label: "Rejecting delivery...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/${order.orderId}/reject",
          body: {
            "reasonCode": "USER_ISSUE",
            "reasonNote": (reasonNote ?? "").trim(),
          },
        );
        if (data == null) return false;

        activeOrder.value = null;
        await refreshDashboard();
        return true;
      },
    );
  }

  Future<bool> deliverActiveOrderCash() async {
    final order = activeOrder.value;
    if (order == null) return false;

    return _runOrderAction(
      label: "Completing cash delivery...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/${order.orderId}/deliver",
          body: {"paymentMode": "CASH"},
        );
        if (data == null) return false;

        activeOrder.value = null;
        await refreshDashboard();
        return true;
      },
    );
  }

  Future<bool> completePaidActiveOrder() async {
    final order = activeOrder.value;
    if (order == null) return false;

    return _runOrderAction(
      label: "Completing delivery...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/${order.orderId}/deliver",
        );
        if (data == null) return false;

        activeOrder.value = null;
        await refreshDashboard();
        return true;
      },
    );
  }

  Future<String?> requestQrPayment() async {
    final order = activeOrder.value;
    if (order == null) return null;

    String? qrUrl;

    final success = await _runOrderAction(
      label: "Generating QR payment...",
      action: () async {
        final data = await _postJson(
          "${ApiConstants.baseURL}driver/orders/${order.orderId}/deliver",
          body: {"paymentMode": "ONLINE"},
        );
        if (data == null) return false;

        qrUrl = data["qrUrl"]?.toString();
        final rawOrder = data["order"];
        if (rawOrder is Map<String, dynamic>) {
          activeOrder.value = DriverOrderModel.fromJson(rawOrder);
        } else {
          activeOrder.value = order.copyWith(
            deliveryPaymentStatus: "QR_PENDING",
            qrUrl: qrUrl,
          );
        }
        return true;
      },
    );

    return success ? qrUrl : null;
  }

  Future<bool> refreshActiveOrderStatus() async {
    await fetchCurrentOrder();
    return activeOrder.value?.paymentStatus == "paid" ||
        activeOrder.value?.deliveryPaymentStatus == "PAID";
  }

  Future<bool> syncActiveOrderLocation({
    required double lat,
    required double lng,
  }) async {
    final order = activeOrder.value;
    if (order == null) return false;

    isLocationSyncing.value = true;

    try {
      final data = await _putJson(
        "${ApiConstants.baseURL}driver/orders/${order.orderId}/location",
        body: {"lat": lat, "lng": lng},
      );

      if (data == null) return false;

      activeOrder.value = order.copyWith(driverLat: lat, driverLng: lng);
      return true;
    } finally {
      isLocationSyncing.value = false;
    }
  }

  Future<bool> _runOrderAction({
    required String label,
    required Future<bool> Function() action,
  }) async {
    isActionLoading.value = true;
    actionLabel.value = label;

    try {
      final success = await action();
      if (!success) {
        Get.snackbar(
          "Action failed",
          "Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return success;
    } finally {
      isActionLoading.value = false;
      actionLabel.value = "";
    }
  }

  void _syncIncomingOrderCards() {
    orders.assignAll(
      incomingOrders
          .map(
            (order) => IncomingOrder(
              id: order.orderId,
              phone: order.customerPhone,
              address: order.address,
              amount: order.amount,
            ),
          )
          .toList(),
    );
  }

  bool _shouldShowIncomingOrder(DriverOrderModel order) {
    return order.driverStatus == "WAITING_DRIVER" &&
        _visibleIncomingStatuses.contains(order.orderStatus);
  }

  Future<Map<String, dynamic>?> _getJson(String url) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>?> _postJson(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body ?? const {}),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>?> _putJson(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) return null;

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Map<String, dynamic>? _decodeResponse(http.Response response) {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    Get.snackbar(
      "Error",
      data["message"]?.toString() ?? "Something went wrong",
      snackPosition: SnackPosition.BOTTOM,
    );
    return null;
  }

  int get deliveredCount => orderHistory.length;

  double get deliveredAmount => orderHistory
      .where((item) => !item.isRejectedByUser)
      .fold(0, (sum, item) => sum + item.amount);

  DriverOrderModel? get latestDeliveredOrder {
    for (final order in orderHistory) {
      if (!order.isRejectedByUser) return order;
    }
    return null;
  }

  int get todayDeliveries {
    final now = DateTime.now();
    return orderHistory.where((order) {
      if (order.isRejectedByUser) return false;
      final deliveredAt = order.deliveredAt?.toLocal();
      return deliveredAt != null &&
          deliveredAt.year == now.year &&
          deliveredAt.month == now.month &&
          deliveredAt.day == now.day;
    }).length;
  }

  Future<void> placeOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    isLoading.value = true;
    paymentCompleted.value = false;

    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseURL}orders/place"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "shippingAddress": shippingAddress,
          "paymentMethod": paymentMethod,
          "location": {"lat": 0.0, "lng": 0.0},
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (paymentMethod == "ONLINE" && data["success"] == true) {
        _razorpayOrderId = data["razorpayOrderId"].toString();
        _openRazorpay(
          key: data["key"].toString(),
          amount: int.parse(data["amount"].toString()),
          razorpayOrderId: _razorpayOrderId!,
        );
      } else if (paymentMethod == "COD" && data["success"] == true) {
        paymentCompleted.value = true;
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (_) {
      isLoading.value = false;
    }
  }

  void _openRazorpay({
    required String key,
    required int amount,
    required String razorpayOrderId,
  }) {
    if (_razorpay == null) {
      isLoading.value = false;
      return;
    }

    final options = {
      "key": key,
      "amount": amount,
      "order_id": razorpayOrderId,
      "name": "Hungzo Foods",
      "description": "Order Payment",
      "theme": {"color": "#16AB88"},
    };

    try {
      _razorpay!.open(options);
    } catch (_) {
      isLoading.value = false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_razorpayOrderId == null) {
      isLoading.value = false;
      return;
    }

    await verifyPayment(
      razorpayOrderId: _razorpayOrderId!,
      razorpayPaymentId: response.paymentId ?? "",
      razorpaySignature: response.signature ?? "",
    );
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final token = await _storage.read(key: "accessToken");
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseURL}orders/verify-payment"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "razorpay_order_id": razorpayOrderId,
          "razorpay_payment_id": razorpayPaymentId,
          "razorpay_signature": razorpaySignature,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data["success"] == true) {
        paymentCompleted.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    Get.snackbar(
      "Payment Failed",
      response.message ?? "Unknown error occurred",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isLoading.value = false;
    Get.snackbar(
      "Wallet",
      response.walletName ?? "External wallet selected",
      snackPosition: SnackPosition.BOTTOM,
    );
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
}
