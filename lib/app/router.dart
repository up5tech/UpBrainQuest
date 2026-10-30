import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/app/app_navigation_shell.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';
import 'package:up_brain_quest/features/explore/presentation/explore_page.dart';
import 'package:up_brain_quest/features/gameplay/presentation/gameplay_page.dart';
import 'package:up_brain_quest/features/gameplay/presentation/session_result_page.dart';
import 'package:up_brain_quest/features/gameplay/presentation/session_setup_page.dart';
import 'package:up_brain_quest/features/home/presentation/home_page.dart';
import 'package:up_brain_quest/features/progress/presentation/progress_page.dart';
import 'package:up_brain_quest/features/settings/presentation/settings_page.dart';

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

/// Builds the application router.
///
/// The four primary destinations live inside a persistent bottom-navigation
/// shell (PLAN §2.1, Phase 1). Session routes are added in Phase 3 and live
/// outside this shell.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AppNavigationShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.explore,
                builder: (BuildContext context, GoRouterState state) =>
                    const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.progress,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProgressPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/session/setup/:mode',
        builder: (BuildContext context, GoRouterState state) =>
            SessionSetupPage(modeKey: state.pathParameters['mode'] ?? ''),
      ),
      GoRoute(
        path: '/session/play',
        builder: (BuildContext context, GoRouterState state) =>
            const GameplayPage(),
      ),
      GoRoute(
        path: '/session/result',
        builder: (BuildContext context, GoRouterState state) {
          final SessionResult? result = state.extra as SessionResult?;
          return SessionResultPage(result: result);
        },
      ),
    ],
  );
}
