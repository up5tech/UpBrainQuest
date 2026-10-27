import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/theme/app_theme.dart';

/// Root widget of the UpBrainQuest application.
class UpBrainQuestApp extends StatelessWidget {
  /// Creates the application root.
  const UpBrainQuestApp({super.key, required this.router});

  /// The router that owns the navigation graph.
  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UpBrainQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
