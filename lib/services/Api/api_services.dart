
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../constants/constants.dart';
import '../../data/models/AddAddressModel/add_address_model.dart';
import '../../data/models/AddToCartModel/addTo_cart_model.dart';
import '../../data/models/AllAddressesModel/all_addresses_model.dart';
import '../../data/models/CommonModel/common_model.dart';
import '../../data/models/FavouritesModel/favourites_model.dart';
import '../../data/models/FetchUserModel/fetch_user_model.dart';
import '../../data/models/HomeModel/home_model.dart';
import '../../data/models/MlmModels/mlm_downlines_model.dart';
import '../../data/models/MyAllServicesModel/my_all_services_model.dart';
import '../../data/models/NearWorkshopModel/near_workshop_model.dart';
import '../../data/models/OrderHistoryModel/order_history_model.dart';
import '../../data/models/ProductModel/product_model.dart';
import '../../data/models/RemFromCartModel/rem_from_cart_model.dart';
import '../../data/models/RemFromFevModel/rem_from_fev_model.dart';
import '../../data/models/SearchModel/search_model.dart';
import '../../data/models/ServicesModel/services_model.dart';
import '../../data/models/TransactionModel/transaction_model.dart';
import '../../data/models/UpdateAddressModel/update_address_model.dart';
import '../../data/models/UpdateCartQuantityModel/update_cart_quantity_model.dart';
import '../../data/models/ViewCartModel/view_cart_model.dart';
import '../../data/models/ViewFavouritesModel/view_favourites_model.dart';
import '../../data/models/Wallet/AllUpiIdModel/add_upi_id_model.dart';
import '../../data/models/Wallet/AllUpiIdModel/delete_upi_id_model.dart';
import '../../data/models/Wallet/AllUpiIdModel/get_all_upi_id_model.dart';
import '../../data/models/Wallet/WithdrawHistoryModel/withdraw_history_model.dart';
import '../../data/models/Wallet/WithdrawModel/withdraw_model.dart';
import '../../data/models/login_and_registration_flow/login/LoginModel.dart';
import '../../data/models/login_and_registration_flow/registration/RegisterModel.dart';
import '../../model/driver_profile_model.dart';
import '../../screens/delivery_home_screen.dart';
import '../../utils/flutter_toast.dart';
import 'api_constants.dart';
import 'api_repository.dart';

class ApiService implements ApiRepository {
  final Dio dio;
  var storage = GetStorage();
  final secureStorage = const FlutterSecureStorage();

  ApiService({required this.dio});
  Future<void> firebaseLogin(String s) async {
    try {
      print("firebaseLogin");

      final idToken =
      await FirebaseAuth.instance.currentUser!.getIdToken();

      // final url = Uri.parse(
      //     'http://10.0.2.2:4000/auth/firebase-login'); // emulator
      final url = Uri.parse('${ApiConstants.baseURL}auth/firebase-login');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': 'DRIVER',
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        await secureStorage.write(
          key: Constants.accessToken,
          value: accessToken,
        );

        await secureStorage.write(
          key: Constants.refreshToken,
          value: refreshToken,
        );

        print('Login success');
      } else {
        print('Login failed');
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<DriverProfileModel?> getDriverProfile() async {
    try {
      final token =
      await secureStorage.read(key: Constants.accessToken);

      if (token == null || token.isEmpty) {
        print("❌ Access token missing");
        return null;
      }

      final response = await dio.get(
        "${ApiConstants.baseURL}driver/myProfile",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          validateStatus: (status) => true,
        ),
      );

      print("PROFILE STATUS => ${response.statusCode}");
      print("PROFILE RESPONSE => ${response.data}");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["success"] == true &&
          response.data["profile"] != null) {
        return DriverProfileModel.fromJson(
          Map<String, dynamic>.from(response.data["profile"]),
        );
      }

      return null;
    } catch (e) {
      print("GET PROFILE ERROR => $e");
      return null;
    }
  }
  Future<bool> updateDriverProfile({
    required String name,
    required String vehicleNumber,
    File? profilePic,
    File? vehicleImage,
    File? aadharImage,
    File? licenseImage,
    String? vehicleType,
  }) async {
    try {
      final token =
      await secureStorage.read(key: Constants.accessToken);

      if (token == null || token.isEmpty) {
        print("❌ Access token missing");
        return false;
      }

      /// 🔥 BUILD FORM DATA
      final formData = FormData.fromMap({
        "name": name.trim(),
        "vehicleNumber": vehicleNumber.trim().toUpperCase(),
        if (vehicleType != null) "vehicleType": vehicleType,

        /// ✅ PROFILE PIC
        if (profilePic != null)
          "profilePic": await MultipartFile.fromFile(
            profilePic.path,
            filename: "profile.jpg",
          ),

        /// ✅ VEHICLE IMAGE
        if (vehicleImage != null)
          "vehicleImage": await MultipartFile.fromFile(
            vehicleImage.path,
            filename: "vehicle.jpg",
          ),

        /// ✅ DOCUMENTS (ONLY WHEN SENT)
        if (aadharImage != null)
          "aadharImage": await MultipartFile.fromFile(
            aadharImage.path,
            filename: "aadhar.jpg",
          ),

        if (licenseImage != null)
          "licenseImage": await MultipartFile.fromFile(
            licenseImage.path,
            filename: "license.jpg",
          ),
      });

      final response = await dio.put(
        "${ApiConstants.baseURL}driver/profile",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            // ⚠️ do NOT manually set multipart content-type
          },
          validateStatus: (status) => true,
        ),
      );

      print("UPDATE STATUS => ${response.statusCode}");
      print("UPDATE RESPONSE => ${response.data}");

      /// ✅ SUCCESS CHECK
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data["success"] == true) {
        return true;
      }

      return false;
    } catch (e) {
      print("UPDATE ERROR => $e");
      return false;
    }
  }
  //   Future<void> firebaseLogin(String firebaseToken) async {
//     print("firebaseLogin");
//
//     final url = Uri.parse('${ApiConstants.baseURL}auth/firebase-login');
// print("Url $url");
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $firebaseToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'role': 'DRIVER',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("Url = $data");
//
//       final accessToken = data['accessToken'];
//       final refreshToken = data['refreshToken'];
//
//       // ✅ Store securely
//       await secureStorage.write(
//         key: 'accessToken',
//         value: accessToken,
//       );
//
//       await secureStorage.write(
//         key: 'refreshToken',
//         value: refreshToken,
//       );
//
//       print('Login success');
//     } else {
//       print('Login failed: ${response.statusCode}');
//       print(response.body);
//     }
//   }

  Future<MenuModel> getMenu() async {
    final response = await dio.get(
      '${ApiConstants.baseURL}categories/menu',
    );

    if (response.statusCode == 200) {
      return MenuModel.fromJson(response.data);
    } else {
      throw Exception("Menu fetch failed");
    }
  }

  Future<LoginModel> login(Map<String, String> request) async {
    try {
      final response = await dio.post(ApiConstants.userLogin, data: request);
      if (response.statusCode == 200) {
        return LoginModel.fromJson(response.data);
      } else {
        return LoginModel(
          status: false,
          message: response.data['message'] ??
              "Unexpected error occurred. Status Code: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      return LoginModel(
        status: false,
        message: e.response?.data['message'] ??
            e.response?.statusMessage ??
            "Server error occurred. Please try again.",
      );
    } catch (e) {
      return LoginModel(
        status: false,
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refreshToken');
  }

  // Future<RegisterModel> firebaseRegister(
  //     Map<String, dynamic> request,
  //     ) async {
  //   try {
  //     final accessToken = await getAccessToken();
  //
  //     if (accessToken == null) {
  //       return RegisterModel(
  //         status: false,
  //         message: 'Access token not found. Please login again.',
  //       );
  //     }
  //
  //     final response = await dio.post(
  //       '${ApiConstants.baseURL}driver/register',
  //       data: request,
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $accessToken",
  //           "Content-Type": "application/json",
  //         },
  //         validateStatus: (status) => true,
  //       ),
  //     );
  //
  //     print("REGISTER STATUS => ${response.statusCode}");
  //     print("REGISTER DATA => ${response.data}");
  //     print("REGISTER DATA => ${request}");
  //
  //     if (response.statusCode == 200 ||
  //         response.statusCode == 201) {
  //       return RegisterModel.fromJson(response.data);
  //     } else {
  //       return RegisterModel(
  //         status: false,
  //         message:
  //         response.data["message"] ?? "Registration failed",
  //       );
  //     }
  //   } on DioException catch (e) {
  //     print("REGISTER ERROR => ${e.response?.data}");
  //
  //     return RegisterModel(
  //       status: false,
  //       message: e.response?.data?["message"] ??
  //           e.message ??
  //           "Server error",
  //     );
  //   } catch (e) {
  //     print("REGISTER ERROR => $e");
  //
  //     return RegisterModel(
  //       status: false,
  //       message: "Unexpected error: ${e.toString()}",
  //     );
  //   }
  // }
  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return File(result!.path);
  }

  Future<RegisterModel> firebaseRegister({
    required String name,
    required String vehicleType,
    required String vehicleNumber,
    required File aadharImage,
    required File licenseImage,
    required File vehicleImage,
    File? profilePic,
  }) async {
    try {
      final accessToken = await getAccessToken();

      if (accessToken == null) {
        return RegisterModel(
          status: false,
          message: "Access token missing. Please login again.",
        );
      }

      /// 🔥 Compress Images
      final compressedAadhar = await compressImage(aadharImage);
      final compressedLicense = await compressImage(licenseImage);
      final compressedVehicle = await compressImage(vehicleImage);
      File? compressedProfile;

      if (profilePic != null) {
        compressedProfile = await compressImage(profilePic);
      }

      /// 🔥 Create Multipart Files
      MultipartFile aadharFile = await MultipartFile.fromFile(
        compressedAadhar.path,
        filename: "aadhar.jpg",
      );

      MultipartFile licenseFile = await MultipartFile.fromFile(
        compressedLicense.path,
        filename: "license.jpg",
      );

      MultipartFile vehicleFile = await MultipartFile.fromFile(
        compressedVehicle.path,
        filename: "vehicle.jpg",
      );

      MultipartFile? profileFile;

      if (compressedProfile != null) {
        profileFile = await MultipartFile.fromFile(
          compressedProfile.path,
          filename: "profile.jpg",
        );
      }

      /// 🔥 Create FormData
      FormData formData = FormData.fromMap({
        "name": name,
        "vehicleType": vehicleType,
        "vehicleNumber": vehicleNumber,
        "aadharImage": aadharFile,
        "licenseImage": licenseFile,
        "vehicleImage": vehicleFile,
       "profilePic": profileFile,
      });

      final response = await dio.post(
        "${ApiConstants.baseURL}driver/register",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Accept": "application/json",
          },
          contentType: "multipart/form-data",
          validateStatus: (status) => true,
        ),
      );

      print("REGISTER STATUS => ${response.statusCode}");
      print("REGISTER DATA => ${response.data}");

      /// ✅ SUCCESS
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
        response.data is Map ? response.data : jsonDecode(response.data);

        Get.offAll(() => const DeliveryHomeScreen());

        return RegisterModel.fromJson(data);
      }

      /// ❌ SERVER ERROR
      else {
        if (response.data is Map) {
          return RegisterModel(
            status: false,
            message: response.data["message"] ?? "Registration failed",
          );
        } else {
          return RegisterModel(
            status: false,
            message: "Server error: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      print("REGISTER ERROR => $e");

      return RegisterModel(
        status: false,
        message: e.toString(),
      );
    }
  }
  // Future<RegisterModel> firebaseRegister({
  //   required String name,
  //   required String vehicleType,
  //   required String vehicleNumber,
  //   required File aadharImage,
  //   required File licenseImage,
  //   required File vehicleImage,
  //   File? profilePic,
  // }) async {
  //   try {
  //     final accessToken = await getAccessToken();
  //
  //     if (accessToken == null) {
  //       return RegisterModel(
  //         status: false,
  //         message: 'Access token not found. Please login again.',
  //       );
  //     }
  //
  //     /// ✅ FORM DATA (REQUIRED)
  //     FormData formData = FormData.fromMap({
  //       "name": name,
  //       "vehicleType": vehicleType,
  //       "vehicleNumber": vehicleNumber,
  //
  //       /// 🔥 FILES (MOST IMPORTANT)
  //       "aadharImage": await MultipartFile.fromFile(
  //         aadharImage.path,
  //         filename: "aadhar.jpg",
  //       ),
  //       "licenseImage": await MultipartFile.fromFile(
  //         licenseImage.path,
  //         filename: "license.jpg",
  //       ),
  //       "vehicleImage": await MultipartFile.fromFile(
  //         vehicleImage.path,
  //         filename: "vehicle.jpg",
  //       ),
  //
  //       if (profilePic != null)
  //         "profilePic": await MultipartFile.fromFile(
  //           profilePic.path,
  //           filename: "profile.jpg",
  //         ),
  //     });
  //
  //     final response = await dio.post(
  //       '${ApiConstants.baseURL}driver/register',
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $accessToken",
  //           "Accept": "application/json",
  //         },
  //         validateStatus: (status) => true,
  //       ),
  //     );
  //
  //     print("REGISTER STATUS => ${response.statusCode}");
  //     print("REGISTER DATA => ${response.data}");
  //
  //     if (response.statusCode == 200 ||
  //         response.statusCode == 201) {
  //       Get.offAll(
  //             () => const DeliveryHomeScreen(),
  //       );
  //       return RegisterModel.fromJson(response.data);
  //     } else {
  //       return RegisterModel(
  //         status: false,
  //         message:
  //         response.data["message"] ?? "Registration failed",
  //       );
  //     }
  //   } catch (e) {
  //     print("REGISTER STATUS e=> ${e}");
  //     return RegisterModel(
  //       status: false,
  //       message: e.toString(),
  //     );
  //   }
  // }


  @override
  Future<RegisterModel> register(Map<String, String> request) async {
    try {
      final response = await dio.post(ApiConstants.userRegister, data: request);
      if (response.data != null && response.data is Map<String, dynamic>) {
        print(" OTP Screen Submit: ${response.data}");
        bool status = response.data['status'] ?? false;

        if (status) {
          return RegisterModel.fromJson(response.data);
        } else {
          return RegisterModel(
            status: false,
            message: response.data['message'] ?? "Unexpected error occurred",
          );
        }
      } else {
        return RegisterModel(
          status: false,
          message: "Invalid response from server",
        );
      }
    } on DioException catch (e) {
      return RegisterModel(
        status: false,
        message: e.response?.data['message'] ?? "Server error",
      );
    } catch (e) {
      return RegisterModel(
        status: false,
        message: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  @override
  Future<CommonModel> registerOtp(Map<String, String> request) async {
    try {
      final response = await dio.post(ApiConstants.sendOTP, data: request);
      if (response.statusCode == 200) {
        return CommonModel.fromJson(response.data);
      } else {
        return CommonModel(status: false, message: response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return CommonModel(status: false, message: e.response?.data["message"]);
      } else {
        Message_Utils.displayToast(e.toString());
      }
    } catch (e) {
      Message_Utils.displayToast(e.toString());
    }
    return CommonModel(status: false, message: "server error");
  }

  @override
  Future<CommonModel> resetPassword(Map<String, String> request) async {
    try {
      final response =
      await dio.post(ApiConstants.resetPassword, data: request);
      if (response.statusCode == 200) {
        return CommonModel.fromJson(response.data);
      } else {
        return CommonModel(status: false, message: response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return CommonModel(status: false, message: e.response?.data["message"]);
      }
    } catch (e) {
      Message_Utils.displayToast(e.toString());
    }
    return CommonModel(status: false, message: "server error");
  }

  @override
  Future<ProductModel> getAllProductsList() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getProductList,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch product: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return ProductModel(status: false, message: "server-error");
    }
  }

  @override
  Future<SearchModel> searchProduct(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.searchProduct,
        queryParameters: request,
      );

      if (response.statusCode == 200) {
        return SearchModel.fromJson(response.data);
      } else {
        throw ("Failed to search product: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return SearchModel(status: false, message: "server-error");
    }
  }

  @override
  Future<UpdateAddressModel> updateAddress(
      String addressId, Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }
      String url = '${ApiConstants.updateAddress}$addressId';
      final response = await dio.put(
        url,
        data: request,
      );

      if (response.statusCode == 200) {
        return UpdateAddressModel.fromJson(response.data);
      } else {
        throw ("Failed to update address: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return UpdateAddressModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<TransactionModel> createOrder(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response = await dio.post(
        ApiConstants.createOrder,
        data: request,
      );

      if (response.statusCode == 201) {
        return TransactionModel.fromJson(response.data);
      } else {
        throw Exception("Failed to process payment: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return TransactionModel(status: false, message: e.toString());
    }
  }

  @override
  Future<CommonModel> verifyOrder(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response = await dio.post(
        ApiConstants.verifyOrder,
        data: request,
      );

      if (response.statusCode == 201) {
        return CommonModel.fromJson(response.data);
      } else {
        throw Exception("Failed to verify order: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    }
  }

  @override
  Future<OrderHistoryModel> myOrderHistory(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response = await dio.get(ApiConstants.orderHistory,
          data: request,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));

      if (response.statusCode == 200) {
        return OrderHistoryModel.fromJson(response.data);
      } else {
        return OrderHistoryModel(
          status: false,
          message: "Failed to load order history: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      return OrderHistoryModel(
        status: false,
        message: e.response?.data['message'] ?? "An unknown error occurred.",
      );
    } catch (e) {
      return OrderHistoryModel(status: false, message: e.toString());
    }
  }

  @override
  Future<NearWorkshopModel> getAllWorkshopList(
      Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getNearWorkshopList,
        data: request,
      );

      if (response.statusCode == 200) {
        return NearWorkshopModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch workshops: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return NearWorkshopModel(status: false, message: e.toString());
    }
  }

  @override
  Future<NearWorkshopModel> getBreakdownList(
      Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getNearWorkshopList,
        data: request,
      );

      if (response.statusCode == 200) {
        return NearWorkshopModel.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to fetch near workshops: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return NearWorkshopModel(status: false, message: e.toString());
    }
  }

  @override
  Future<AddToCartModel> addToCart(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.post(
        ApiConstants.addToCart,
        data: request,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddToCartModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data["message"] ?? "Unknown error occurred";
        throw Exception(errorMessage);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      return AddToCartModel(status: false, message: e.toString());
    }
  }

  @override
  Future<FavouritesModel> addToFavourites(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.post(
        ApiConstants.addToFavourites,
        data: request,
      );

      if (response.statusCode == 200) {
        return FavouritesModel.fromJson(response.data);
      } else {
        throw Exception(
            "Add to Failed favorites product: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return FavouritesModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<ViewCartModel> getAllCartList() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getCartList,
      );

      if (response.statusCode == 200) {
        return ViewCartModel.fromJson(response.data);
      } else {
        throw Exception("${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return ViewCartModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<ViewFavouritesModel> getAllFavouriteList() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getFavouriteList,
      );

      if (response.statusCode == 200) {
        return ViewFavouritesModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch favorites: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return ViewFavouritesModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<void> logOut(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);

      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.post(ApiConstants.logOut, data: request);
    } catch (e) {
      Message_Utils.displayToast("Logout Error:${e.toString()}");
    }
  }

  @override
  Future<RemFromCartModel> removeFromCart(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.delete(
        ApiConstants.removeFromCart,
        data: request,
      );

      if (response.statusCode == 200) {
        return RemFromCartModel.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to remove product from cart: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return RemFromCartModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<RemFromFevModel> removeFromFavourite(
      Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.delete(
        ApiConstants.removeFromFav,
        data: request,
      );

      if (response.statusCode == 200) {
        return RemFromFevModel.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to fetch from wishlist: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return RemFromFevModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<OrderHistoryModel> cancelOrder(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response = await dio.patch(ApiConstants.cancelOrder, data: request);

      if (response.statusCode == 200) {
        return OrderHistoryModel.fromJson(response.data);
      } else {
        return OrderHistoryModel(
          status: false,
          message: "Failed to cancel order: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      return OrderHistoryModel(
        status: false,
        message: e.response?.data['message'] ?? "An unknown error occurred.",
      );
    } catch (e) {
      return OrderHistoryModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<ServiceModel> bookBreakdownService(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response =
      await dio.post(ApiConstants.bookBreakdownService, data: request);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        return ServiceModel.fromJson(response.data);
      } else {
        return ServiceModel(
          status: false,
          message: "${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      return ServiceModel(
        status: false,
        message: e.response?.data['message'] ?? "An unknown error occurred.",
      );
    } catch (e) {
      return ServiceModel(
          status: false, message: "An error occurred: ${e.toString()}");
    }
  }

  @override
  Future<ServiceModel> bookWorkshopService(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response =
      await dio.post(ApiConstants.bookWorkshopService, data: request);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        return ServiceModel.fromJson(response.data);
      } else {
        return ServiceModel(
          status: false,
          message: response.data['message'] ?? "Unexpected error occurred.",
        );
      }
    } on DioException catch (e) {
      return ServiceModel(
        status: false,
        message: e.response?.data?['message'] ?? "An unknown error occurred.",
      );
    } catch (e) {
      return ServiceModel(
        status: false,
        message: "An error occurred: ${e.toString()}",
      );
    }
  }

  @override
  Future<void> refreshToken(Map<String, String> request) async {
    try {
      final response = await dio.post(
        ApiConstants.accessTokenNew,
        data: request,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to refresh token");
      }
    } catch (e) {
      Message_Utils.displayToast(e.toString());
    }
  }

  @override
  Future<UpdateCartQuantityModel> updateCartQuantity(
      Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response =
      await dio.put(ApiConstants.updateCartQuantity, data: request);

      if (response.statusCode == 200) {
        return UpdateCartQuantityModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 409) {
          return UpdateCartQuantityModel(
            status: false,
            message: e.response?.data["message"] ??
                "This product's quantity is fixed and cannot be changed.",
          );
        }
        return UpdateCartQuantityModel(
          status: false,
          message: e.response?.data["message"] ?? "Unknown error occurred",
        );
      } else {
        return UpdateCartQuantityModel(
          status: false,
          message: "Network error occurred",
        );
      }
    } catch (e) {
      return UpdateCartQuantityModel(status: false, message: e.toString());
    }
  }

  @override
  Future<HomeModel> getHomeData() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getHomeData,
      );

      if (response.statusCode == 200) {
        return HomeModel.fromJson(response.data);
      } else {
        throw Exception("Failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return HomeModel(status: false, message: e.toString());
    }
  }

  @override
  Future<MyAllServicesModel> myAllServices() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.myAllServices,
      );

      if (response.statusCode == 200) {
        return MyAllServicesModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return MyAllServicesModel(status: false, message: e.toString());
    }
  }

  @override
  Future<MyAllServicesModel> cancelService(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }

      final response =
      await dio.patch(ApiConstants.cancelService, data: request);

      if (response.statusCode == 200) {
        return MyAllServicesModel.fromJson(response.data);
      } else {
        return MyAllServicesModel(
          status: false,
          message: "Failed to cancel service: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      return MyAllServicesModel(
        status: false,
        message: e.response?.data['message'] ?? "An unknown error occurred.",
      );
    } catch (e) {
      return MyAllServicesModel(status: false, message: e.toString());
    }
  }

  @override
  Future<HomeModel> getFeaturedWorkshop(Map<String, String> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(ApiConstants.getHomeData, data: request);

      if (response.statusCode == 200) {
        return HomeModel.fromJson(response.data);
      } else {
        throw Exception("Failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return HomeModel(status: false, message: e.toString());
    }
  }

  @override
  Future<AllAddressesModel> getAllAddress() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getAllAddresses,
      );

      if (response.statusCode == 200) {
        return AllAddressesModel.fromJson(response.data);
      } else {
        throw Exception("${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return AllAddressesModel(status: false);
    }
  }

  @override
  Future<AddAddressModel> addAddress(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.post(ApiConstants.addAddress, data: request);

      if (response.statusCode == 201) {
        return AddAddressModel.fromJson(response.data);
      } else {
        throw Exception("Failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  @override
  Future<GetUpiIdModel> getAllUpiId() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(ApiConstants.getAllUpiId);

      if (response.statusCode == 200) {
        return GetUpiIdModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch UPI IDs: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return GetUpiIdModel(
        success: false,
      );
    }
  }

  @override
  Future<AddUpiIdModel> addAllUpiId(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.post(
        ApiConstants.addAllUpiId,
        data: request,
      );

      if (response.statusCode == 200) {
        return AddUpiIdModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data["message"] ?? "Unknown error occurred";
        throw Exception(errorMessage);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      return AddUpiIdModel(success: false, message: e.toString());
    }
  }

  @override
  Future<DeleteUpiIdModel> deleteUpiId(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.delete(
        ApiConstants.deleteUpiId,
        data: request,
      );

      if (response.statusCode == 200) {
        return DeleteUpiIdModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data["message"] ?? "Unknown error occurred";
        throw Exception(errorMessage);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      return DeleteUpiIdModel(
          success: false, message: e.toString(), upiIds: []);
    }
  }

  @override
  Future<MlmDownLinesModel> getAllDownLines(
      Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(
        ApiConstants.getAllDownLines,
        queryParameters: request,
      );

      if (response.statusCode == 200) {
        return MlmDownLinesModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data["message"] ?? "Unknown error occurred";
        throw Exception(errorMessage);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      return MlmDownLinesModel(status: false, message: e.toString());
    }
  }

  @override
  Future<WithdrawModel> createWithdraw(Map<String, dynamic> request) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing. Please log in again.');
      }
      final response = await dio.post(
        ApiConstants.createWithdraw,
        data: request,
      );
      if (response.statusCode == 201) {
        return WithdrawModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data["message"] ?? "Network error occurred";
      throw Exception(errorMessage);
    } catch (e) {
      return WithdrawModel(status: false, message: e.toString());
    }
  }

  @override
  Future<WithdrawHistoryModel> withdrawalHistory() async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(ApiConstants.withdrawHistory);

      if (response.statusCode == 200) {
        return WithdrawHistoryModel.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to fetch Withdraw History: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception("Network error occurred");
      }
    } catch (e) {
      return WithdrawHistoryModel(
        status: false,
      );
    }
  }

  @override
  Future<CommonModel> deleteAddress(String id) async {
    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.delete(
        '${ApiConstants.deleteAddress}$id',
      );

      if (response.statusCode == 200) {
        return CommonModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMessage =
            e.response?.data["message"] ?? "Unknown error occurred";
        throw Exception(errorMessage);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      return CommonModel(status: false, message: e.toString());
    }
  }

  @override
  Future<FetchUserModel> fetchUserData() async {

    try {
      String? token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing in the request map.');
      }

      final response = await dio.get(ApiConstants.fetchUserDetail);

      if (response.statusCode == 200) {
        return FetchUserModel.fromJson(response.data);
      } else {
        throw Exception(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data["message"] ?? "Unknown error occurred");
      } else {
        throw Exception(e.toString());
      }
    } catch (e) {
      return FetchUserModel(status: false, message: e.toString());
    }
  }
}
