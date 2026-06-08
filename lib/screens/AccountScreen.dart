import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hungzo_delivery_partner/constants/color_constants.dart';
import '../controllers/order_controller.dart';
import '../controllers/profile_controller.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  ProfileController get controller => Get.find<ProfileController>();
  OrderController get orderController => Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value && controller.profile.value == null) {
        controller.fetchProfile();
      }
    });

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.profile.value;
      if (data == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_search_outlined,
                  size: 48,
                  color: Colors.black45,
                ),
                const SizedBox(height: 12),
                const Text(
                  "We couldn't load your profile yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tap below to retry fetching your driver account details.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: controller.fetchProfile,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchProfile();
          await orderController.refreshDashboard();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            const Text(
              "My Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _profileCard(context, data),
            const SizedBox(height: 18),
            _availabilityCard(),
            const SizedBox(height: 18),
            _deliverySummaryCard(),
            const SizedBox(height: 18),
            _detailsCard(data),
            const SizedBox(height: 18),
            _recentActivityCard(),
            const SizedBox(height: 18),
            _menuTile(
              icon: Icons.receipt_long,
              title: "Refresh account and orders",
              onTap: () async {
                await controller.fetchProfile();
                await orderController.refreshDashboard();
              },
            ),
            _menuTile(
              icon: Icons.logout,
              title: "Log Out",
              color: Colors.red,
              onTap: controller.confirmLogout,
            ),
          ],
        ),
      );
    });
  }

  Widget _profileCard(BuildContext context, dynamic data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ColorConstants.surfaceGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.06),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorConstants.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: (data.profilePic != null && data.profilePic!.isNotEmpty)
                  ? NetworkImage(data.profilePic!)
                  : const NetworkImage("https://i.pravatar.cc/150?img=12"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.phone,
                  style: TextStyle(
                    color: ColorConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statusBadge(data.verificationStatus),
                    const SizedBox(width: 8),
                    _smallPill(
                      data.isBlocked ? "Blocked" : (data.isActive ? "Active" : "Inactive"),
                      data.isBlocked
                          ? Colors.red
                          : (data.isActive ? ColorConstants.success : ColorConstants.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: ColorConstants.primary,
              size: 24,
            ),
            onPressed: () => _openEditSheet(context, data),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    return Obx(() {
      final data = controller.profile.value;
      if (data == null) {
        return const SizedBox.shrink();
      }

      final canGoOnline =
          data.verificationStatus.toUpperCase() == "APPROVED" &&
          data.isActive &&
          !data.isBlocked;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Availability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (data.isBlocked) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.blockType == "TEMPORARY"
                          ? "Your account is temporarily blocked."
                          : "Your account is blocked by admin.",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    if ((data.restrictionReasonText ?? "").isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        data.restrictionReasonText!,
                        style: const TextStyle(color: Color(0xFF7F1D1D)),
                      ),
                    ],
                    if (data.blockedUntil != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Blocked until ${DateFormat('dd MMM yyyy, hh:mm a').format(data.blockedUntil!.toLocal())}",
                        style: const TextStyle(color: Color(0xFF7F1D1D)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const Text(
              "Go online to receive new delivery requests in real time.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.isOnline ? "You are online" : "You are offline",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: data.isOnline ? Colors.green : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        canGoOnline
                            ? "Orders can be assigned to you."
                            : data.isBlocked
                                ? "Admin restriction must be lifted before you can go online."
                                : "Approval is required before going online.",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: data.isOnline,
                  onChanged: (!canGoOnline || controller.isTogglingStatus.value)
                      ? null
                      : (value) => controller.toggleOnlineStatus(value),
                ),
              ],
            ),
            if (controller.isTogglingStatus.value) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        ),
      );
    });
  }

  Widget _deliverySummaryCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    "Delivered",
                    orderController.deliveredCount.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryTile(
                    "Today",
                    orderController.todayDeliveries.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    "Earnings",
                    "Rs ${orderController.deliveredAmount.toStringAsFixed(0)}",
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryTile(
                    "Rating",
                    controller.profile.value == null
                        ? "0.0"
                        : controller.profile.value!.ratingAverage.toStringAsFixed(1),
                    const Color(0xFFFFB300),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Driver Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.badge_outlined, "Driver ID", data.driverId),
          _detailRow(Icons.two_wheeler_outlined, "Vehicle Type", data.vehicleType),
          _detailRow(Icons.confirmation_num_outlined, "Vehicle Number", data.vehicleNumber),
          _detailRow(
            Icons.star_outline_rounded,
            "Average Rating",
            "${data.ratingAverage.toStringAsFixed(1)} from ${data.ratingCount} ratings",
          ),
          _detailRow(
            Icons.verified_user_outlined,
            "Verification",
            data.verificationStatus,
          ),
        ],
      ),
    );
  }

  Widget _recentActivityCard() {
    return Obx(() {
      final active = orderController.activeOrder.value;
      final latest = orderController.latestDeliveredOrder;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (active != null)
              _activityTile(
                title: "Active delivery",
                subtitle:
                    "${active.customerName} • ${active.orderStatus} • Rs ${active.amount.toStringAsFixed(0)}",
                color: const Color(0xffFF6B6B),
              )
            else
              _activityTile(
                title: "No active delivery",
                subtitle: "You are free to accept the next order.",
                color: Colors.grey,
              ),
            const SizedBox(height: 10),
            if (latest != null)
              _activityTile(
                title: "Last completed order",
                subtitle:
                    "${latest.customerName} • ${_formatDate(latest.deliveredAt ?? latest.createdAt)}",
                color: Colors.green,
              )
            else
              _activityTile(
                title: "No completed orders yet",
                subtitle: "Your delivered orders will appear here.",
                color: Colors.orange,
              ),
          ],
        ),
      );
    });
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _smallPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "--" : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityTile({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(.14),
            child: Icon(Icons.history, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Recently";
    return DateFormat("dd MMM, hh:mm a").format(date.toLocal());
  }

  void _openEditSheet(BuildContext context, data) {
    final nameController = TextEditingController(text: data.name);
    final vehicleController = TextEditingController(text: data.vehicleNumber);

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () async {
                        final img = await picker.pickImage(source: ImageSource.gallery);
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
                            : (data.profilePic != null && data.profilePic!.isNotEmpty)
                                ? NetworkImage(data.profilePic!)
                                : null,
                        child: pickedProfile == null &&
                                (data.profilePic == null || data.profilePic!.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(labelText: "Vehicle Number"),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final img = await picker.pickImage(source: ImageSource.gallery);
                        if (img != null) {
                          pickedVehicle = File(img.path);
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.directions_car),
                      label: Text(
                        pickedVehicle != null
                            ? "Vehicle Selected ✓"
                            : "Update Vehicle Image",
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (controller.canEditDocuments.value) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await picker.pickImage(source: ImageSource.gallery);
                          if (img != null) {
                            pickedAadhar = File(img.path);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(
                          pickedAadhar != null ? "Aadhar Selected ✓" : "Update Aadhar",
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await picker.pickImage(source: ImageSource.gallery);
                          if (img != null) {
                            pickedLicense = File(img.path);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.credit_card),
                        label: Text(
                          pickedLicense != null ? "License Selected ✓" : "Update License",
                        ),
                      ),
                    ] else
                      const Text(
                        "Documents locked after ACTIVE verification",
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () async {
                                final success = await controller.updateProfile(
                                  name: nameController.text.trim(),
                                  vehicleNumber:
                                      vehicleController.text.trim().toUpperCase(),
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
                            ? const CircularProgressIndicator(color: Colors.white)
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

  Widget _menuTile({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}
