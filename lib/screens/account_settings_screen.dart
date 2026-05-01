import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/screens/wallet_screen.dart';

import '../controllers/auth_controller.dart';
import '../utils/color_constants.dart';
import 'about_us_screen.dart';
import 'auth/login/login_screen.dart';
import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  AccountSettingsScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    /// 🔥 ALWAYS get fresh user (don't store globally)
    final user = authController.currentUser;

    final bool isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Account",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= ACCOUNT SETTINGS =================
            const Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConstants.success,
              ),
            ),

            const SizedBox(height: 12),

            _settingsTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () => Get.to(() => EditProfileScreen()),
            ),

            _settingsTile(
              icon: Icons.inventory_2_outlined,
              title: "My Orders",
              onTap: () => Get.to(() => MyOrdersScreen()),
            ),

            _settingsTile(
              icon: Icons.credit_card,
              title: "Payment Methods",
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.inventory_2_outlined,
              title: "Wallet",
              onTap: () => Get.to(() => WalletScreen()),
            ),
            const SizedBox(height: 24),

            /// ================= GENERAL =================
            const Text(
              "General Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConstants.success,
              ),
            ),

            const SizedBox(height: 12),

            _settingsTile(
              icon: Icons.info_outline,
              title: "About us",
              onTap: () => Get.to(() => const AboutUsScreen()),
            ),

            const SizedBox(height: 40),

            /// ================= LOGIN / LOGOUT BUTTON =================
            SizedBox(
              width: 140,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoggedIn ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                onPressed: () {
                  if (isLoggedIn) {
                    _showLogoutDialog(context);
                  } else {
                    Get.offAll(() => LoginScreen());
                  }
                },

                child: Text(
                  isLoggedIn ? "Log Out" : "Login",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TILE =================
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  /// ================= LOGOUT =================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await authController.logout();
                Get.offAll(() => const LoginScreen());
              } catch (e) {
                debugPrint("Logout error: $e");
              }
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
