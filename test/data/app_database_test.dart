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

  test('schema version is 1 and the metadata table exists', () async {
    expect(database.schemaVersion, 1);

    final List<String> tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map<String>((QueryRow row) => row.read<String>('name'))
        .get();

    expect(tables, contains('app_metadata_entries'));
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
}
