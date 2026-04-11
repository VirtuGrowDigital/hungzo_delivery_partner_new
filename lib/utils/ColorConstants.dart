import 'package:flutter/material.dart';

class ColorConstants {
  static const white = Color(0xFFFFFFFF);
  static const orangeOne = Color(0xFFD8712A);
  static const greenSecondaryColor = Color(0xFF01916D);


  // Primary Brand Colors
  static const Color primary = Color(0xFF16AB88); // Teal Green
  static const Color primaryLight = Color(0xFFBAD7C9);
  static const Color primaryDark = Color(0xFF127835);

  // Accent & Highlights
  static const Color accent = Color(0xFFFACE3D); // Yellow
  static const Color accentOrange = Color(0xFFF9881F);
  static const Color accentPeach = Color(0xFFFFC49C);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8FBFF);
  static const Color cardBackground = Color(0xFFBFDACD);

  // Text Colors
  static const Color textPrimary = Color(0xFF16AB88);
  static const Color textSecondary = Color(0xFF4782CF);
  static const Color textHint = Color(0xFFD7D7D7);

  // Status Colors
  static const Color success = Color(0xFF16AB88);
  static const Color warning = Color(0xFFF9881F);
  static const Color error = Color(0xFFEB4D57);

  // Additional Status / Alerts
  static const Color danger = Color(0xFFE02D69);
  static const Color alert = Color(0xFFFE554A);

  // Divider & Border
  static const Color divider = Color(0xFFD7D7D7);
  static const Color border = Color(0xFFC3E8D8);

  // Misc / Utility
  static const Color infoBlue = Color(0xFF4782CF);
  static const Color successDark = Color(0xFF127835);
  static const Color orangeRed = Color(0xFFE95555);
  static const Color coral = Color(0xFFFF774C);
  static const Color gold = Color(0xFFC07906);

  static const Color transparent = Colors.transparent;

  static const textOne = Color(0xFF41404D);
//Snack bar Color
  static const Color snackSuccess = Color(0xFF16AB88);
  static const Color snackError = Color(0xFFEB4D57);
  static const Color snackWarning = Color(0xFFF9881F);
  static const Color mintCream = Color(0xFFEAF5EF);
  static const Color teaGreen = Color(0xFFCFE3D7);

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
