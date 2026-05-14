import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/color_constants.dart';
import '../../utils/ImageConstant.dart';

class PermissionService {
  /// ================= CUSTOM DIALOG =================
  static Future<bool> _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String allowText,
    String? denyText,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),

                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primary,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  allowText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (denyText != null)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(denyText),
                ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  /// ================= LOCATION =================
  static Future<void> _location(BuildContext context) async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      return;
    }
    if (!context.mounted) return;

    await _showPermissionDialog(
      context: context,
      title: "Location",
      description: "Allow maps to access your location while you use the app?",
      allowText: "Allow",
      imageAsset: ImageConstant.location,
    );

    final result = await Geolocator.requestPermission();
    if (result == LocationPermission.deniedForever) {
      openAppSettings();
    }
  }
}
