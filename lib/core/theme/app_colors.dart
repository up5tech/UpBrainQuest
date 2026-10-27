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
  static const Color primary = Color(0xFF7C5CFF);

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
  static const Color textOnAccent = Color(0xFF0B1020);
}
