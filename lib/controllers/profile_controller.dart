import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../model/driver_profile_model.dart';
import '../services/Api/api_services.dart';
import '../services/Api/api_constants.dart';
import '../utils/snack_bar.dart';

class ProfileController extends GetxController {
  final ApiService apiService = ApiService(dio: Dio());

  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;
  RxBool isTogglingStatus = false.obs;
  RxBool canEditDocuments = false.obs;
  Rxn<DriverProfileModel> profile = Rxn<DriverProfileModel>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }
  Future<bool> toggleOnlineStatus(bool nextStatus) async {
    try {
      isTogglingStatus.value = true;

      final token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        CustomSnackBar("Access token missing", "E");
        return false;
      }

      Position? position;
      if (nextStatus) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          CustomSnackBar("Enable location services to go online", "E");
          return false;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          CustomSnackBar("Location permission is required to go online", "E");
          return false;
        }

        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      final response = await http.put(
        Uri.parse("${ApiConstants.baseURL}driver/online-status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "isOnline": nextStatus,
          if (position != null)
            "location": {
              "lat": position.latitude,
              "lng": position.longitude,
            },
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(isOnline: nextStatus);
        }
        CustomSnackBar(
          nextStatus ? "You are now online" : "You are now offline",
          "S",
        );
        return true;
      }

      CustomSnackBar(data["message"]?.toString() ?? "Status update failed", "E");
      return false;
    } catch (e) {
      CustomSnackBar("Could not update status", "E");
      return false;
    } finally {
      isTogglingStatus.value = false;
    }
  }

  // =========================================================
  // 🔥 FETCH PROFILE
  // =========================================================
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final result = await apiService.getDriverProfile();
      profile.value = result;

      /// ✅ allow edit when NOT ACTIVE
      if (result != null) {
        final status = result.verificationStatus.toUpperCase().trim();

        canEditDocuments.value = status != "ACTIVE";
      } else {
        canEditDocuments.value = false;
      }
    } catch (e) {
      print("PROFILE CONTROLLER ERROR => $e");
      profile.value = null;
      canEditDocuments.value = false;
    } finally {
      isLoading.value = false;
    }
  }
  // =========================================================
  // 🔥 UPDATE PROFILE (THIS IS WHAT YOU NEEDED)
  // =========================================================
  Future<bool> updateProfile({
    required String name,
    required String vehicleNumber,
    File? profilePic,
    File? vehicleImage,
    File? aadharImage,
    File? licenseImage,
    String? vehicleType,
  }) async {
    try {
      isUpdating.value = true;

      /// 🚨 block docs if not allowed
      if (!canEditDocuments.value) {
        aadharImage = null;
        licenseImage = null;
      }

      final success = await apiService.updateDriverProfile(
        name: name,
        vehicleNumber: vehicleNumber,
        profilePic: profilePic,
        vehicleImage: vehicleImage,
        aadharImage: aadharImage,
        licenseImage: licenseImage,
        vehicleType: vehicleType,
      );

      if (success) {
        /// ✅ USER FRIENDLY TOAST
        CustomSnackBar("Profile updated successfully", "S");

        await fetchProfile();
        return true;
      } else {
        CustomSnackBar("Profile update failed. Please try again", "E");
        return false;
      }
    } catch (e) {
      CustomSnackBar("Something went wrong", "E");
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await apiService.logoutCurrentSession();

      /// 1️⃣ Firebase logout
      await FirebaseAuth.instance.signOut();

      /// 2️⃣ Clear tokens
      await secureStorage.delete(key: Constants.accessToken);
      await secureStorage.delete(key: Constants.refreshToken);
      await secureStorage.delete(key: Constants.fcmToken);

      /// 3️⃣ Clear profile
      profile.value = null;

      /// 4️⃣ Navigate
      Get.offAllNamed("/login");
      CustomSnackBar("Logged out successfully", "S");
    } catch (e) {
      print("Logout failed. Please try again $e");
      CustomSnackBar("Logout failed. Please try again", "E");
    } finally {
      isLoading.value = false;
    }
  }  Future<void> confirmLogout() async {
    Get.defaultDialog(
      title: "Logout",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      middleText: "Are you sure you want to logout?",
      middleTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),

      /// 🎨 BACKGROUND
      backgroundColor: Colors.white,
      radius: 16,

      /// ❌ CANCEL BUTTON STYLE
      textCancel: "Cancel",
      cancelTextColor: Colors.grey.shade700,
      buttonColor: const Color(0xff1EB980), // fallback color

      /// ✅ CONFIRM BUTTON TEXT COLOR
      textConfirm: "Logout",
      confirmTextColor: Colors.white,

      /// 🔥 CUSTOM CONFIRM BUTTON COLOR
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () async {
          Get.back();
          await logout();
        },
        child: const Text(
          "Logout",
          style: TextStyle(color: Colors.white),
        ),
      ),

      /// ❌ CUSTOM CANCEL BUTTON
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );  }
}
