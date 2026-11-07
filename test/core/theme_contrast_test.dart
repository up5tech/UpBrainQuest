import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_gradients.dart';

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
        AppColors.supporting,
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

    test('on-accent text clears 4.5:1 on every gradient stop', () {
      for (final LinearGradient gradient in <LinearGradient>[
        AppGradients.primary,
        AppGradients.accent,
      ]) {
        for (final Color stop in gradient.colors) {
          expect(
            _contrast(AppColors.textOnAccent, stop),
            greaterThanOrEqualTo(4.5),
            reason: 'on-accent text must be readable on gradient stop $stop',
          );
        }
      }
    });

    test('accent text on the page and card surfaces is at least 4.5:1', () {
      // These tokens are used as text (dialog actions, ghost buttons, error
      // copy), not just as fills.
      for (final (String name, Color accent) in <(String, Color)>[
        ('primary', AppColors.primary),
        ('secondary', AppColors.secondary),
        ('supporting', AppColors.supporting),
        ('positive', AppColors.positive),
        ('error', AppColors.error),
      ]) {
        for (final (String surfaceName, Color surface) in <(String, Color)>[
          ('background', AppColors.background),
          ('surface', AppColors.surface),
        ]) {
          expect(
            _contrast(accent, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$name text must be readable on $surfaceName',
          );
        }
      }
    });

    test('the mode badge label is readable on its tinted fill', () {
      final Color tint = Color.alphaBlend(
        AppColors.secondary.withValues(alpha: 0.15),
        AppColors.surface,
      );
      expect(_contrast(AppColors.secondary, tint), greaterThanOrEqualTo(4.5));
    });

    test('progress fill is distinguishable from its track', () {
      expect(
        _contrast(AppColors.primary, AppColors.elevatedSurface),
        greaterThanOrEqualTo(3),
        reason: 'non-text UI components need 3:1 against their background',
      );
    });

    test('light page text is not used on component fills', () {
      // Documents why hero/gradient surfaces must switch to textOnAccent: the
      // light text tokens miss AA on every accent fill, so a widget that uses
      // them on one of these colours is a bug rather than a near miss.
      for (final Color fill in <Color>[
        AppColors.primary,
        AppColors.secondary,
        AppColors.supporting,
        AppColors.positive,
        AppColors.error,
        AppColors.caution,
      ]) {
        expect(_contrast(AppColors.textPrimary, fill), lessThan(4.5));
        expect(_contrast(AppColors.textSecondary, fill), lessThan(4.5));
      }
    });
  });
}
