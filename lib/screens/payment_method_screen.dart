import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import 'order_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String address;
  const PaymentMethodScreen({super.key, required this.address});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final OrderController orderController = Get.find<OrderController>();
  final RxInt selectedMethod = 1.obs;

  @override
  void initState() {
    super.initState();

    // 🔥 Setup listener for payment completion
    ever(orderController.paymentCompleted, (bool completed) {
      if (completed && mounted) {
        // Reset the flag
        orderController.paymentCompleted.value = false;

        // Navigate to success screen
        Get.offAll(() => const OrderSuccessScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation when payment is in progress
        if (orderController.isLoading.value) {
          Get.snackbar(
            "Please Wait",
            "Payment is in progress",
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment Method"),
          centerTitle: true,
        ),
        body: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Address Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shipping Address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Select Payment Method",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Online Payment Option
                Card(
                  elevation: 1,
                  child: RadioListTile<int>(
                    title: const Text("Online Payment"),
                    subtitle: const Text("Pay via UPI, Card, Wallet"),
                    secondary: const Icon(Icons.payment, color: Colors.green),
                    value: 1,
                    groupValue: selectedMethod.value,
                    onChanged: orderController.isLoading.value
                        ? null
                        : (int? v) {
                      if (v != null) selectedMethod.value = v;
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Cash on Delivery Option
                Card(
                  elevation: 1,
                  child: RadioListTile<int>(
                    title: const Text("Cash on Delivery"),
                    subtitle: const Text("Pay when you receive"),
                    secondary: const Icon(Icons.money, color: Colors.orange),
                    value: 2,
                    groupValue: selectedMethod.value,
                    onChanged: orderController.isLoading.value
                        ? null
                        : (int? v) {
                      if (v != null) selectedMethod.value = v;
                    },
                  ),
                ),

                const Spacer(),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: orderController.isLoading.value
                        ? null
                        : () {
                      orderController.placeOrder(
                        shippingAddress: widget.address,
                        paymentMethod: selectedMethod.value == 1
                            ? "ONLINE"
                            : "COD",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: orderController.isLoading.value
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text("Processing..."),
                      ],
                    )
                        : Text(
                      selectedMethod.value == 1
                          ? "Proceed to Payment"
                          : "Place Order",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }
}