import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';

/// Gradients used for hero cards and accent surfaces.
///
/// Gradients are intentionally limited to short, high-contrast surfaces. PLAN
/// §8.1 explicitly forbids gradients behind long paragraphs or low-contrast
/// text.
abstract final class AppGradients {
  const AppGradients._();

  /// Primary violet gradient, used for the main call to action.
  static const LinearGradient primary = LinearGradient(
    colors: <Color>[AppColors.primary, AppColors.supporting],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan gradient, used for secondary highlights.
  static const LinearGradient accent = LinearGradient(
    colors: <Color>[AppColors.secondary, AppColors.supporting],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle surface gradient used to lift a card off the page background.
  static const LinearGradient surface = LinearGradient(
    colors: <Color>[AppColors.surface, AppColors.elevatedSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
