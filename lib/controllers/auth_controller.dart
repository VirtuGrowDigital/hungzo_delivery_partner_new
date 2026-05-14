// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
//
// import '../bindings/home_binding.dart';
// import '../constants/constants.dart';
// import '../data/models/login_and_registration_flow/registration/RegisterModel.dart';
// import '../model/user_model.dart';
// import '../screens/auth/create_account.dart';
// import '../screens/home_view.dart';
// import '../screens/auth/login/otp_verification.dart';
// import '../services/Api/api_services.dart';
// import '../utils/flutter_toast.dart';
// import '../utils/snack_bar.dart';
// import '../utils/string_constants.dart';
//
// class AuthController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   late final Dio dio;
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//   final isLoading = false.obs;
//   final isVerifying = false.obs;
//   final isResending = false.obs;
//
//   int? _resendToken;
//
//   /// ================= PHONE AUTH =================
//   Future<void> verifyPhone({required String phone}) async {
//     try {
//       isLoading.value = true;
//
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phone,
//         verificationCompleted: (_) {},
//
//         verificationFailed: (e) {
//           isLoading.value = false;
//           CustomSnackBar(
//             e.message ?? TextConstants.verificationFailed,
//             'E',
//           );
//         },
//
//         codeSent: (verificationId, resendToken) {
//           _resendToken = resendToken;
//           isLoading.value = false;
//
//           Get.to(() => OTPVerificationScreen(
//             phoneNumber: phone,
//             verificationId: verificationId,
//           ));
//         },
//
//         codeAutoRetrievalTimeout: (_) {
//           isLoading.value = false;
//         },
//       );
//     } catch (e) {
//       isLoading.value = false;
//       CustomSnackBar(e.toString(), 'E');
//     }
//   }
//
//   /// ================= VERIFY OTP =================
//   Future<void> verifyOTP({
//     required String otp,
//     required String verificationId,
//   }) async {
//     if (otp.length != 6) {
//       CustomSnackBar(TextConstants.enterCompleteOtp, 'E');
//       return;
//     }
//
//     try {
//       isVerifying.value = true;
//
//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otp,
//       );
//
//       final userCred =
//       await _auth.signInWithCredential(credential);
//
//       await _handleUserLogin(userCred.user!);
//     } on FirebaseAuthException catch (e) {
//       CustomSnackBar(
//         e.message ?? TextConstants.invalidOtp,
//         'E',
//       );
//     } catch (_) {
//       CustomSnackBar(TextConstants.somethingWentWrong, 'E');
//     } finally {
//       isVerifying.value = false;
//     }
//   }
//
//   /// ================= USER CHECK =================
//   Future<void> _handleUserLogin(User user) async {
//     final doc =
//     await _db.collection('users').doc(user.uid).get();
//
//     /// ✅ USER EXISTS → HOME
//     if (doc.exists) {
//       try {
//         final user = FirebaseAuth.instance.currentUser;
//
//         if (user == null) {
//           throw Exception('Firebase user not found');
//         }
//
//         // 1️⃣ Get Firebase ID Token
//         final firebaseToken = await user.getIdToken(true);
//
//         // 2️⃣ Call Backend Firebase Login API
//         final apiService = ApiService(dio: Dio()); // no dio null
//         await apiService.firebaseLogin(firebaseToken!);
//
//         // 3️⃣ Navigate ONLY after API success
//         Get.offAll(
//               () => const HomeView(),
//           binding: HomeBinding(),
//         );
//       } catch (e) {
//         Message_Utils.displayToast(
//           'Login failed. Please try again.',
//         );
//       }
//     }
//
//     /// ❌ NEW USER → CREATE ACCOUNT
//     else {
//       Get.offAll(() => CreateAccountScreen(user: user));
//     }
//   }
//
//   /// ================= CREATE USER AFTER SIGNUP =================
//   Future<void> createUserProfile(UserModel userModel) async {
//     try {
//       // 1️⃣ Save user in Firestore
//       await _db
//           .collection('users')
//           .doc(userModel.uid)
//           .set(userModel.toMap());
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('Firebase user not found');
//       }
//
//       // 2️⃣ Get backend token (already saved after firebaseLogin)
//       final token = await secureStorage.read(key: Constants.accessToken);
//       if (token == null) {
//         throw Exception('Backend token missing');
//       }
//
//       // 3️⃣ BUILD REQUEST BODY ✅
//       final Map<String, dynamic> requestBody = {
//         "ownerName": userModel.fullName,
//         "restaurantName": userModel.restaurantName,
//         "gst": userModel.gstNumber,
//         "fssai": userModel.fssaiLicenseNumber,
//         "address": {
//           "label": userModel.city,
//           "city": userModel.city,
//           "state": userModel.state,
//           "pincode": userModel.pincode,
//         }
//       };
//
//       // 4️⃣ Call register API
//       // final apiService = ApiService();
//       final apiService = ApiService(dio: Dio()); // no dio null
//       final result =
//       await apiService.firebaseRegister(requestBody);
//
//       if (result.status == true) {
//         Get.offAll(
//               () => const HomeView(),
//           binding: HomeBinding(),
//         );
//       } else {
//         Message_Utils.displayToast(result.message ?? 'Registration failed');
//       }
//     } catch (e) {
//       Message_Utils.displayToast(e.toString());
//     }
//   }
//   Future<String?> getAccessToken() async {
//     return await secureStorage.read(key: 'accessToken');
//   }
//
//   Future<String?> getRefreshToken() async {
//     return await secureStorage.read(key: 'refreshToken');
//   }
//
//   /// ================= RESEND OTP =================
//   Future<void> resendOTP(String phone) async {
//     try {
//       isResending.value = true;
//
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phone,
//         forceResendingToken: _resendToken,
//
//         verificationCompleted: (_) {},
//
//         verificationFailed: (e) {
//           CustomSnackBar(
//             e.message ?? TextConstants.verificationFailed,
//             'E',
//           );
//         },
//
//         codeSent: (_, resendToken) {
//           _resendToken = resendToken;
//           CustomSnackBar(TextConstants.otpResent, 'S');
//         },
//
//         codeAutoRetrievalTimeout: (_) {},
//       );
//     } finally {
//       isResending.value = false;
//     }
//   }
//
//   /// ================= AUTH CHECK =================
//   bool isUserLoggedIn() {
//     return _auth.currentUser != null;
//   }
//
//   /// ================= UPLOAD PROFILE IMAGE =================
//   Future<String> uploadProfileImage({
//     required File image,
//     required String uid,
//   }) async {
//     try {
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('users/profile_photos/$uid.jpg');
//
//       final uploadTask = ref.putFile(image);
//
//       await uploadTask;
//
//       return await ref.getDownloadURL();
//     } catch (e) {
//       CustomSnackBar('Image upload failed', 'E');
//       rethrow;
//     }
//   }
// }

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../constants/constants.dart';
import '../screens/auth/create_account.dart';
import '../services/Api/api_services.dart';
import '../utils/flutter_toast.dart';
import '../utils/snack_bar.dart';
import '../utils/string_constants.dart';

enum AuthBootstrapState { loggedOut, needsProfile, authenticated }

class PendingOtpSession {
  const PendingOtpSession({
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;
}

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ApiService apiService = ApiService(dio: Dio());
  User? get currentUser => _auth.currentUser;

  final isLoading = false.obs;
  final isVerifying = false.obs;
  final isResending = false.obs;

  int? _resendToken;

  /// ================= PHONE AUTH =================
  Future<void> verifyPhone({required String phone}) async {
    try {
      isLoading.value = true;
      await SmsAutoFill().listenForCode();

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          isLoading.value = false;
          try {
            final userCred = await _auth.signInWithCredential(credential);
            if (userCred.user != null) {
              await _completeVerifiedSignIn(userCred.user!);
            }
          } on FirebaseAuthException catch (e) {
            CustomSnackBar(e.message ?? TextConstants.verificationFailed, 'E');
          }
        },

        verificationFailed: (e) async {
          isLoading.value = false;
          await _clearPendingOtpSession();
          CustomSnackBar(e.message ?? TextConstants.verificationFailed, 'E');
        },

        codeSent: (verificationId, resendToken) async {
          _resendToken = resendToken;
          isLoading.value = false;
          await _cachePendingOtpSession(
            verificationId: verificationId,
            phoneNumber: phone,
          );

          Get.toNamed(
            "/otp",
            arguments: {
              "phoneNumber": phone,
              "verificationId": verificationId,
            },
          );
        },

        codeAutoRetrievalTimeout: (_) {
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar(e.toString(), 'E');
    }
  }

  /// ================= VERIFY OTP =================
  Future<void> verifyOTP({
    required String otp,
    required String verificationId,
  }) async {
    if (otp.length != 6) {
      CustomSnackBar(TextConstants.enterCompleteOtp, 'E');
      return;
    }

    try {
      isVerifying.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCred = await _auth.signInWithCredential(credential);

      final user = userCred.user;
      if (user == null) {
        throw Exception('Firebase user not found');
      }

      await _completeVerifiedSignIn(user);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException $e");
      CustomSnackBar(e.message ?? TextConstants.invalidOtp, 'E');
    } catch (_) {
      CustomSnackBar(TextConstants.somethingWentWrong, 'E');
    } finally {
      isVerifying.value = false;
    }
  }

  /// ================= USER CHECK =================
  Future<bool> _handleUserLogin(User user) async {
    try {
      final loginData = await _syncBackendSession(user);

      if (_isProfileCompleted(loginData)) {
        Get.offAll(() => const DeliveryHomeScreen());
      } else {
        Get.offAll(() => CreateAccountScreen(user: user));
      }
      return true;
    } catch (e) {
      Message_Utils.displayToast('Login failed. Please try again.');
      return false;
    }
  }

  Future<void> _completeVerifiedSignIn(User user) async {
    final didLoginSucceed = await _handleUserLogin(user);
    if (didLoginSucceed) {
      await _clearPendingOtpSession();
    }
  }

  /// ================= CREATE USER AFTER SIGNUP =================

  Future<void> createDriverProfile({
    required String name,
    required String vehicleType,
    required String vehicleNumber,
    required File aadharImage,
    required File licenseImage,
    required File vehicleImage,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Firebase user not found");
      }

      await _syncBackendSession(user);

      final token = await secureStorage.read(key: Constants.accessToken);
      if (token == null || token.isEmpty) {
        throw Exception("Backend token missing");
      }

      final registerResult = await apiService.firebaseRegister(
        name: name,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        aadharImage: aadharImage,
        licenseImage: licenseImage,
        vehicleImage: vehicleImage,
      );

      if (registerResult.status == true) {
        final profile = await apiService.getDriverProfile();
        if (profile != null && profile.driverId.isNotEmpty) {
          await _cacheAuthenticatedDriver(profile.driverId);
        }
        Get.offAll(() => const DeliveryHomeScreen());
      } else {
        Message_Utils.displayToast(registerResult.message);
      }
    } catch (e) {
      debugPrint("DRIVER ERROR: $e");
      Message_Utils.displayToast(e.toString());
    }
  }

  /// ================= RESEND OTP =================
  Future<String?> resendOTP(String phone) async {
    try {
      isResending.value = true;
      await SmsAutoFill().listenForCode();

      String? latestVerificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,

        verificationCompleted: (credential) async {
          try {
            final userCred = await _auth.signInWithCredential(credential);
            if (userCred.user != null) {
              await _completeVerifiedSignIn(userCred.user!);
            }
          } on FirebaseAuthException catch (e) {
            CustomSnackBar(e.message ?? TextConstants.verificationFailed, 'E');
          }
        },

        verificationFailed: (e) {
          CustomSnackBar(e.message ?? TextConstants.verificationFailed, 'E');
        },

        codeSent: (verificationId, resendToken) async {
          latestVerificationId = verificationId;
          _resendToken = resendToken;
          await _cachePendingOtpSession(
            verificationId: verificationId,
            phoneNumber: phone,
          );
          CustomSnackBar(TextConstants.otpResent, 'S');
        },

        codeAutoRetrievalTimeout: (_) {},
      );

      return latestVerificationId;
    } finally {
      isResending.value = false;
    }
  }

  Future<AuthBootstrapState> restoreSession() async {
    final user = _auth.currentUser;
    final hasAccessToken = await _hasStoredAccessToken();
    final hasRefreshToken = await _hasStoredRefreshToken();
    final cachedState = await _readCachedBootstrapState();

    if (hasAccessToken) {
      final profile = await apiService.getDriverProfile();
      if (profile != null && profile.driverId.isNotEmpty) {
        await _cacheAuthenticatedDriver(profile.driverId);
        return AuthBootstrapState.authenticated;
      }
    }

    if (!hasAccessToken && hasRefreshToken) {
      final refreshed = await apiService.tryRefreshSession();
      if (refreshed) {
        final refreshedProfile = await apiService.getDriverProfile();
        if (refreshedProfile != null && refreshedProfile.driverId.isNotEmpty) {
          await _cacheAuthenticatedDriver(refreshedProfile.driverId);
          return AuthBootstrapState.authenticated;
        }
      }
    }

    if (user == null) {
      if (await hasPendingOtpSession()) {
        return AuthBootstrapState.loggedOut;
      }
      await _clearStoredSession();
      return AuthBootstrapState.loggedOut;
    }

    try {
      final loginData = await _syncBackendSession(user);
      return _isProfileCompleted(loginData)
          ? AuthBootstrapState.authenticated
          : AuthBootstrapState.needsProfile;
    } catch (e) {
      if (cachedState == AuthBootstrapState.needsProfile &&
          (hasAccessToken || hasRefreshToken)) {
        return AuthBootstrapState.needsProfile;
      }

      if (await hasPendingOtpSession()) {
        return AuthBootstrapState.loggedOut;
      }

      await _clearStoredSession();
      await _auth.signOut();
      return AuthBootstrapState.loggedOut;
    }
  }

  Future<void> logout({bool showSuccessMessage = true}) async {
    Object? revokeError;

    try {
      await apiService.logoutCurrentSession();
    } catch (e) {
      revokeError = e;
      debugPrint("Logout revoke failed: $e");
    }

    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Firebase logout failed: $e");
    }

    await _clearStoredSession();
    await _clearPendingOtpSession();

    if (showSuccessMessage) {
      if (revokeError == null) {
        CustomSnackBar("Logged out successfully", "S");
      } else {
        CustomSnackBar(
          "Logged out locally. Session revoke will retry on next login.",
          "S",
        );
      }
    }
  }

  Future<void> deleteAccount() async {
    await apiService.deleteCurrentAccount();
    await _auth.signOut();
    await _clearStoredSession();
    await _clearPendingOtpSession();
  }

  Future<Map<String, dynamic>> _syncBackendSession(User user) async {
    final firebaseToken = await user.getIdToken(true);
    if (firebaseToken == null || firebaseToken.isEmpty) {
      throw Exception('Firebase token missing');
    }
    await secureStorage.write(key: Constants.fcmToken, value: firebaseToken);
    final loginData = await apiService.firebaseLogin(firebaseToken);
    await _cacheLoginState(loginData);
    return loginData;
  }

  bool _isProfileCompleted(Map<String, dynamic> loginData) {
    final user = loginData['user'];
    if (user is! Map) {
      return false;
    }

    final backendUser = Map<String, dynamic>.from(user);
    final isProfileCompleted = backendUser['isProfileCompleted'] == true;
    final driverId = backendUser['driverId'];
    return isProfileCompleted && driverId != null;
  }

  Future<void> _clearStoredSession() async {
    await secureStorage.delete(key: Constants.accessToken);
    await secureStorage.delete(key: Constants.refreshToken);
    await secureStorage.delete(key: Constants.fcmToken);
    await secureStorage.delete(key: Constants.authProfileCompleted);
    await secureStorage.delete(key: Constants.authDriverId);
  }

  Future<void> _cachePendingOtpSession({
    required String verificationId,
    required String phoneNumber,
  }) async {
    await secureStorage.write(
      key: Constants.pendingOtpVerificationId,
      value: verificationId,
    );
    await secureStorage.write(
      key: Constants.pendingOtpPhoneNumber,
      value: phoneNumber,
    );
  }

  Future<PendingOtpSession?> getPendingOtpSession() async {
    final verificationId = await secureStorage.read(
      key: Constants.pendingOtpVerificationId,
    );
    final phoneNumber = await secureStorage.read(
      key: Constants.pendingOtpPhoneNumber,
    );

    if (verificationId == null ||
        verificationId.isEmpty ||
        phoneNumber == null ||
        phoneNumber.isEmpty) {
      return null;
    }

    return PendingOtpSession(
      verificationId: verificationId,
      phoneNumber: phoneNumber,
    );
  }

  Future<bool> hasPendingOtpSession() async {
    return await getPendingOtpSession() != null;
  }

  Future<void> clearPendingOtpSession() async {
    await _clearPendingOtpSession();
  }

  Future<void> _clearPendingOtpSession() async {
    await secureStorage.delete(key: Constants.pendingOtpVerificationId);
    await secureStorage.delete(key: Constants.pendingOtpPhoneNumber);
  }

  Future<bool> _hasStoredAccessToken() async {
    final token = await secureStorage.read(key: Constants.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<bool> _hasStoredRefreshToken() async {
    final token = await secureStorage.read(key: Constants.refreshToken);
    return token != null && token.isNotEmpty;
  }

  Future<AuthBootstrapState?> _readCachedBootstrapState() async {
    final isProfileCompleted = await secureStorage.read(
      key: Constants.authProfileCompleted,
    );
    final driverId = await secureStorage.read(key: Constants.authDriverId);

    if (isProfileCompleted == 'true' &&
        driverId != null &&
        driverId.isNotEmpty) {
      return AuthBootstrapState.authenticated;
    }

    if (isProfileCompleted == 'false') {
      return AuthBootstrapState.needsProfile;
    }

    return null;
  }

  Future<void> _cacheLoginState(Map<String, dynamic> loginData) async {
    final isProfileCompleted = _isProfileCompleted(loginData);
    final user = loginData['user'];
    String? driverId;

    if (user is Map) {
      driverId = user['driverId']?.toString();
    }

    await secureStorage.write(
      key: Constants.authProfileCompleted,
      value: isProfileCompleted.toString(),
    );

    if (driverId != null && driverId.isNotEmpty) {
      await secureStorage.write(key: Constants.authDriverId, value: driverId);
    } else {
      await secureStorage.delete(key: Constants.authDriverId);
    }
  }

  Future<void> _cacheAuthenticatedDriver(String driverId) async {
    await secureStorage.write(
      key: Constants.authProfileCompleted,
      value: true.toString(),
    );
    await secureStorage.write(key: Constants.authDriverId, value: driverId);
  }

  /// ================= UPLOAD PROFILE IMAGE =================
  Future<String> uploadProfileImage({
    required File image,
    required String uid,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'users/profile_photos/$uid.jpg',
      );

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      CustomSnackBar('Image upload failed', 'E');
      rethrow;
    }
  }
}
