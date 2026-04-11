import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom Bar
          Container(
            height: 70,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navIcon(Icons.home, 0),
                navIcon(Icons.shopping_cart_outlined, 1),
                const SizedBox(width: 50), // space for center button
                navIcon(Icons.notifications_none, 2),
                navIcon(Icons.person_outline, 3),
              ],
            ),
          ),

          // Center Floating Button
          Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () => controller.changeTab(2),
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    backgroundImage:
                    const AssetImage("assets/logo.png"),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Icon(
        icon,
        size: 26,
        color: controller.bottomIndex.value == index
            ? Colors.green
            : Colors.grey,
      ),
    );
  }
}
