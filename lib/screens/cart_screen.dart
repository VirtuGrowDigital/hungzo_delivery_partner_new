import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';
import 'package:hungzo_delivery_partner/screens/select%20_location%20_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/cart_controller.dart';
import '../utils/color_constants.dart';
import '../utils/ImageConstant.dart';
import 'home_view.dart';
import '../bindings/home_binding.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {

        /// 🔥 SHIMMER (ONLY WHEN LOADING & EMPTY)
        if (controller.isLoading.value &&
            controller.cartItems.isEmpty) {
          return _cartShimmer();
        }

        /// ✅ EMPTY CART
        if (controller.cartItems.isEmpty) {
          return _emptyCartView(context);
        }

        /// ✅ REAL DATA
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 50),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchCart,
                  child: ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    children: controller.cartItems
                        .map(
                          (item) => CartItemTile(
                        item: item,
                        controller: controller,
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),

              const Divider(height: 30),
              Obx(() => _priceRow('Subtotal', controller.subtotal.value)),
              Obx(() => _priceRow('Delivery Fee', controller.deliveryFee.value)),
              Obx(() => _priceRow('Platform Fee', controller.platformFee.value)),
              const Divider(),
              const Divider(),

              Obx(() => _priceRow(
                'Total',
                controller.totalAmount.value,
                isBold: true,
                big: true,
              )),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const SelectLocationScreen());
                  },
                  child: const Text(
                    'Proceed to Payment',
                    style:
                    TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// ---------------- SHIMMER UI ----------------
  Widget _cartShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade200,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  /// ---------------- EMPTY CART UI ----------------
  Widget _emptyCartView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 220,
            child: Image.asset(ImageConstant.emptyCart),
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: "Your Cart is "),
                TextSpan(
                  text: "Empty",
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add item to get started",
            style: TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Get.offAll(
                      () => const DeliveryHomeScreen(),
                  binding: HomeBinding(),
                );
              },
              child: const Text(
                'Go back to home',
                style:
                TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      double value, {
        bool isBold = false,
        bool big = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: big ? 18 : 14,
              fontWeight:
              isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: big ? 20 : 14,
              fontWeight:
              isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
