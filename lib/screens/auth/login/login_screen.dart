import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/auth_controller.dart';
import '../../../services/Api/api_constants.dart';
import '../../../utils/ImageConstant.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/snack_bar.dart';
import '../../../utils/string_constants.dart';
import '../../policy_document_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialPhoneNumber;

  const LoginScreen({super.key, this.initialPhoneNumber});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  final String _countryCode = '+91';
  String _termsOfServiceUrl = '';
  String _privacyPolicyUrl = '';

  @override
  void initState() {
    super.initState();
    final initialDigits = (widget.initialPhoneNumber ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (initialDigits.isNotEmpty) {
      _phoneController.text = initialDigits.length > 10
          ? initialDigits.substring(initialDigits.length - 10)
          : initialDigits;
    }
    authController.restorePendingOtpSessionState(
      phoneHint: initialDigits.isEmpty ? null : '$_countryCode$initialDigits',
    );
    _loadAppConfiguration();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      CustomSnackBar(TextConstants.invalidPhoneNumber, 'E');
      return;
    }

    final formattedPhone = '$_countryCode$digits';
    if (!authController.canRequestOtpFor(formattedPhone)) {
      return;
    }

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    authController.verifyPhone(phone: formattedPhone);
  }

  Future<void> _loadAppConfiguration() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseURL}store/config?app=delivery_partner'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return;
      }

      final config = data['config'];
      if (config is! Map<String, dynamic>) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _termsOfServiceUrl =
            config['termsOfServiceUrl']?.toString().trim() ?? '';
        _privacyPolicyUrl = config['privacyPolicyUrl']?.toString().trim() ?? '';
      });
    } catch (error) {
      debugPrint('Driver app configuration fetch skipped: $error');
    }
  }

  Future<void> _openLegalDestination({
    required String label,
    required String policyKey,
    required String url,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isNotEmpty) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return;
        }
      }
      CustomSnackBar('Unable to open $label right now.', 'E');
    }

    if (!mounted) return;
    Get.to(
      () => PolicyDocumentScreen(
        appKey: 'DELIVERY_PARTNER',
        policyKey: policyKey,
        title: label,
      ),
    );
  }

  Widget _buildLegalLink({
    required String label,
    required String policyKey,
    required String url,
  }) {
    return GestureDetector(
      onTap: () =>
          _openLegalDestination(label: label, policyKey: policyKey, url: url),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ColorConstants.success,
          decoration: TextDecoration.underline,
          decorationColor: ColorConstants.success,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                            height: 150,
                            child: Image.asset(
                              ImageConstant.logoHungZo,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'Log in',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: ColorConstants.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your mobile number to continue.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: ColorConstants.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConstants.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  '+91',
                                  style: TextStyle(
                                    color: ColorConstants.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AutofillGroup(
                                  child: TextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocusNode,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (_) => setState(() {}),
                                    autofillHints: const [
                                      AutofillHints.telephoneNumber,
                                    ],
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    onSubmitted: (_) => _handleContinue(),
                                    decoration: const InputDecoration(
                                      hintText: TextConstants.enterPhoneNumber,
                                      hintStyle: TextStyle(
                                        color: ColorConstants.textTertiary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 18,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: ColorConstants.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(() {
                          final digits = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          final formattedPhone = digits.length == 10
                              ? '$_countryCode$digits'
                              : '';
                          final hasValidPhone = digits.length == 10;
                          final cooldownSeconds = formattedPhone.isEmpty
                              ? 0
                              : authController.remainingRequestCooldownFor(
                                  formattedPhone,
                                );
                          final canContinue =
                              hasValidPhone &&
                              authController.canRequestOtpFor(formattedPhone);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: canContinue
                                      ? _handleContinue
                                      : null,
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
                                  child: authController.isLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          TextConstants.continueText,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              if (hasValidPhone && cooldownSeconds > 0) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Request again in ${cooldownSeconds}s.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: ColorConstants.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            Text(
                              'By continuing, you agree to our',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                height: 1.45,
                                color: ColorConstants.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildLegalLink(
                              label: 'Terms of service',
                              policyKey: 'DELIVERY_PARTNER_TERMS',
                              url: _termsOfServiceUrl,
                            ),
                            Text(
                              '&',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: ColorConstants.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildLegalLink(
                              label: 'Privacy policy',
                              policyKey: 'DELIVERY_PARTNER_PRIVACY',
                              url: _privacyPolicyUrl,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SMS verification will be used for sign in.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            height: 1.4,
                            color: ColorConstants.textSecondary,
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
    );
  }
}
