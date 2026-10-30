import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:up_brain_quest/app/app.dart';
import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/app/router.dart';
import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/data/preferences/settings_repository.dart';

/// Deterministic settings backend for widget tests (no platform channels).
class _DefaultSettingsRepository extends SettingsRepository {
  @override
  Future<AppSettings> load() async => const AppSettings(
    reducedMotion: false,
    soundEnabled: false,
    hapticsEnabled: false,
  );
}

/// Builds the real app against an in-memory database and fake preferences so
/// widget tests never touch the platform path provider or a real file.
///
/// A [settingsRepository] can be injected to control reduced-motion state.
Widget buildTestApp({SettingsRepository? settingsRepository}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((Ref ref) async {
        final AppDatabase database = AppDatabase(NativeDatabase.memory());
        ref.onDispose(database.close);
        return database;
      }),
      settingsRepositoryProvider.overrideWithValue(
        settingsRepository ?? _DefaultSettingsRepository(),
      ),
    ],
    child: UpBrainQuestApp(router: createRouter()),
  );
}
