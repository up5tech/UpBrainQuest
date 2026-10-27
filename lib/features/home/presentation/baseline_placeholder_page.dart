import 'package:flutter/widgets.dart';

import 'package:up_brain_quest/core/theme/app_theme.dart';

/// Placeholder page shown during the Phase 0 baseline.
///
/// PLAN §14.12 forbids fake scores and fake history. This screen therefore
/// states plainly that the app shell is not implemented yet rather than
/// showing placeholder content that could be mistaken for real progress.
class BaselinePlaceholderPage extends StatelessWidget {
  /// Creates the placeholder page.
  const BaselinePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.dark().scaffoldBackgroundColor,
      child: Center(
        child: Text(
          'UpBrainQuest',
          style: AppTheme.dark().textTheme.headlineMedium,
        ),
      ),
    );
  }
}
