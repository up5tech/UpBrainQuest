import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/database/app_database_opener.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the local database opens and persists on the device', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = await openAppDatabase();
    addTearDown(database.close);

    // The table must exist after the automatic migration on first open.
    final List<String> tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map<String>((QueryRow row) => row.read<String>('name'))
        .get();

    expect(tables, contains('app_metadata_entries'));

    // A write/read round-trip proves the bundled SQLite native library is
    // functional on the target platform, not just present in the bundle.
    await database.writeMetadata('content_pack_version', '1.0.0');

    expect(await database.readMetadata('content_pack_version'), '1.0.0');
  });
}
