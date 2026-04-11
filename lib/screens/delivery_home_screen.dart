import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'AccountScreen.dart';
import 'HomeContent.dart';
import 'OrdersScreen.dart';
import '../controllers/profile_controller.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() =>
      _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState
    extends State<DeliveryHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

     if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
              () => ProfileController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_shape.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      HomeContent(),
                      const OrdersScreen(),
                      const AccountScreen(), // ✅ opens on tab click
                    ],
                  ),
                ),
                BottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin:
      const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", 0),
          _navItem(Icons.shopping_bag_outlined,
              "Orders", 1),
          _navItem(Icons.person_outline,
              "Account", 2),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon, String label, int index) {
    final bool active = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xffFF6B6B)
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: active
                    ? Colors.white
                    : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: active
                        ? Colors.white
                        : Colors.grey))
          ],
        ),
      ),
    );
  }
}
