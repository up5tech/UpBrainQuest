import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';

/// Reusable card surface built on the shared tokens.
///
/// Provides consistent padding and radius. When [onTap] is supplied the card
/// becomes a tappable surface with an ink response and a full-row hit area.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? const EdgeInsets.all(AppSpacing.md);

    final BorderRadius radius = BorderRadius.circular(AppRadii.card);
    final Widget content = Padding(padding: resolvedPadding, child: child);
    // A Material paints the card surface, so ink effects from a nested
    // ListTile or ExpansionTile stay visible instead of being hidden behind
    // an opaque Container (and taps get a ripple on the card itself).
    final Widget tappable = onTap == null
        ? content
        : InkWell(onTap: onTap, borderRadius: radius, child: content);

    if (gradient == null) {
      return Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: tappable,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        child: tappable,
      ),
    );
  }
}
