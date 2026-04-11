import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ImageConstant.dart';
import '../../widgets/OTP_field.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthController authController = Get.find<AuthController>();

  static const int otpLength = 6;

  final List<TextEditingController> _otpControllers =
  List.generate(otpLength, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(otpLength, (_) => FocusNode());

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  void _verifyOTP() {
    if (_otpCode.length < otpLength) return;

    authController.verifyOTP(
      otp: _otpCode,
      verificationId: widget.verificationId,
    );
  }

  void _resendOTP() {
    authController.resendOTP(widget.phoneNumber);
    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Image.asset(
              ImageConstant.logoHungZo,
              height: 140,
            ),

            const SizedBox(height: 30),

            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

             Text(
              'An OTP has been sent to your contact number ${widget.phoneNumber}',
              // 'An OTP has been sent to your contact number is +91 7765044459',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 32),

            /// ✅ 6 DIGIT OTP INPUTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(otpLength, (index) {
                return OTPInput(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  prevFocus:
                  index > 0 ? _focusNodes[index - 1] : null,
                  nextFocus:
                  index < otpLength - 1
                      ? _focusNodes[index + 1]
                      : null,
                );
              }),
            ),

            const SizedBox(height: 40),

            /// SUBMIT BUTTON
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: authController.isVerifying.value
                    ? null
                    : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: authController.isVerifying.value
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 18),

            /// RESEND OTP
            Obx(() => TextButton(
              onPressed: authController.isResending.value
                  ? null
                  : _resendOTP,
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: ColorConstants.orangeRed,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
