import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/database/app_database_opener.dart';

/// Provider exposing the local [AppDatabase].
///
/// The database is opened lazily on first use and shared for the lifetime of
/// the container. Widgets must not access it directly; repositories in the
/// data layer own that responsibility (PLAN §6.3).
///
/// Transactions are started through `AppDatabase.transaction(...)` rather
/// than by exposing the raw connection, so that the transaction boundary
/// stays inside the data layer (PLAN §7.3).
final FutureProvider<AppDatabase> appDatabaseProvider =
    FutureProvider<AppDatabase>((Ref ref) async {
      final AppDatabase database = await openAppDatabase();
      ref.onDispose(database.close);
      return database;
    });
