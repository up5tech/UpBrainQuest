import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';

/// Builds the app [ThemeData] from the shared tokens.
///
/// A dark theme is the primary art direction (PLAN §8.2). A light theme is
/// deliberately not implemented yet — PLAN §8.2 forbids shipping an incomplete
/// theme toggle.
abstract final class AppTheme {
  const AppTheme._();

  /// Minimum interactive target size in logical pixels.
  static const double minTouchTarget = 48;

  /// Builds the dark application theme.
  static ThemeData dark() {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.supporting,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.textOnAccent,
      onSecondary: AppColors.textOnAccent,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    );

    const TextTheme textTheme = TextTheme(
      displaySmall: AppTypography.display,
      headlineMedium: AppTypography.headline,
      titleLarge: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySecondary,
      labelSmall: AppTypography.caption,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: AppTypography.title,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.elevatedSurface),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: AppTypography.title,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerTheme: const DividerThemeData(color: AppColors.elevatedSurface),
    );
  }
}
