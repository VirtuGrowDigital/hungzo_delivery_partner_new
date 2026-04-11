import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/profile_controller.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  ProfileController get controller => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.profile.value;

      if (data == null) {
        return const Center(child: Text("No Profile Found"));
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// 🔥 HEADER
            const Text(
              "My Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            /// 🔥 PROFILE CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffEEF7FF), Color(0xffFFFFFF)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.06),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: (data.profilePic != null &&
                        data.profilePic!.isNotEmpty)
                        ? NetworkImage(data.profilePic!)
                        : const NetworkImage(
                        "https://i.pravatar.cc/150?img=12"),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.phone,
                          style:
                          const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        _statusBadge(data.verificationStatus),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _openEditSheet(context, data),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            _menuTile(
              icon: Icons.receipt_long,
              title: "Order History",
              onTap: () {},
            ),

            _menuTile(
              icon: Icons.logout,
              title: "Log Out",
              color: Colors.red,
              onTap: () async {
             controller.confirmLogout();
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================

  Widget _statusBadge(String status) {
    Color color;

    switch (status.toUpperCase()) {
      case "APPROVED":
      case "ACTIVE":
        color = Colors.green;
        break;
      case "REJECTED":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================================================
  // 🔥 EDIT SHEET (FINAL PREMIUM)
  // =========================================================

  void _openEditSheet(BuildContext context, data) {
    final nameController = TextEditingController(text: data.name);
    final vehicleController =
    TextEditingController(text: data.vehicleNumber);

    File? pickedProfile;
    File? pickedVehicle;
    File? pickedAadhar;
    File? pickedLicense;

    final picker = ImagePicker();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Obx(() {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// DRAG HANDLE
                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 28),

                    // ================= PROFILE IMAGE =================
                    GestureDetector(
                      onTap: () async {
                        final img = await picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) {
                          pickedProfile = File(img.path);
                          setState(() {});
                        }
                      },
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: pickedProfile != null
                            ? FileImage(pickedProfile!)
                            : (data.profilePic != null &&
                            data.profilePic!.isNotEmpty)
                            ? NetworkImage(data.profilePic!)
                            : null,
                        child: pickedProfile == null &&
                            (data.profilePic == null ||
                                data.profilePic!.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= NAME =================
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: "Full Name"),
                    ),

                    const SizedBox(height: 12),

                    // ================= VEHICLE NUMBER =================
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(
                          labelText: "Vehicle Number"),
                    ),

                    const SizedBox(height: 20),

                    // ================= VEHICLE IMAGE =================
                    OutlinedButton.icon(
                      onPressed: () async {
                        final img = await picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) {
                          pickedVehicle = File(img.path);
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.directions_car),
                      label: Text(pickedVehicle != null
                          ? "Vehicle Selected ✓"
                          : "Update Vehicle Image"),
                    ),

                    const SizedBox(height: 14),

                    // ================= DOCUMENTS =================
                    if (controller.canEditDocuments.value) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (img != null) {
                            pickedAadhar = File(img.path);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(pickedAadhar != null
                            ? "Aadhar Selected ✓"
                            : "Update Aadhar"),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (img != null) {
                            pickedLicense = File(img.path);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.credit_card),
                        label: Text(pickedLicense != null
                            ? "License Selected ✓"
                            : "Update License"),
                      ),
                    ] else
                      const Text(
                        "Documents locked after ACTIVE verification",
                        style: TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 30),

                    // ================= SAVE BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () async {
                          final success =
                          await controller.updateProfile(
                            name: nameController.text.trim(),
                            vehicleNumber: vehicleController.text
                                .trim()
                                .toUpperCase(),
                            profilePic: pickedProfile,
                            vehicleImage: pickedVehicle,
                            aadharImage: pickedAadhar,
                            licenseImage: pickedLicense,
                          );

                          if (success == true) {
                            Get.back();
                          }
                        },
                        child: controller.isUpdating.value
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
      isScrollControlled: true,
    );
  }

  // =========================================================
  // MENU TILE
  // =========================================================

  Widget _menuTile({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style:
          TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}