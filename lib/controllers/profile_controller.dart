import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as secureStorage;
import 'package:hungzo_delivery_partner/screens/auth/login/login_screen.dart';

import '../constants/constants.dart';
import '../model/driver_profile_model.dart';
import '../services/Api/api_services.dart';
import '../utils/snack_bar.dart';

class ProfileController extends GetxController {
  final ApiService apiService = ApiService(dio: Dio());

  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;
  RxBool canEditDocuments = false.obs;
  Rxn<DriverProfileModel> profile = Rxn<DriverProfileModel>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  void onInit() {
    super.onInit();
    fetchProfile();
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

      /// 1️⃣ Firebase logout
      await FirebaseAuth.instance.signOut();

      /// 2️⃣ Clear tokens
      await secureStorage.delete(key: Constants.accessToken);
      await secureStorage.delete(key: Constants.refreshToken);

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



