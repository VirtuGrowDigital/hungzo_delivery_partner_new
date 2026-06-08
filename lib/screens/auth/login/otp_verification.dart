import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/ImageConstant.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/snack_bar.dart';
import '../../../utils/string_constants.dart';
import 'login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  static const int otpLength = 6;

  final AuthController authController = Get.find<AuthController>();

  late String _phoneNumber;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber;
    authController.restorePendingOtpSessionState(phoneHint: _phoneNumber);
    _listenForCode();
  }

  Future<void> _listenForCode() async {
    try {
      await SmsAutoFill().listenForCode();
    } catch (_) {}
  }

  void _setOtpCodeSafely(String nextCode) {
    if (!mounted || _otpCode == nextCode) {
      return;
    }

    void applyUpdate() {
      if (!mounted || _otpCode == nextCode) {
        return;
      }

      setState(() {
        _otpCode = nextCode;
      });
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => applyUpdate());
      return;
    }

    applyUpdate();
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != otpLength) {
      CustomSnackBar(TextConstants.enterCompleteOtp, 'E');
      return;
    }

    await authController.verifyOTP(otp: _otpCode, phone: _phoneNumber);
  }

  Future<void> _resendOTP() async {
    if (!authController.canResendOtp) {
      return;
    }

    await authController.resendOTP(_phoneNumber);

    if (!mounted) return;

    _setOtpCodeSafely('');
    await _listenForCode();
  }

  String get _editablePhoneDigits {
    final digitsOnly = _phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= 10) {
      return digitsOnly;
    }

    return digitsOnly.substring(digitsOnly.length - 10);
  }

  Future<void> _returnToLogin() async {
    await authController.clearPendingOtpSession();
    if (!mounted) return;

    Get.off(() => LoginScreen(initialPhoneNumber: _editablePhoneDigits));
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _returnToLogin();
      },
      child: Scaffold(
        backgroundColor: ColorConstants.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ColorConstants.textPrimary,
          leading: IconButton(
            onPressed: _returnToLogin,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
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
                                onPressed: _returnToLogin,
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

                                _setOtpCodeSafely(nextCode);

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
                                onPressed:
                                    authController.isVerifying.value ||
                                        _otpCode.length != otpLength
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
                                onPressed: authController.canResendOtp
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
                                        authController
                                                    .resendCooldownSeconds
                                                    .value ==
                                                0
                                            ? 'Resend code'
                                            : 'Resend in ${authController.resendCooldownSeconds.value}s',
                                        style: TextStyle(
                                          color:
                                              authController
                                                      .resendCooldownSeconds
                                                      .value ==
                                                  0
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
