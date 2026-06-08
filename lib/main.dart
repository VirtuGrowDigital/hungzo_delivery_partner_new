import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hungzo_delivery_partner/screens/auth/login/login_screen.dart';
import 'package:hungzo_delivery_partner/screens/auth/login/otp_verification.dart';
import 'package:hungzo_delivery_partner/screens/delivery_home_screen.dart';
import 'package:hungzo_delivery_partner/screens/splash/splash_screen.dart';
import 'package:hungzo_delivery_partner/constants/color_constants.dart';
import 'bindings/app_binding.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Using ValueNotifier to dynamically switch theme
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, currentTheme, _) {
        return GetMaterialApp(
          initialBinding: AppBinding(),
          navigatorKey: rootNavigatorKey,
          initialRoute: "/",
          getPages: [
            GetPage(name: "/", page: () => const SplashScreen()),
            GetPage(name: "/login", page: () => const LoginScreen()),
            GetPage(
              name: "/otp",
              page: () {
                final args = Get.arguments as Map<String, dynamic>? ?? {};
                return OTPVerificationScreen(
                  phoneNumber: args['phoneNumber'] as String? ?? '',
                );
              },
            ),
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
              primaryContainer: ColorConstants.primary50,
              secondary: ColorConstants.accent,
              secondaryContainer: ColorConstants.accent.withValues(alpha: 0.1),
              surface: ColorConstants.surface,
              surfaceContainerHighest: ColorConstants.surfaceVariant,
              onPrimary: ColorConstants.textOnPrimary,
              onSecondary: ColorConstants.textPrimary,
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
              headlineMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
              headlineSmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
              titleLarge: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
              titleMedium: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textPrimary,
              ),
              titleSmall: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textSecondary,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: ColorConstants.textSecondary,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: ColorConstants.textSecondary,
              ),
              bodySmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: ColorConstants.textTertiary,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: ColorConstants.surface,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primary,
                foregroundColor: ColorConstants.textOnPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: ColorConstants.primaryDark,
            scaffoldBackgroundColor: ColorConstants.primary900,
            colorScheme: ColorScheme.dark(
              primary: ColorConstants.primaryDark,
              primaryContainer: ColorConstants.primary800,
              secondary: ColorConstants.accent,
              secondaryContainer: ColorConstants.accent.withValues(alpha: 0.2),
              surface: ColorConstants.primary800,
              surfaceContainerHighest: ColorConstants.primary700,
              onPrimary: ColorConstants.textOnPrimary,
              onSecondary: ColorConstants.textOnPrimary,
            ),
          ),
          themeMode: currentTheme,
        );
      },
    );
  }
}
