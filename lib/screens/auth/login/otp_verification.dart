import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/ImageConstant.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/snack_bar.dart';
import '../../../utils/string_constants.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  static const int otpLength = 6;
  static const int resendCooldown = 30;

  final AuthController authController = Get.find<AuthController>();

  late String _verificationId;
  late String _phoneNumber;
  String _otpCode = '';
  int _secondsRemaining = resendCooldown;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _phoneNumber = widget.phoneNumber;
    _startResendCountdown();
    _listenForCode();
  }

  Future<void> _listenForCode() async {
    try {
      await SmsAutoFill().listenForCode();
    } catch (_) {}
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _secondsRemaining = resendCooldown;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {});
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != otpLength) {
      CustomSnackBar(TextConstants.enterCompleteOtp, 'E');
      return;
    }

    await authController.verifyOTP(
      otp: _otpCode,
      verificationId: _verificationId,
    );
  }

  Future<void> _resendOTP() async {
    if (_secondsRemaining > 0 || authController.isResending.value) {
      return;
    }

    final verificationId = await authController.resendOTP(_phoneNumber);
    if (verificationId != null && verificationId.isNotEmpty) {
      _verificationId = verificationId;
    }

    if (!mounted) return;

    setState(() {
      _otpCode = '';
    });
    _startResendCountdown();
    await _listenForCode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await authController.clearPendingOtpSession();
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ColorConstants.textPrimary,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 170,
                              height: 140,
                              child: Image.asset(
                                ImageConstant.logoHungZo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Enter OTP',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: ColorConstants.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We sent a 6-digit code to',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _phoneNumber,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: ColorConstants.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await authController.clearPendingOtpSession();
                                  if (Get.currentRoute == '/otp') {
                                    Get.offNamed('/login');
                                    return;
                                  }
                                  Get.back();
                                },
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: ColorConstants.primary700,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AutofillGroup(
                            child: PinFieldAutoFill(
                              currentCode: _otpCode,
                              codeLength: otpLength,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              autoFocus: true,
                              enableInteractiveSelection: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: BoxLooseDecoration(
                                gapSpace: 12,
                                radius: const Radius.circular(16),
                                bgColorBuilder: FixedColorBuilder(Colors.white),
                                strokeColorBuilder: FixedColorBuilder(
                                  ColorConstants.border,
                                ),
                                textStyle: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.textPrimary,
                                ),
                              ),
                              onCodeChanged: (code) {
                                final nextCode = (code ?? '').trim();
                                if (_otpCode == nextCode) return;

                                setState(() {
                                  _otpCode = nextCode;
                                });

                                if (nextCode.length == otpLength) {
                                  TextInput.finishAutofillContext();
                                  FocusScope.of(context).unfocus();
                                  _verifyOTP();
                                }
                              },
                              onCodeSubmitted: (_) => _verifyOTP(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: authController.isVerifying.value
                                    ? null
                                    : _verifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstants.success,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: ColorConstants
                                      .success
                                      .withValues(alpha: 0.55),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authController.isVerifying.value
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Verify & continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Obx(
                              () => TextButton(
                                onPressed:
                                    (_secondsRemaining == 0 &&
                                        !authController.isResending.value)
                                    ? _resendOTP
                                    : null,
                                child: authController.isResending.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ColorConstants.orangeRed,
                                        ),
                                      )
                                    : Text(
                                        _secondsRemaining == 0
                                            ? 'Resend code'
                                            : 'Resend in ${_secondsRemaining}s',
                                        style: TextStyle(
                                          color: _secondsRemaining == 0
                                              ? ColorConstants.orangeRed
                                              : ColorConstants.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
