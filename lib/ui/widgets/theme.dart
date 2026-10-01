import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF166359);
  static const tealLight = Color(0xFFF2F9F7);
  static const background = Color(0xFFF7F8F8);
  static const hover = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB);
  static const red = Color(0xFFD93025);

  // text and icons, from dark to light
  static const text = Color(0xFF1E232A);
  static const textMedium = Color(0xFF4B5563);
  static const textLight = Color(0xFF6B7280);
  static const hint = Color(0xFF9CA3AF);
}

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.text,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  // no animation: no ripple, no press highlight, only a hover color
  splashFactory: NoSplash.splashFactory,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: AppColors.hover,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(animationDuration: Duration.zero),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(animationDuration: Duration.zero),
  ),
);
