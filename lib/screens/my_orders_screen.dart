import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/constants.dart';
import '../utils/color_constants.dart';
import 'order_details_screen.dart';

/// =====================
/// MY ORDERS SCREEN
/// =====================

class MyOrdersScreen extends StatelessWidget {
  MyOrdersScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerOrderCard(),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (_, index) {
              final order = controller.orders[index];
              return _orderCard(order);
            },
          ),
        );
      }),
    );
  }

  /// ================= ORDER CARD =================

  Widget _orderCard(OrderModel order) {
    final utcTime = DateTime.parse(order.createdAt);
    final istTime = utcTime.toLocal(); // Converts UTC to device local (India)

    final date = DateFormat("dd MMM yyyy, hh:mm a")
        .format(istTime);


    final String status = order.displayStatus;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case "Cancelled":
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      case "Refunded":
        statusColor = Colors.green;
        statusIcon = Icons.currency_rupee;
        break;
      case "Returned":
        statusColor = Colors.orange;
        statusIcon = Icons.keyboard_return;
        break;
      case "Delivered":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Out for Delivery":
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case "Accepted":
        statusColor = Colors.deepPurple;
        statusIcon = Icons.inventory_2;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// DATE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              /// Modern Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// ITEMS
          ...order.items.map((item) {
            return InkWell(
              onTap: () {
                Get.to(() => OrderDetailsScreen(
                  order: order,
                  selectedItem: item,
                ));
              },
              child: _orderItem(item, order),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// ================= ORDER ITEM =================

  Widget _orderItem(OrderItem item, OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image.isNotEmpty
                ? Image.network(
              item.image,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.qty}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
            ).format(order.totalAmount),
          )

        ],
      ),
    );
  }

  /// ================= SHIMMER =================

  Widget _shimmerOrderCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(height: 50),
            _shimmerItem(),
            _shimmerItem(),
          ],
        ),
      ),
    );
  }

  Widget _shimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(height: 50, width: 50, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Container(height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 80, color: Colors.white),
              ],
            ),
          ),
          Container(height: 16, width: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported),
    );
  }
}

/// =====================
/// CONTROLLER
/// =====================

class OrdersController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String apiUrl = "${ApiConstants.baseURL}orders/my";

  String? token;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    token = await _storage.read(key: Constants.accessToken);

    if (token == null || token!.isEmpty) {
      Get.snackbar("Auth Error", "Please login again");
      return;
    }

    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = OrderResponse.fromJson(jsonData);
        orders.assignAll(responseModel.orders);
      } else {
        Get.snackbar("Error", "Failed to load orders");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}

/// =====================
/// MODELS
/// =====================

class OrderResponse {
  final bool success;
  final List<OrderModel> orders;

  OrderResponse({required this.success, required this.orders});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'] ?? false,
      orders: (json['orders'] as List? ?? [])
          .map((x) => OrderModel.fromJson(x))
          .toList(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderStatus;
  final String paymentStatus;
  final String createdAt;
  final List<OrderItem> items;
  final double totalAmount; // 👈 ADD THIS


  OrderModel({
    required this.id,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
    required this.totalAmount,
  });

  /// Derived Status Logic
  String get displayStatus {
    if (items.any((item) => item.refunded)) {
      return "Refunded";
    }
    if (items.any((item) => item.returned)) {
      return "Returned";
    }
    return orderStatus;
  }

  bool get isOngoing =>
      displayStatus == "Pending" ||
          displayStatus == "Accepted" ||
          displayStatus == "Out for Delivery";

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((x) => OrderItem.fromJson(x))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),

    );
  }
}

class OrderItem {
  final String orderItemId;
  final String productId;
  final String name;
  final int qty;
  final int returnedQty;
  final double price;
  final double total;
  final String image;

  final String? returnStatus;
  final bool returned;
  final bool refunded;
  final double refundAmount;

  OrderItem({
    required this.orderItemId,
    required this.productId,
    required this.name,
    required this.qty,
    required this.returnedQty,
    required this.price,
    required this.total,
    required this.image,
    required this.returnStatus,
    required this.returned,
    required this.refunded,
    required this.refundAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];

    String imageUrl = '';
    String productId = '';

    if (product != null) {
      productId = product['_id'] ?? '';
      if (product['images'] is List &&
          product['images'].isNotEmpty) {
        imageUrl = product['images'][0];
      }
    }

    return OrderItem(
      orderItemId: json['_id'] ?? '',
      productId: productId,
      name: json['productName'] ?? '',
      qty: json['quantity'] ?? 0,
      returnedQty: json['returnedQuantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      image: imageUrl,
      returnStatus: json['returnStatus'],
      returned: json['returned'] ?? false,
      refunded: json['refunded'] ?? false,
      refundAmount: (json['refundAmount'] ?? 0).toDouble(),
    );
  }
}
