import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/order_controller.dart';
import '../controllers/profile_controller.dart';
import '../model/driver_order_model.dart';
import 'delivery_map_screen.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});

  final OrderController orderController = Get.find<OrderController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => orderController.refreshDashboard(),
      child: Obx(() {
        if (orderController.isDashboardLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeOrder = orderController.activeOrder.value;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            _header(),
            const SizedBox(height: 20),
            _summaryStrip(activeOrder),
            const SizedBox(height: 20),
            _activeDeliveryCard(context, activeOrder),
            const SizedBox(height: 24),
            _sectionTitle("Incoming Requests"),
            const SizedBox(height: 12),
            _incomingOrders(context),
            const SizedBox(height: 24),
            _sectionTitle("Recent Deliveries"),
            const SizedBox(height: 12),
            _recentDeliveryCard(orderController.latestDeliveredOrder),
          ],
        );
      }),
    );
  }

  Widget _header() {
    return Obx(() {
      final profile = profileController.profile.value;
      final name = profile?.name.isNotEmpty == true ? profile!.name : "Delivery Partner";
      final status = profile?.verificationStatus ?? "PENDING";

      return Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: (profile?.profilePic?.isNotEmpty ?? false)
                ? NetworkImage(profile!.profilePic!)
                : null,
            child: (profile?.profilePic?.isNotEmpty ?? false)
                ? null
                : const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $name",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Verification: $status",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => orderController.refreshDashboard(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      );
    });
  }

  Widget _summaryStrip(DriverOrderModel? activeOrder) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            "Delivered",
            orderController.deliveredCount.toString(),
            const Color(0xff1EB980),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            "Today",
            orderController.todayDeliveries.toString(),
            const Color(0xffFF8A3D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            "Active",
            activeOrder == null ? "0" : "1",
            const Color(0xff5D60F6),
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeDeliveryCard(BuildContext context, DriverOrderModel? activeOrder) {
    if (activeOrder == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "No active delivery",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              "Incoming orders will appear below as soon as they are assigned.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFFF0E5), Color(0xffFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Current Delivery",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              _pill(activeOrder.orderStatus),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Order #${activeOrder.orderId.substring(0, _safeShortLength(activeOrder.orderId))}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            activeOrder.customerName,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            activeOrder.address,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _infoLine(
                  Icons.payments_outlined,
                  activeOrder.paymentStatus == "paid"
                      ? "Payment received"
                      : activeOrder.isQrPending
                          ? "QR pending"
                          : "Collect payment",
                ),
              ),
              Expanded(
                child: _infoLine(
                  Icons.currency_rupee,
                  "Rs ${activeOrder.amount.toStringAsFixed(0)}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryMapScreen(orderId: activeOrder.orderId),
                  ),
                );
              },
              child: const Text("Open Live Delivery"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomingOrders(BuildContext context) {
    if (orderController.incomingOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "No incoming orders right now.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: orderController.incomingOrders.map((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    "Rs ${order.amount.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.address,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: orderController.isActionLoading.value
                      ? null
                      : () => orderController.acceptIncomingOrder(order.orderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1EB980),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    orderController.isActionLoading.value
                        ? orderController.actionLabel.value
                        : "Accept Order",
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _recentDeliveryCard(DriverOrderModel? order) {
    if (order == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "No deliveries completed yet.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final date = order.deliveredAt ?? order.createdAt;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.customerName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(order.address, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Text(
            date == null
                ? "Completed recently"
                : "Delivered ${DateFormat("dd MMM, hh:mm a").format(date.toLocal())}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffFF6B6B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffFF6B6B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  int _safeShortLength(String value) => value.length < 8 ? value.length : 8;
}
