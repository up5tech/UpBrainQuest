import 'package:drift/drift.dart';

/// Locally persisted achievement progress and unlock records (PLAN §7.2).
///
/// `unlockedAt` is written at most once per achievement so an unlock is never
/// re-dated or announced twice (PLAN Phase 7 acceptance).
class Achievements extends Table {
  /// Stable achievement key (see `AchievementId.key`).
  TextColumn get id => text()();

  /// When the achievement first unlocked, or `null` while locked.
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  /// Current local progress value.
  IntColumn get progressValue => integer().withDefault(const Constant(0))();

  /// Target value for progressive achievements.
  IntColumn get targetValue => integer().withDefault(const Constant(0))();

  /// Version of the achievement rules that produced this row.
  IntColumn get definitionVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
