import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_theme.dart';

/// An [IconButton] that requires an explicit semantic label.
///
/// PLAN Phase 1 acceptance requires every interactive control to expose a
/// meaningful semantic label so screen readers announce intent. This wrapper
/// forbids omitting [semanticsLabel] at the call site.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: IconButton(
        icon: icon,
        tooltip: tooltip ?? semanticLabel,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppTheme.minTouchTarget,
            AppTheme.minTouchTarget,
          ),
        ),
      ),
    );
  }
}
