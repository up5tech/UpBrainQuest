import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';

/// Recoverable error state with an optional retry (PLAN §6.5).
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Icon(
        Icons.error_outline,
        size: 48,
        color: Theme.of(context).colorScheme.error,
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        message,
        style: AppTypography.bodySecondary,
        textAlign: TextAlign.center,
      ),
    ];

    if (onRetry != null) {
      children
        ..add(const SizedBox(height: AppSpacing.lg))
        ..add(AppButton(label: context.l10n.retry, onPressed: onRetry));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
