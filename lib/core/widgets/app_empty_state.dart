import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';

/// Honest empty state shown when no data exists yet (PLAN §14.12).
///
/// Never shows placeholder content that could be mistaken for real progress.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
      const SizedBox(height: AppSpacing.md),
      Text(
        message,
        style: AppTypography.bodySecondary,
        textAlign: TextAlign.center,
      ),
    ];

    if (actionLabel != null && onAction != null) {
      children
        ..add(const SizedBox(height: AppSpacing.lg))
        ..add(AppButton(label: actionLabel!, onPressed: onAction));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
