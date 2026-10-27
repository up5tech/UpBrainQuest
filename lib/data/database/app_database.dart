import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Lightweight metadata table used for database and content-pack bookkeeping.
///
/// PLAN §7.2 allows a small `app_metadata` table for migration metadata. It
/// is created here in the Phase 0 baseline so the Drift code-generation and
/// native SQLite toolchain is exercised end to end from the very first
/// commit. The full session/attempt schema arrives in Phase 6 as a schema
/// migration, never by deleting user data (PLAN §7.3).
@DataClassName('AppMetadataEntry')
class AppMetadataEntries extends Table {
  /// Primary key of the metadata row.
  TextColumn get key => text()();

  /// Free-form value stored for [key].
  TextColumn get value => text().withDefault(const Constant(''))();

  /// When the row was last written (UTC).
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// Local application database.
///
/// The database is the source of truth for completed sessions, attempts and
/// progress (PLAN §7.1). It is opened locally on-device and never talks to a
/// server.
@DriftDatabase(tables: <Type>[AppMetadataEntries])
class AppDatabase extends _$AppDatabase {
  /// Opens the database stored at [executor].
  AppDatabase(super.executor);

  /// Current schema version. Bump this whenever [migration] is extended so
  /// that existing databases are migrated instead of reset (PLAN §7.3).
  @override
  int get schemaVersion => 1;

  /// Migrations applied in sequence. Never delete an existing step: old
  /// installs must be able to upgrade without losing progress.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    beforeOpen: (details) async {
      // Foreign keys are disabled by default in SQLite; drift enables them
      // per-connection, but we also make sure the pragma is applied for
      // integrity checks that rely on it.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Reads the metadata value stored for [key], or `null` when absent.
  Future<String?> readMetadata(String key) async {
    final AppMetadataEntry? entry = await (select(
      appMetadataEntries,
    )..where((AppMetadataEntries t) => t.key.equals(key))).getSingleOrNull();

    return entry?.value;
  }

  /// Writes [value] for [key], replacing any previous value.
  Future<void> writeMetadata(String key, String value) async {
    await into(appMetadataEntries).insertOnConflictUpdate(
      AppMetadataEntriesCompanion.insert(
        key: key,
        value: Value<String>(value),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
