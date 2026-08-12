import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

ThemeData get lightTheme {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.lightBackground,
      onSurface: Colors.black87,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightDivider,
    textTheme: AppTextTheme.textTheme,
    useMaterial3: true,
  );
}
