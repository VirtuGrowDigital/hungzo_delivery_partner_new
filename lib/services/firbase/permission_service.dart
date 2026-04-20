import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/color_constants.dart';
import '../../utils/ImageConstant.dart';

class PermissionService {
  static const String _offersAskedKey = "offers_permission_asked";

  /// ================= CUSTOM DIALOG =================
  static Future<bool> _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String allowText,
    required String denyText,
    required String imageAsset,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imageAsset, width: 80, height: 80),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),



          style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primary,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(allowText,
                    style: const TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () =>  Navigator.pop(dialogContext, false),
                child: Text(denyText),
              ),        
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  /// ================= NOTIFICATION =================
  static Future<void> _notification(BuildContext context) async {
    if ((await Permission.notification.status).isGranted) return;

    final accepted = await _showPermissionDialog(
      context: context,
      title: "Notification",
      description:
      "Please enable notifications to receive updates and reminders",
      allowText: "Turn on",
      denyText: "Skip",
      imageAsset: ImageConstant.notification,
    );

    if (accepted) {
      await Permission.notification.request();
    }
  }

  /// ================= LOCATION =================
  static Future<void> _location(BuildContext context) async {
    if ((await Permission.location.status).isGranted) return;

    final accepted = await _showPermissionDialog(
      context: context,
      title: "Location",
      description:
      "Allow maps to access your location while you use the app?",
      allowText: "Allow",
      denyText: "Skip",
      imageAsset: ImageConstant.location,
    );

    if (accepted) {
      final result = await Permission.location.request();
      if (result.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  /// ================= OFFERS / FILE =================
  static Future<void> _offers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // ❌ already skipped once → never show again
    if (prefs.getBool(_offersAskedKey) == true) return;

    final permission = Permission.photos;
    final status = await permission.status;

    if (status.isGranted || status.isLimited) return;

    // mark as asked BEFORE dialog
    await prefs.setBool(_offersAskedKey, true);

    final accepted = await _showPermissionDialog(
      context: context,
      title: "Offers and news",
      description: "Please allow access to save images and files",
      allowText: "Allow",
      denyText: "Skip",
      imageAsset: ImageConstant.offers,
    );

    if (accepted) {
      await permission.request();
    }
  }

  /// ================= ✅ PUBLIC METHOD (THIS WAS MISSING) =================
  static Future<void> requestAllPermissions(BuildContext context) async {
    await _notification(context);
    await _location(context);
    await _offers(context);
  }

  /// ================= OPTIONAL RESET =================
  static Future<void> resetOffersPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offersAskedKey);
  }
}
