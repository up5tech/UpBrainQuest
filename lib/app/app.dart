import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/theme/app_theme.dart';

/// Root widget of the UpBrainQuest application.
///
/// The app-level reduced-motion preference is folded into [MediaQuery] so every
/// animation (result fade, route transitions) respects it, in addition to the
/// OS accessibility setting (PLAN §8.4, Phase 8 task 3).
class UpBrainQuestApp extends ConsumerWidget {
  /// Creates the application root.
  const UpBrainQuestApp({super.key, required this.router});

  /// The router that owns the navigation graph.
  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool appReducedMotion =
        ref.watch(appSettingsProvider).value?.reducedMotion ?? false;

    return MaterialApp.router(
      title: 'UpBrainQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en')],
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        final bool reduced = media.disableAnimations || appReducedMotion;
        return MediaQuery(
          data: media.copyWith(disableAnimations: reduced),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
