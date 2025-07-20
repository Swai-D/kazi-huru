import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryColor = Color.fromARGB(255, 4, 145, 15); // Green
  static const Color secondaryColor = Color.fromRGBO(239, 243, 242, 1);
  static const Color errorColor = Color(0xFFB00020);
  static const Color scaffoldBackgroundColor = Color(0xFFF5F7FA); // Light grey/off-white
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Color(0xFF222B45);
  static const Color textColorLight = Color(0xFF666666);
  
  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
    color: textColor,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textColor,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    color: textColor,
  );
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  // Border Radius
  static const double borderRadiusSmall = 0.0;
  static const double borderRadiusMedium = 4.0;
  static const double borderRadiusLarge = 8.0;
  
  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
} 