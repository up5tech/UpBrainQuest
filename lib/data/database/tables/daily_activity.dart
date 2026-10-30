import 'package:drift/drift.dart';

/// Per-local-day activity, used for the local streak (PLAN §7.2, §7.3).
///
/// The key is the device's **local** ISO date (`yyyy-MM-dd`). Moving the device
/// clock can therefore affect local streaks; this is a convenience feature, not
/// a tamper-proof record (PLAN §2.2E).
class DailyActivity extends Table {
  /// Local ISO date (`yyyy-MM-dd`).
  TextColumn get localDate => text()();

  /// Whether the Daily Challenge was completed on this date.
  BoolColumn get completedDailyChallenge =>
      boolean().withDefault(const Constant(false))();

  /// How many sessions were completed on this date.
  IntColumn get completedSessionsCount =>
      integer().withDefault(const Constant(0))();

  /// When this row was first created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{localDate};
}
