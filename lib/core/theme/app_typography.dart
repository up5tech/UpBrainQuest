import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';

/// Text styles used across the app.
///
/// PLAN §8.1 requires a clear typography hierarchy. Widgets should reference
/// these styles (via [TextTheme]) rather than constructing [TextStyle] objects
/// inline.
abstract final class AppTypography {
  const AppTypography._();

  /// Large hero headline.
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Screen title.
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section heading.
  static const TextStyle title = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body copy for questions and explanations.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Supporting or secondary copy.
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Small caption, used for hints and metadata.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Numeric score display.
  static const TextStyle score = TextStyle(
    fontSize: 44,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );
}
