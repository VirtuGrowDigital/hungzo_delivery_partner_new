import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
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
            navIcon(Icons.person_outline, 2),
          ],
        ),
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
