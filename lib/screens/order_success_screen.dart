import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';
import '../bindings/home_binding.dart';
import '../utils/color_constants.dart';
import '../utils/ImageConstant.dart';
import 'home_view.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              /// ✅ SUCCESS ICON
              SizedBox(
                height: 140,
                width: 140,
                child: Image.asset(ImageConstant.orderSuccess),
              ),

              const SizedBox(height: 32),

              /// TITLE
              const Text(
                "Your order has been\nsuccessfully placed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              /// SUBTITLE
              const Text(
                "Sit and relax while your order is being worked on.\n"
                    "It’ll take 5 min before you get it",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              /// GO HOME BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(
                          () => const DeliveryHomeScreen(),
                      binding: HomeBinding(),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Go back to home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Decorative dot
  static Widget _dot() {
    return Container(
      height: 8,
      width: 8,
      decoration: const BoxDecoration(
        color: ColorConstants.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
