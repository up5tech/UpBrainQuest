import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_colors.dart';

/// Elevation shadows for cards and floating elements.
///
/// PLAN §8.2 lists shadows among the design tokens that must be defined once
/// and reused. Widgets reference these rather than inlining [BoxShadow] lists.
abstract final class AppShadows {
  const AppShadows._();

  /// Subtle shadow for cards resting on the page background.
  static List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: AppColors.background.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Stronger shadow for elevated or hero surfaces.
  static List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(
      color: AppColors.background.withValues(alpha: 0.5),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
