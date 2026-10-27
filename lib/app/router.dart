import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/features/home/presentation/baseline_placeholder_page.dart';

/// Route paths for the application.
///
/// Route identifiers are validated before use; they are never treated as
/// trusted arbitrary input (PLAN §9.2).
abstract final class AppRoutes {
  const AppRoutes._();

  /// Home — the app entry point.
  static const String home = '/';

  /// Explore — mode and difficulty selection.
  static const String explore = '/explore';

  /// Progress — history, skill breakdowns and achievements.
  static const String progress = '/progress';

  /// Settings — preferences and local data controls.
  static const String settings = '/settings';
}

/// Builds the application's router.
///
/// The active game session is intentionally *not* part of the persistent
/// navigation shell (PLAN §2.1). Session routes are added in Phase 3.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const BaselinePlaceholderPage(),
      ),
    ],
  );
}
