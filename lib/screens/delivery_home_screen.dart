import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/constants/color_constants.dart';
import 'AccountScreen.dart';
import 'HomeContent.dart';
import 'OrdersScreen.dart';
import '../controllers/order_controller.dart';
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

     if (!Get.isRegistered<OrderController>()) {
      Get.put<OrderController>(OrderController(), permanent: true);
    }

     if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController(), permanent: true);
    }

    Get.find<OrderController>().initializeDriverSession();
    Get.find<ProfileController>().fetchProfile();
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
                    if (index == 2) {
                      Get.find<ProfileController>().fetchProfile();
                    }
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, Icons.home_filled, "Home", 0),
          _navItem(Icons.shopping_bag_outlined, Icons.shopping_bag, "Orders", 1),
          _navItem(Icons.person_outline, Icons.person, "Account", 2),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final bool active = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? ColorConstants.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active
                  ? ColorConstants.primary
                  : ColorConstants.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active
                    ? ColorConstants.primary
                    : ColorConstants.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
