import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_theme.dart';

/// Visual variant for [AppButton].
enum AppButtonVariant { primary, outline, ghost }

/// Reusable button built on the shared design tokens.
///
/// Uses the token radius and minimum touch target so every button matches the
/// design system (PLAN §8.2). Child text supplies the semantic label.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool fullWidth;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon!,
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          );

    final OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
    );

    const Size minSize = Size(AppTheme.minTouchTarget, AppTheme.minTouchTarget);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(shape: shape, minimumSize: minSize),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(shape: shape, minimumSize: minSize),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(shape: shape, minimumSize: minSize),
        child: child,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
