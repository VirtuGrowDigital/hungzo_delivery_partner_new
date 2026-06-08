import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hungzo_delivery_partner/constants/color_constants.dart';
import '../controllers/order_controller.dart';
import '../model/driver_order_model.dart';
import 'delivery_map_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return RefreshIndicator(
      onRefresh: () => controller.refreshDashboard(),
      child: Obx(() {
        if (controller.isDashboardLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            const Text(
              "Orders",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            if (controller.activeOrder.value != null) ...[
              _ActiveOrderBanner(order: controller.activeOrder.value!),
              const SizedBox(height: 20),
            ],
            if (controller.orderHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 64,
                      color: ColorConstants.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Delivered orders will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorConstants.textTertiary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...controller.orderHistory.map((order) {
                final deliveredAt = order.deliveredAt ?? order.createdAt;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.textPrimary,
                              ),
                            ),
                          ),
                          _statusChip(order.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Rs ${order.amount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: ColorConstants.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            deliveredAt == null
                                ? ""
                                : DateFormat("dd MMM, hh:mm a")
                                    .format(deliveredAt.toLocal()),
                            style: TextStyle(
                              color: ColorConstants.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  final DriverOrderModel order;

  const _ActiveOrderBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    final distanceLabel = controller.distanceToOrderLabel(order);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryMapScreen(orderId: order.orderId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorConstants.primary.withOpacity(0.1), ColorConstants.primary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstants.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: ColorConstants.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "One delivery is active right now.",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distanceLabel == null
                        ? "Tap to open live tracking."
                        : "Delivery $distanceLabel",
                    style: TextStyle(
                      color: ColorConstants.textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ColorConstants.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statusChip(String text) {
  Color backgroundColor;
  Color textColor;
  
  switch (text.toLowerCase()) {
    case 'delivered':
    case 'completed':
      backgroundColor = ColorConstants.successLight;
      textColor = ColorConstants.success;
      break;
    case 'pending':
    case 'processing':
      backgroundColor = ColorConstants.warningLight;
      textColor = ColorConstants.warning;
      break;
    case 'cancelled':
    case 'failed':
      backgroundColor = ColorConstants.errorLight;
      textColor = ColorConstants.error;
      break;
    default:
      backgroundColor = ColorConstants.primary50;
      textColor = ColorConstants.primary;
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}
