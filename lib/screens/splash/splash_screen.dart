import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../services/app_update_service.dart';
import '../../utils/color_constants.dart';
import '../../utils/ImageConstant.dart';
import '../auth/login/login_screen.dart';
import '../auth/create_account.dart';
import '../update/app_update_bottom_sheet.dart';
import '../update/app_update_required_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1200);
  static const Duration _updateCheckTimeout = Duration(seconds: 3);

  late final AnimationController _slideController;
  late final AnimationController _logoController;
  late final AnimationController _logoZoomController;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoZoomAnimation;

  final AuthController _authController = Get.find<AuthController>();
  late final Future<_SplashBootstrapResult> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _bootstrapFuture = _bootstrapApp();
    _startFlow();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _logoZoomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _logoScaleAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoFadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoZoomAnimation = Tween(begin: 1.0, end: 4.0).animate(
      CurvedAnimation(parent: _logoZoomController, curve: Curves.easeInCubic),
    );
  }

  Future<_SplashBootstrapResult> _bootstrapApp() async {
    final authFuture = _authController.restoreSession();
    final updateFuture = AppUpdateService.instance.getUpdateDecision().timeout(
      _updateCheckTimeout,
      onTimeout: () => null,
    );

    final authState = await authFuture;
    final updateDecision = await updateFuture;

    return _SplashBootstrapResult(
      authState: authState,
      updateDecision: updateDecision,
    );
  }

  Future<void> _startFlow() async {
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 250));

    _logoController.forward();
    await Future.wait([
      _bootstrapFuture,
      Future.delayed(_minimumSplashDuration),
    ]);

    _logoZoomController.forward();
    await Future.delayed(const Duration(milliseconds: 250));

    final bootstrapResult = await _bootstrapFuture;
    await _navigateNext(bootstrapResult);
  }

  Future<void> _navigateNext(_SplashBootstrapResult bootstrapResult) async {
    if (!mounted) return;

    final authState = bootstrapResult.authState;
    final updateDecision = bootstrapResult.updateDecision;

    if (updateDecision?.isMandatory == true) {
      Get.offAll(() => AppUpdateRequiredScreen(decision: updateDecision!));
      return;
    }

    if (authState == AuthBootstrapState.authenticated) {
<<<<<<< HEAD
      Get.offAll(() => const DeliveryHomeScreen());
=======
      Get.offAll(() => const DeliveryHomeScreen(), binding: HomeBinding());
      if (updateDecision != null) {
        _showOptionalUpdate(updateDecision);
      }
>>>>>>> 265a8b57 (updated)
      return;
    }

    if (authState == AuthBootstrapState.needsProfile) {
      Get.offAll(() => const CreateAccountScreen());
      if (updateDecision != null) {
        _showOptionalUpdate(updateDecision);
      }
      return;
    }

    final pendingOtpSession = await _authController.getPendingOtpSession();
    if (!mounted) return;

    if (pendingOtpSession != null) {
      Get.offAllNamed(
        '/otp',
        arguments: {'phoneNumber': pendingOtpSession.phoneNumber},
      );
      if (updateDecision != null) {
        _showOptionalUpdate(updateDecision);
      }
      return;
    }

    Get.offAll(() => const LoginScreen());
    if (updateDecision != null) {
      _showOptionalUpdate(updateDecision);
    }
  }

  void _showOptionalUpdate(AppUpdateDecision decision) {
    Future<void>.delayed(const Duration(milliseconds: 320), () async {
      final context = Get.overlayContext;
      if (context == null || !context.mounted) {
        return;
      }
      await AppUpdateBottomSheet.show(context, decision);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _logoController.dispose();
    _logoZoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ColorConstants.screenBackgroundGradient,
          ),
        ),
        child: Stack(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  ImageConstant.splashBackGraundImage,
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Center(
              child: ScaleTransition(
                scale: _logoZoomAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: _buildLogo(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildLogodLogo() {
  //   return Container(
  //     width: 280,
  //     height: 280,
  //     decoration: BoxDecoration(
  //       color: Colors.green,
  //       shape: BoxShape.circle,
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Colors.white,
  //           blurRadius: 20,
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.all(10),
  //     child: ClipOval(
  //       child: Image.asset(
  //         ImageConstant.logoHungZo,
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 0.92,
            child: Image.asset(ImageConstant.logoHungZo, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            "Delivery Partner",
            style: TextStyle(
              color: ColorConstants.success,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashBootstrapResult {
  const _SplashBootstrapResult({
    required this.authState,
    required this.updateDecision,
  });

  final AuthBootstrapState authState;
  final AppUpdateDecision? updateDecision;
}
