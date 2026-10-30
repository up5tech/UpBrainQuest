import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:up_brain_quest/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('schema version is 3 and all tables exist', () async {
    expect(database.schemaVersion, 3);

    final List<String> tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map<String>((QueryRow row) => row.read<String>('name'))
        .get();

    expect(
      tables,
      containsAll(<String>[
        'app_metadata_entries',
        'game_sessions',
        'question_attempts',
        'achievements',
        'daily_activity',
      ]),
    );
  });

  test('readMetadata returns null for an unknown key', () async {
    expect(await database.readMetadata('missing'), isNull);
  });

  test('writeMetadata stores a value that can be read back', () async {
    await database.writeMetadata('content_pack_version', '1.0.0');

    expect(await database.readMetadata('content_pack_version'), '1.0.0');
  });

  test('writeMetadata replaces an existing value', () async {
    await database.writeMetadata('content_pack_version', '1.0.0');
    await database.writeMetadata('content_pack_version', '1.1.0');

    expect(await database.readMetadata('content_pack_version'), '1.1.0');
  });

  test('metadata rows are upserted rather than duplicated', () async {
    await database.writeMetadata('key', 'a');
    await database.writeMetadata('key', 'b');

    final int count = await database
        .customSelect('SELECT COUNT(*) AS c FROM app_metadata_entries')
        .map<int>((QueryRow row) => row.read<int>('c'))
        .getSingle();

    expect(count, 1);
  });

  test('migrates a v1 database to v3 without losing metadata', () async {
    final AppDatabase migrated = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          // Recreate the v1 schema and stamp it as version 1 so opening the
          // database runs onUpgrade(1 -> 2).
          database
            ..execute('''
              CREATE TABLE app_metadata_entries (
                key TEXT NOT NULL,
                value TEXT NOT NULL DEFAULT '',
                updated_at INTEGER NOT NULL,
                PRIMARY KEY (key)
              );
            ''')
            ..execute(
              'INSERT INTO app_metadata_entries (key, value, updated_at) '
              "VALUES ('content_pack_version', '1.0.0', 0);",
            )
            ..execute('PRAGMA user_version = 1;');
        },
      ),
    );
    addTearDown(migrated.close);

    // Opening the database runs the migration.
    expect(await migrated.readMetadata('content_pack_version'), '1.0.0');

    final List<String> tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map<String>((QueryRow row) => row.read<String>('name'))
        .get();

    expect(
      tables,
      containsAll(<String>[
        'game_sessions',
        'question_attempts',
        'achievements',
        'daily_activity',
      ]),
    );
  });
}
