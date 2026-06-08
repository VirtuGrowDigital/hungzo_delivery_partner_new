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
import 'dart:async';

import 'package:dio/dio.dart';
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
    required this.phoneNumber,
    required this.requestedAt,
  });

  final String phoneNumber;
  final DateTime requestedAt;
}

class AuthController extends GetxController {
  static const Duration _otpCooldownDuration = Duration(seconds: 30);

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ApiService apiService = ApiService(dio: Dio());

  final isLoading = false.obs;
  final isVerifying = false.obs;
  final isResending = false.obs;
  final isAuthenticated = false.obs;
  final requestCooldownSeconds = 0.obs;
  final resendCooldownSeconds = 0.obs;

  String? _lastRequestedPhone;
  DateTime? _lastOtpRequestedAt;
  Timer? _requestCooldownTimer;
  Timer? _resendCooldownTimer;

  @override
  void onClose() {
    _requestCooldownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.onClose();
  }

  String? get lastRequestedPhone => _lastRequestedPhone;

  bool canRequestOtpFor(String phone) {
    if (isLoading.value) {
      return false;
    }

    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      return true;
    }

    if (_lastRequestedPhone == null || _lastRequestedPhone != normalizedPhone) {
      return true;
    }

    return requestCooldownSeconds.value == 0;
  }

  int remainingRequestCooldownFor(String phone) {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty ||
        _lastRequestedPhone == null ||
        _lastRequestedPhone != normalizedPhone) {
      return 0;
    }

    return requestCooldownSeconds.value;
  }

  bool get canResendOtp =>
      !isResending.value &&
      resendCooldownSeconds.value == 0 &&
      _lastRequestedPhone != null;

  int _remainingCooldownFrom(DateTime requestedAt) {
    final elapsed = DateTime.now().difference(requestedAt);
    final remaining = _otpCooldownDuration - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds + 1;
  }

  void _syncCooldownValues() {
    if (_lastOtpRequestedAt == null) {
      requestCooldownSeconds.value = 0;
      resendCooldownSeconds.value = 0;
      _requestCooldownTimer?.cancel();
      _resendCooldownTimer?.cancel();
      return;
    }

    final nextValue = _remainingCooldownFrom(_lastOtpRequestedAt!);
    requestCooldownSeconds.value = nextValue;
    resendCooldownSeconds.value = nextValue;

    if (nextValue == 0) {
      _requestCooldownTimer?.cancel();
      _resendCooldownTimer?.cancel();
    }
  }

  void _startCooldownTickers() {
    _requestCooldownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _syncCooldownValues();

    if (requestCooldownSeconds.value == 0) {
      return;
    }

    _requestCooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncCooldownValues();
    });
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncCooldownValues();
    });
  }

  Future<void> restorePendingOtpSessionState({String? phoneHint}) async {
    final pendingSession = await getPendingOtpSession();
    if (pendingSession == null) {
      _lastRequestedPhone = null;
      _lastOtpRequestedAt = null;
      _syncCooldownValues();
      return;
    }

    final normalizedHint = phoneHint?.trim();
    if (normalizedHint != null &&
        normalizedHint.isNotEmpty &&
        normalizedHint != pendingSession.phoneNumber) {
      return;
    }

    _lastRequestedPhone = pendingSession.phoneNumber;
    _lastOtpRequestedAt = pendingSession.requestedAt;
    _startCooldownTickers();
  }

  /// ================= PHONE AUTH =================
  Future<void> verifyPhone({required String phone}) async {
    final normalizedPhone = phone.trim();
    if (!canRequestOtpFor(normalizedPhone)) {
      CustomSnackBar(
        'Please wait ${remainingRequestCooldownFor(normalizedPhone)}s before requesting another OTP.',
        'W',
      );
      return;
    }

    try {
      isLoading.value = true;
      await SmsAutoFill().listenForCode();
      await apiService.requestDriverPhoneOtp(phone: normalizedPhone);
      final requestedAt = DateTime.now();
      _lastRequestedPhone = normalizedPhone;
      _lastOtpRequestedAt = requestedAt;
      await _cachePendingOtpSession(
        phoneNumber: normalizedPhone,
        requestedAt: requestedAt,
      );
      _startCooldownTickers();
      isLoading.value = false;

      Get.toNamed("/otp", arguments: {"phoneNumber": normalizedPhone});
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar(e.toString(), 'E');
    }
  }

  /// ================= VERIFY OTP =================
  Future<void> verifyOTP({required String otp, required String phone}) async {
    if (otp.length != 6) {
      CustomSnackBar(TextConstants.enterCompleteOtp, 'E');
      return;
    }

    try {
      isVerifying.value = true;
      final loginData = await apiService.verifyDriverPhoneOtp(
        phone: phone,
        code: otp,
      );
      await _completeVerifiedSignIn(loginData);
    } catch (e) {
      debugPrint("Driver OTP verify error: $e");
      CustomSnackBar(e.toString(), 'E');
    } finally {
      isVerifying.value = false;
    }
  }

  /// ================= USER CHECK =================
  Future<bool> _handleUserLogin(Map<String, dynamic> loginData) async {
    try {
      if (_isProfileCompleted(loginData)) {
<<<<<<< HEAD
        Get.offAll(() => const DeliveryHomeScreen());
=======
        final user = loginData['user'];
        final driverId = user is Map ? user['driverId']?.toString() ?? '' : '';
        if (driverId.isNotEmpty) {
          await _cacheAuthenticatedDriver(driverId);
        }
        isAuthenticated.value = true;
        Get.offAll(() => const DeliveryHomeScreen(), binding: HomeBinding());
>>>>>>> 265a8b57 (updated)
      } else {
        isAuthenticated.value = true;
        Get.offAll(() => const CreateAccountScreen());
      }
      return true;
    } catch (e) {
      Message_Utils.displayToast('Login failed. Please try again.');
      return false;
    }
  }

  Future<void> _completeVerifiedSignIn(Map<String, dynamic> loginData) async {
    await _cacheLoginState(loginData);
    final didLoginSucceed = await _handleUserLogin(loginData);
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
<<<<<<< HEAD
        Get.offAll(() => const DeliveryHomeScreen());
=======
        isAuthenticated.value = true;
        Get.offAll(() => const DeliveryHomeScreen(), binding: HomeBinding());
>>>>>>> 265a8b57 (updated)
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
    final normalizedPhone = phone.trim();
    if (!canResendOtp || _lastRequestedPhone != normalizedPhone) {
      CustomSnackBar(
        'Please wait ${remainingRequestCooldownFor(normalizedPhone)}s before requesting another OTP.',
        'W',
      );
      return null;
    }

    try {
      isResending.value = true;
      await SmsAutoFill().listenForCode();
      await apiService.requestDriverPhoneOtp(phone: normalizedPhone);
      final requestedAt = DateTime.now();
      _lastRequestedPhone = normalizedPhone;
      _lastOtpRequestedAt = requestedAt;
      await _cachePendingOtpSession(
        phoneNumber: normalizedPhone,
        requestedAt: requestedAt,
      );
      _startCooldownTickers();
      CustomSnackBar(TextConstants.otpResent, 'S');
      return normalizedPhone;
    } finally {
      isResending.value = false;
    }
  }

  Future<AuthBootstrapState> restoreSession() async {
    final hasAccessToken = await _hasStoredAccessToken();
    final hasRefreshToken = await _hasStoredRefreshToken();
    final cachedState = await _readCachedBootstrapState();

    if (hasAccessToken) {
      final profile = await apiService.getDriverProfile();
      if (profile != null && profile.driverId.isNotEmpty) {
        await _cacheAuthenticatedDriver(profile.driverId);
        isAuthenticated.value = true;
        return AuthBootstrapState.authenticated;
      }
    }

    if (!hasAccessToken && hasRefreshToken) {
      final refreshed = await apiService.tryRefreshSession();
      if (refreshed) {
        final refreshedProfile = await apiService.getDriverProfile();
        if (refreshedProfile != null && refreshedProfile.driverId.isNotEmpty) {
          await _cacheAuthenticatedDriver(refreshedProfile.driverId);
          isAuthenticated.value = true;
          return AuthBootstrapState.authenticated;
        }
      }
    }

    if (cachedState == AuthBootstrapState.needsProfile &&
        (hasAccessToken || hasRefreshToken)) {
      isAuthenticated.value = true;
      return AuthBootstrapState.needsProfile;
    }

    if (await hasPendingOtpSession()) {
      isAuthenticated.value = false;
      return AuthBootstrapState.loggedOut;
    }

    await _clearStoredSession();
    isAuthenticated.value = false;
    return AuthBootstrapState.loggedOut;
  }

  Future<void> logout({bool showSuccessMessage = true}) async {
    Object? revokeError;

    try {
      await apiService.logoutCurrentSession();
    } catch (e) {
      revokeError = e;
      debugPrint("Logout revoke failed: $e");
    }

    await _clearStoredSession();
    await _clearPendingOtpSession();
    isAuthenticated.value = false;

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

<<<<<<< HEAD
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

=======
>>>>>>> 265a8b57 (updated)
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
    await secureStorage.delete(key: Constants.authProfileCompleted);
    await secureStorage.delete(key: Constants.authDriverId);
  }

  Future<void> _cachePendingOtpSession({
    required String phoneNumber,
    required DateTime requestedAt,
  }) async {
    await secureStorage.write(
      key: Constants.pendingOtpPhoneNumber,
      value: phoneNumber,
    );
    await secureStorage.write(
      key: Constants.pendingOtpRequestedAt,
      value: requestedAt.toIso8601String(),
    );
  }

  Future<PendingOtpSession?> getPendingOtpSession() async {
    final phoneNumber = await secureStorage.read(
      key: Constants.pendingOtpPhoneNumber,
    );
    final requestedAtRaw = await secureStorage.read(
      key: Constants.pendingOtpRequestedAt,
    );

    if (phoneNumber == null ||
        phoneNumber.isEmpty ||
        requestedAtRaw == null ||
        requestedAtRaw.isEmpty) {
      return null;
    }

    final requestedAt = DateTime.tryParse(requestedAtRaw);
    if (requestedAt == null) {
      return null;
    }

    return PendingOtpSession(
      phoneNumber: phoneNumber,
      requestedAt: requestedAt,
    );
  }

  Future<bool> hasPendingOtpSession() async {
    return await getPendingOtpSession() != null;
  }

  Future<void> clearPendingOtpSession() async {
    await _clearPendingOtpSession();
  }

  Future<void> _clearPendingOtpSession() async {
    _requestCooldownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _lastRequestedPhone = null;
    _lastOtpRequestedAt = null;
    requestCooldownSeconds.value = 0;
    resendCooldownSeconds.value = 0;
    await secureStorage.delete(key: Constants.pendingOtpPhoneNumber);
    await secureStorage.delete(key: Constants.pendingOtpRequestedAt);
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
