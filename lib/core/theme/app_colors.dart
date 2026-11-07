import 'package:flutter/material.dart';

/// Core colour palette for UpBrainQuest.
///
/// Values follow the design direction in PLAN §8.2: deep navy surfaces with
/// violet and cyan accents. Every colour used in a widget must come from this
/// file (or from the [ColorScheme] built from it) so that the palette stays
/// consistent across feature screens.
abstract final class AppColors {
  const AppColors._();

  /// Base page background (deep navy).
  static const Color background = Color(0xFF0B1020);

  /// Primary surface used for cards and sheets.
  static const Color surface = Color(0xFF151D33);

  /// Elevated surface used for nested elements on top of [surface].
  static const Color elevatedSurface = Color(0xFF202B45);

  /// Primary accent (violet).
  ///
  /// Lightened from `#7C5CFF` so primary text (dialog actions, ghost keypad
  /// buttons) clears WCAG AA on the page and card surfaces; the darker shade
  /// sat at 3.85-4.36:1 there. Dark on-accent text still clears 5.7:1.
  static const Color primary = Color(0xFF8E72FF);

  /// Secondary accent (cyan).
  static const Color secondary = Color(0xFF29C7D8);

  /// Supporting accent (blue).
  static const Color supporting = Color(0xFF4C8DFF);

  /// Positive / correct state.
  static const Color positive = Color(0xFF3DDC97);

  /// Caution state.
  static const Color caution = Color(0xFFFFC857);

  /// Error / incorrect state.
  static const Color error = Color(0xFFFF5C7A);

  /// Primary text colour on dark surfaces.
  static const Color textPrimary = Color(0xFFF4F6FF);

  /// Secondary text colour on dark surfaces.
  static const Color textSecondary = Color(0xFFB4BCD8);

  /// Text colour used on top of saturated accent fills.
  ///
  /// Kept near-black (rather than the page background navy) so it clears the
  /// WCAG AA 4.5:1 ratio on the violet primary fill as well as on the bright
  /// positive/error fills (verified by `theme_contrast_test`).
  static const Color textOnAccent = Color(0xFF05070F);
}
