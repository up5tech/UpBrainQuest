import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';

/// WCAG 2.x relative luminance for an sRGB colour.
double _luminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Theme contrast (WCAG AA)', () {
    test('primary text on surfaces is at least 4.5:1', () {
      expect(
        _contrast(AppColors.textPrimary, AppColors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.textPrimary, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.textPrimary, AppColors.elevatedSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('secondary text on surfaces is at least 4.5:1', () {
      expect(
        _contrast(AppColors.textSecondary, AppColors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.textSecondary, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.textSecondary, AppColors.elevatedSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('on-accent text clears 4.5:1 on every accent fill', () {
      for (final Color fill in <Color>[
        AppColors.primary,
        AppColors.secondary,
        AppColors.positive,
        AppColors.error,
        AppColors.caution,
      ]) {
        expect(
          _contrast(AppColors.textOnAccent, fill),
          greaterThanOrEqualTo(4.5),
          reason: 'on-accent text must be readable on $fill',
        );
      }
    });
  });
}
