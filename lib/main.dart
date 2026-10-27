import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:up_brain_quest/app/app.dart';
import 'package:up_brain_quest/app/router.dart';
import 'package:up_brain_quest/core/logging/app_logger.dart';

/// Application entry point.
///
/// The app is fully offline: there is no backend, no remote configuration and
/// no analytics upload (PLAN §1.2, §10). Start-up therefore never depends on
/// a network connection (PLAN §7.4).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppLogger.info('Starting UpBrainQuest');

  runApp(ProviderScope(child: UpBrainQuestApp(router: createRouter())));
}
