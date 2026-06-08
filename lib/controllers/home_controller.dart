import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';

import '../screens/cart_screen.dart';
import '../screens/home_view.dart';
import '../screens/account_settings_screen.dart';
import '../controllers/cart_controller.dart';
import '../services/firbase/permission_service.dart';

class HomeController extends GetxController {
  /// Bottom navigation index
  final RxInt bottomIndex = 0.obs;
  RxBool isLoading = true.obs;
  /// ================= FILTER STATE =================

  final RxnInt sortIndex = RxnInt(); // nullable
  final RxBool ratingFilter = false.obs;
  final RxBool priceFilter = false.obs;
  /// ================= BANNERS =================
  final String bannerApiUrl = "${ApiConstants.baseURL}banners";

  final RxList<String> bannerImages = <String>[].obs;

  /// original products (backup)
  List<Map<String, dynamic>> originalProducts = [];
  /// Bottom navigation icons
  final List<IconData> iconList = const [
    Icons.home,
    Icons.shopping_cart_outlined,
    Icons.person_outline,
  ];

  /// Screens (kept alive by AnimatedBottomNavigationBar)
  final List<Widget> screens = [
    HomeScreen(),
    CartScreen(),
    AccountSettingsScreen(),
  ];

  /// ================= API =================
  final String apiUrl = "${ApiConstants.baseURL}categories/menu";
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxString selectedCategory = "".obs;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestAllPermissions(Get.context!);
    });

    fetchCategories();
    fetchBanners(); // 🔥 ADD THIS

    /// ✅ Ensure CartController exists once
    Get.put(CartController(), permanent: true);
  }

  void applyFilters() {

    List<Map<String, dynamic>> filtered = [...originalProducts];

    // =================================================
    // ⭐ PRICE FILTER (use FIRST variety price)
    // =================================================

    if (priceFilter.value) {
      filtered = filtered.where((p) {

        final varieties = p["varieties"] as List?;

        if (varieties == null || varieties.isEmpty) return false;

        final price = (varieties[0]["price"] ?? 0).toDouble();

        return price >= 200 && price <= 400; // adjust range
      }).toList();
    }

    // =================================================
    // ⭐ SORT
    // =================================================

    if (sortIndex.value != null) {

      filtered.sort((a, b) {

        final aPrice =
        (a["varieties"][0]["price"] ?? 0).toDouble();

        final bPrice =
        (b["varieties"][0]["price"] ?? 0).toDouble();

        if (sortIndex.value == 1) {
          return aPrice.compareTo(bPrice); // low → high
        } else if (sortIndex.value == 2) {
          return bPrice.compareTo(aPrice); // high → low
        }

        return 0;
      });
    }

    products.assignAll(filtered);
  }

  /// ================= CATEGORY API =================
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
print("Product data $data");
        if (data["success"] == true) {
          categories.assignAll(
            List<Map<String, dynamic>>.from(data["menu"]),
          );

          if (categories.isNotEmpty) {
            selectedCategory.value = categories.first["category"];

            /// 🔥 SAVE BACKUP
            originalProducts =
            List<Map<String, dynamic>>.from(categories.first["products"]);

            products.assignAll(originalProducts);
          }
        }
      }
    } catch (e) {
      debugPrint("API ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
  void clearFilters() {
    sortIndex.value = null;
    ratingFilter.value = false;
    priceFilter.value = false;

    products.assignAll(originalProducts);
  }

  /// ================= CATEGORY CHANGE =================
  void changeCategory(String categoryName) {

    selectedCategory.value = categoryName;

    final category = categories.firstWhere(
          (c) => c["category"] == categoryName,
      orElse: () => {},
    );

    if (category.isNotEmpty) {

      /// 🔥 reset filters when category changes
      sortIndex.value = null;
      ratingFilter.value = false;
      priceFilter.value = false;

      /// 🔥 update backup
      originalProducts =
      List<Map<String, dynamic>>.from(category["products"]);

      /// 🔥 show raw products (NO FILTER)
      products.assignAll(originalProducts);
    }
  }

  /// ================= TAB CHANGE (🔥 FIX HERE) =================
  void changeTab(int index) {
    bottomIndex.value = index;

    /// 🔥 WHEN CART TAB IS OPENED
    if (index == 1) {
      Get.find<CartController>().fetchCart();
    }
  }
  /// ================= BANNER API =================
  Future<void> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse(bannerApiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final banners = List<Map<String, dynamic>>.from(data["banners"]);

          List<String> allImages = [];

          for (var banner in banners) {
            final images = List<String>.from(banner["images"]);
            allImages.addAll(images);
          }

          bannerImages.assignAll(allImages);
        }
      }
    } catch (e) {
      debugPrint("Banner API ERROR: $e");
    }
  }

}
