import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ImageConstant.dart';
import '../../../utils/snack_bar.dart';
import '../../../utils/string_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    print("On Click Continue");
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      CustomSnackBar(TextConstants.invalidPhoneNumber, 'E');
      return;
    }

    final phone = '$_countryCode${_phoneController.text}';

    /// CALL CONTROLLER METHOD
    authController.verifyPhone(phone: phone);
  }

  void _handleGoogleSignIn() {
    print('Google Sign In clicked');
  }

  void _handleSkip() {
    print('Skip clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [

                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      TextConstants.skipForNow,
                      style: TextStyle(
                        color: ColorConstants.accentOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Logo
                Image.asset(
                  ImageConstant.logoHungZo,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        TextConstants.loginOrSignup,
                        style: TextStyle(
                          color: ColorConstants.textOne,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 20),

                // Phone input section
                Row(
                  children: [
                  SizedBox(
                  width: 80, // 👈 control width here
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: CountryCodePicker(
                      onChanged: (country) {
                        _countryCode = country.dialCode!;
                      },
                      initialSelection: 'IN',
                      favorite: const ['+91', 'IN'],
                      showCountryOnly: true,
                      showOnlyCountryWhenClosed: true,
                      showFlag: true,
                      showDropDownButton: false, // 👈 remove arrow if needed
                      alignLeft: true,          // 👈 important
                      padding: EdgeInsets.zero,
                      flagWidth: 28,
                      hideMainText: true,

                    ),
                  ),
                ),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                _countryCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                  hintText: TextConstants.enterPhoneNumber,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// CONTINUE BUTTON (GetX Loading)
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        TextConstants.continueText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        TextConstants.orText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/logo/google_icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  TextConstants.useAnotherMethod,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
