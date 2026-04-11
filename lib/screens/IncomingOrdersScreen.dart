import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';


class IncomingOrdersScreen extends StatelessWidget {
  const IncomingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incoming Orders"),
      ),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(
            child: Text("No incoming orders yet."),
          );
        }

        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(order.id.substring(0, 2).toUpperCase()),
                ),
                title: Text("Order ID: ${order.id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.address),
                    const SizedBox(height: 4),
                    Text("Customer Phone: ${order.phone}"),
                  ],
                ),
                trailing: Text(
                  "₹${order.amount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}