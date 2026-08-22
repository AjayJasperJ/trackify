import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Single source of truth for form-screen look & feel.
/// Every add/edit screen (task, goal, milestone) uses these tokens so all
/// form content — cards, text fields, dropdowns, date fields — is identical:
/// rounded-12 cards, filled rounded-12 inputs, primary border on focus.
class AppFormStyles {
  AppFormStyles._();

  static const double cardRadius = 16;
  static const double inputRadius = 16;

  /// Text color used inside form inputs.
  static const Color textColor = AppColors.onSurface;

  /// Primary accent (buttons, focus borders, icons).
  static const Color primary = AppColors.primary;

  /// Secondary text / icons.
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;

  /// Hairline borders.
  static const Color outline = AppColors.outline;
  static const Color outlineVariant = AppColors.outlineVariant;

  /// Standard card: white, rounded-16, hairline border, soft shadow.
  static BoxDecoration card({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: borderColor ?? AppColors.outlineVariant.withValues(alpha: 0.15),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Standard input decoration: filled, rounded-16, subtle border,
  /// primary border on focus. Shared by TextFormField,
  /// DropdownButtonFormField and InputDecorator.
  static InputDecoration input({
    String? label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
      ),
      hintStyle: const TextStyle(color: AppColors.outlineVariant),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
