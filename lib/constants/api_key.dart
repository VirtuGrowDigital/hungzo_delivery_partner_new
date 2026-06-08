import 'package:flutter/foundation.dart';

<<<<<<< HEAD
class RazorpayConfig {
  static const String _debugKey = "rzp_test_KJT1gVRXpP4vOB";
  static const String _releaseKey = "rzp_live_SojUV7qNee5LjD";

  static const String publicKey = String.fromEnvironment(
    "RAZORPAY_KEY_ID",
    defaultValue: kReleaseMode ? _releaseKey : _debugKey,
  );

  static String resolveCheckoutKey([String? backendKey]) {
    final candidate = (backendKey ?? "").trim();
    final resolved = candidate.isEmpty ? publicKey : candidate;

    if (kReleaseMode && resolved.startsWith("rzp_test_")) {
      throw StateError(
        "Release build cannot use a Razorpay test key. "
        "Update the backend or pass RAZORPAY_KEY_ID for release builds.",
      );
    }

    return resolved;
  }
}
=======
const String _razorpayTestKeyId = "rzp_test_KJT1gVRXpP4vOB";
const String _razorpayLiveKeyId = "rzp_live_SojUV7qNee5LjD";

String get razorPayApi => kReleaseMode ? _razorpayLiveKeyId : _razorpayTestKeyId;
>>>>>>> 265a8b57 (updated)
