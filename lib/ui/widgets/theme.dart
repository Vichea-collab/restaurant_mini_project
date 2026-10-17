import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF166359);
  static const background = Color(0xFFF7F8F8);
  static const red = Color(0xFFD93025);

  static const text = Color(0xFF1E232A);
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
);
