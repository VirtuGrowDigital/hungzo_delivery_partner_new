import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';

import '../../bindings/home_binding.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/color_constants.dart';
import '../../utils/ImageConstant.dart';
import '../auth/login/login_screen.dart';
import '../home_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _logoController;
  late final AnimationController _logoZoomController;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoZoomAnimation;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
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

    _slideAnimation = Tween(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _logoScaleAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    _logoZoomAnimation = Tween(begin: 1.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _logoZoomController,
        curve: Curves.easeInCubic,
      ),
    );
  }

  Future<void> _startFlow() async {
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 1400));

    _logoZoomController.forward();
    await Future.delayed(const Duration(milliseconds: 450));

    _navigateNext();
  }

  void _navigateNext() {
    final isLoggedIn = _authController.isUserLoggedIn();

    if (isLoggedIn) {
      Get.offAll(
            () => const DeliveryHomeScreen(),
        binding: HomeBinding(),
      );
    } else {
      Get.offAll(() => const LoginScreen());
    }
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
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // outer solid color
          ),
          padding: const EdgeInsets.all(12), // border thickness
          child:
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstants.primary, // inner background
            ),
            padding: const EdgeInsets.all(10),
            child: ClipOval(
              child: Image.asset(
                ImageConstant.logoHungZo,
                fit: BoxFit.cover,
              ),
            ),
          ),

        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Text("Delivery Partner",style: TextStyle(color: ColorConstants.success,fontSize: 20,fontWeight: FontWeight.bold),),
        )
      ],
    );
  }

}
