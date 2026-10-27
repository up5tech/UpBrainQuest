import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';

import 'package:up_brain_quest/core/logging/app_logger.dart';
import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/database/database_paths.dart';

/// Opens the local on-device database.
///
/// The connection runs on a background isolate so that database I/O never
/// blocks the UI thread (PLAN §6.1 keeps persistence off the widget layer).
///
/// SQLite itself is bundled into the app by the `sqlite3` package's build
/// hooks. There is no network access and no external database server.
Future<AppDatabase> openAppDatabase() async {
  final file = await DatabasePaths.databaseFile('up_brain_quest.sqlite');

  if (kDebugMode) {
    AppLogger.info('Opening local database at ${file.path}');
  }

  return AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (database) {
        // Write-ahead logging keeps reads from blocking writes. Drift's
        // read pool is only effective with WAL enabled.
        database.execute('PRAGMA journal_mode = WAL;');
      },
    ),
  );
}
