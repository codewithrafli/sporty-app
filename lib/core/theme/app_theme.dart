import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
      primary: AppColors.purple,
      surface: AppColors.white,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Satoshi',
      textTheme: const TextTheme(
        bodySmall: TextStyle(fontWeight: FontWeight.w500, color: AppColors.dark),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, color: AppColors.dark),
        bodyLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.dark),
        labelSmall: TextStyle(fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.dark),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.dark),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.dark),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.dark),
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: AppColors.dark),
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: AppColors.dark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.dark,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.dark,
          fontFamily: 'Satoshi',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}
