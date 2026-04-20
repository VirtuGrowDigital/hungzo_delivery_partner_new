import 'package:flutter/material.dart';

class ColorConstants {
  static const white = Color(0xFFFFFFFF);
  static const orangeOne = Color(0xFFD8712A);
  static const greenSecondaryColor = Color(0xFF01916D);

  // Enhanced Primary Brand Colors
  static const Color primary = Color(0xFF16AB88); // Teal Green
  static const Color primary50 = Color(0xFFE8F7F2);
  static const Color primary100 = Color(0xFFC6EBE1);
  static const Color primary200 = Color(0xFFA3DFD0);
  static const Color primary300 = Color(0xFF80D3BF);
  static const Color primary400 = Color(0xFF5DC7AE);
  static const Color primary500 = Color(0xFF3ABB9D);
  static const Color primary600 = Color(0xFF2D9F83);
  static const Color primary700 = Color(0xFF208369);
  static const Color primary800 = Color(0xFF13674F);
  static const Color primary900 = Color(0xFF064B35);

  // Accent & Highlights
  static const Color accent = Color(0xFFFACE3D); // Yellow
  static const Color accentOrange = Color(0xFFF9881F);
  static const Color accentPeach = Color(0xFFFFC49C);

  // Enhanced Background Colors
  static const Color scaffoldBackground = Color(0xFFF8FBFF);
  static const Color cardBackground = Color(0xFFBFDACD);
  static const Color surface = Color(0xFFFAFDFB);
  static const Color surfaceVariant = Color(0xFFF0F7F4);

  // Enhanced Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textHint = Color(0xFFCCCCCC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Enhanced Status Colors
  static const Color success = Color(0xFF16AB88);
  static const Color successLight = Color(0xFFE8F7F2);
  static const Color warning = Color(0xFFF9881F);
  static const Color warningLight = Color(0xFFFFF4EC);
  static const Color error = Color(0xFFEB4D57);
  static const Color errorLight = Color(0xFFFDEEEF);

  // Additional Status / Alerts
  static const Color danger = Color(0xFFE02D69);
  static const Color alert = Color(0xFFFE554A);

  // Enhanced Divider & Border
  static const Color divider = Color(0xFFE8E8E8);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Misc / Utility
  static const Color infoBlue = Color(0xFF4782CF);
  static const Color successDark = Color(0xFF127835);
  static const Color orangeRed = Color(0xFFE95555);
  static const Color coral = Color(0xFFFF774C);
  static const Color gold = Color(0xFFC07906);

  static const Color transparent = Colors.transparent;

  static const textOne = Color(0xFF41404D);
  
  // Enhanced Snack Bar Colors
  static const Color snackSuccess = Color(0xFF16AB88);
  static const Color snackError = Color(0xFFEB4D57);
  static const Color snackWarning = Color(0xFFF9881F);
  static const Color mintCream = Color(0xFFEAF5EF);
  static const Color teaGreen = Color(0xFFCFE3D7);

  // Enhanced Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16AB88), Color(0xFF2D9F83)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFACE3D), Color(0xFFF9B52E)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFDFB), Color(0xFFF0F7F4)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
  );

  // Screen Background Gradient
  static const List<Color> screenBackgroundGradient = [
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFBAD7C9),
    Color(0xFFFFFFFF),
  ];

  static const LinearGradient screenBackgroundGradient2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFCFE3D7),
      Color(0xFFEAF5EF),
    ],
  );
}
