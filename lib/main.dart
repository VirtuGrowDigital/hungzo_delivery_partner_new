 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:hungzo_delivery_partner/screens/IncomingOrdersScreen.dart';
import 'package:hungzo_delivery_partner/screens/auth/login/login_screen.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';
import 'package:hungzo_delivery_partner/screens/splash/splash_screen.dart';
import 'package:hungzo_delivery_partner/screens/tracking_screen.dart';
import 'package:hungzo_delivery_partner/services/Api/clint.dart';
import 'package:hungzo_delivery_partner/utils/ColorConstants.dart';
import 'bindings/app_binding.dart';
import 'controllers/order_controller.dart';
import 'firebase_options.dart';

void main() async {
  Get.put(OrderController(), permanent: true); // 🔥 ONLY ONCE

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>();
// Using ValueNotifier to dynamically switch theme
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.light);

  void _toggleTheme() {
    _themeNotifier.value = _themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, currentTheme, _) {
        return GetMaterialApp(
          // initialBinding: HomeBinding(),
          initialBinding: AppBinding(),
          // navigatorKey: Get.key,
          navigatorKey: rootNavigatorKey, // ✅ IMPORTANT
          getPages: [
            GetPage(name: "/", page: () => const SplashScreen()),
            GetPage(name: "/login", page: () => const LoginScreen()),
            GetPage(name: "/home", page: () => const DeliveryHomeScreen()),
          ],
          title: 'HungZo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: ColorConstants.primary,
            scaffoldBackgroundColor: ColorConstants.scaffoldBackground,
            colorScheme: ColorScheme.light(
              primary: ColorConstants.primary,
              secondary: ColorConstants.accent,
              background: ColorConstants.scaffoldBackground,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: ColorConstants.primaryDark,
            scaffoldBackgroundColor: ColorConstants.primaryDark.withOpacity(0.9),
            colorScheme: ColorScheme.dark(
              primary: ColorConstants.primaryDark,
              secondary: ColorConstants.accent,
              background: ColorConstants.primaryDark.withOpacity(0.9),
            ),
          ),
          themeMode: currentTheme,
          // Use the dynamic theme
          // home: MyHomePage(
          //   title: 'Home Page',
          //   toggleTheme: _toggleTheme,
          // ),
          //    home: HomeView(),
          //    home: IncomingOrdersScreen(),
            home: SplashScreen(),
            // home: DriverOrdersScreen(),
          // home: DeliveryTrackingScreen(),
          // home: FirebaseLoginScreen(),
          // home: CreateAccountScreen(),
          // home: OTPVerificationScreen(verificationId: '', phoneNumber: '',),
          // home: LoginScreen(),
        );
      },
    );
  }
}
