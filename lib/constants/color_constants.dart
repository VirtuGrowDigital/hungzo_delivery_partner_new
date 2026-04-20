import 'package:flutter/material.dart';

class ColorConstants {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);

  static const Color primary900 = Color(0xFF1B5E20);
  static const Color primary800 = Color(0xFF2E7D32);
  static const Color primary700 = Color(0xFF388E3C);
  static const Color primary50 = Color(0xFFE8F5E9);

  // Accent
  static const Color accent = Color(0xFFFFC107);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEEEEE);

  // Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Status colors
  static const Color success = Colors.green;
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Colors.orange;
  static const Color warningLight = Color(0xFFFFF3E0);

  static const Color error = Colors.red;
  static const Color errorLight = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );
}