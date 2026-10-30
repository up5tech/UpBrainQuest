import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';

/// A styled linear progress indicator.
///
/// [value] is clamped to 0..1. Exposes a single semantic node ("label, N%") so
/// screen readers announce the progress rather than an unlabeled bar.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.label});

  final double value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);
    return Semantics(
      container: true,
      label: label,
      value: '${(clamped * 100).round()}%',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (label != null) ...<Widget>[
              Text(label!, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xxs),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: AppSpacing.xs,
                color: AppColors.primary,
                backgroundColor: AppColors.elevatedSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
