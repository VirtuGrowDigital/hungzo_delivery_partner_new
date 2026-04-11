import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';
import '../model/wallet_model.dart';

class WalletController extends GetxController {
  final storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var wallet = Rxn<WalletModel>();

  Future<void> fetchWallet() async {
    try {
      isLoading.value = true;

      final token = await storage.read(key: 'accessToken');

      if (token == null) {
        debugPrint("❌ Access  token not found");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("${ApiConstants.baseURL}wallet/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        wallet.value = WalletModel.fromJson(data);
      } else {
        debugPrint("Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Wallet error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchWallet();
    super.onInit();
  }
}
