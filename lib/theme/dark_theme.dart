import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

ThemeData get darkTheme {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.darkBackground,
      onSurface: Colors.white,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,
    textTheme: AppTextTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    useMaterial3: true,
  );
}
