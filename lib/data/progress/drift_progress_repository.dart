import 'package:drift/drift.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/progress/progress_repository.dart';

/// Drift-backed [ProgressRepository] (PLAN Phase 7 task 3).
///
/// Achievements unlock at most once: an existing `unlockedAt` is never
/// re-dated, even if the achievement is evaluated again on a later session.
class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<AchievementStats> achievementStats({
    required String todayLocalDate,
  }) async {
    final List<GameSession> sessions = await _db.select(_db.gameSessions).get();
    int completed = 0;
    int reasoning = 0;
    int reflection = 0;
    for (final GameSession row in sessions) {
      if (row.status != 'completed') continue;
      completed++;
      if (row.iqScore != null) reasoning++;
      if (row.eqScore != null) reflection++;
    }
    final StreakSummary streak = await this.streak(todayLocalDate);
    return AchievementStats(
      completedSessions: completed,
      reasoningSessions: reasoning,
      reflectionSessions: reflection,
      longestStreak: streak.longest,
    );
  }

  @override
  Future<List<AchievementRecord>> loadAchievements() async {
    final List<Achievement> rows = await _db.select(_db.achievements).get();
    final Map<String, Achievement> byKey = <String, Achievement>{
      for (final Achievement row in rows) row.id: row,
    };
    return <AchievementRecord>[
      for (final AchievementDefinition definition in AchievementCatalog.all)
        _toRecord(definition, byKey[definition.id.key]),
    ];
  }

  @override
  Future<void> saveAchievements(
    List<AchievementProgress> progress, {
    required DateTime nowUtc,
  }) async {
    await _db.transaction(() async {
      for (final AchievementProgress item in progress) {
        final Achievement? existing = await (_db.select(
          _db.achievements,
        )..where((t) => t.id.equals(item.id.key))).getSingleOrNull();
        if (existing == null) {
          await _db
              .into(_db.achievements)
              .insert(
                AchievementsCompanion.insert(
                  id: item.id.key,
                  unlockedAt: Value<DateTime?>(item.met ? nowUtc : null),
                  progressValue: Value<int>(item.current),
                  targetValue: Value<int>(item.target),
                  definitionVersion: const Value<int>(
                    AchievementCatalog.definitionVersion,
                  ),
                ),
              );
        } else {
          await (_db.update(
            _db.achievements,
          )..where((t) => t.id.equals(item.id.key))).write(
            AchievementsCompanion(
              progressValue: Value<int>(item.current),
              targetValue: Value<int>(item.target),
              // Never re-date an existing unlock.
              unlockedAt: existing.unlockedAt == null && item.met
                  ? Value<DateTime>(nowUtc)
                  : const Value<DateTime>.absent(),
            ),
          );
        }
      }
    });
  }

  @override
  Future<DailyStatus> dailyStatus(String localDate) async {
    final DailyActivityData? row = await (_db.select(
      _db.dailyActivity,
    )..where((t) => t.localDate.equals(localDate))).getSingleOrNull();
    if (row == null) return DailyStatus.none(localDate);
    return DailyStatus(
      localDate: row.localDate,
      completedDailyChallenge: row.completedDailyChallenge,
      completedSessionsCount: row.completedSessionsCount,
    );
  }

  @override
  Future<void> recordDailyCompletion({
    required String localDate,
    required bool dailyChallenge,
    required DateTime nowUtc,
  }) async {
    final DailyActivityData? existing = await (_db.select(
      _db.dailyActivity,
    )..where((t) => t.localDate.equals(localDate))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.dailyActivity)
          .insert(
            DailyActivityCompanion.insert(
              localDate: localDate,
              completedDailyChallenge: Value<bool>(dailyChallenge),
              completedSessionsCount: const Value<int>(1),
              createdAt: nowUtc,
            ),
          );
    } else {
      await (_db.update(
        _db.dailyActivity,
      )..where((t) => t.localDate.equals(localDate))).write(
        DailyActivityCompanion(
          completedDailyChallenge: dailyChallenge
              ? const Value<bool>(true)
              : const Value<bool>.absent(),
          completedSessionsCount: Value<int>(
            existing.completedSessionsCount + 1,
          ),
        ),
      );
    }
  }

  @override
  Future<StreakSummary> streak(String todayLocalDate) async {
    final List<DailyActivityData> rows = await _db
        .select(_db.dailyActivity)
        .get();
    final List<DateTime> dates = <DateTime>[
      for (final DailyActivityData row in rows) _parseLocalDate(row.localDate),
    ];
    return const StreakCalculator().compute(
      dates,
      today: _parseLocalDate(todayLocalDate),
    );
  }

  @override
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.achievements).go();
      await _db.delete(_db.dailyActivity).go();
    });
  }

  AchievementRecord _toRecord(
    AchievementDefinition definition,
    Achievement? row,
  ) => AchievementRecord(
    id: definition.id,
    current: row?.progressValue ?? 0,
    target: row?.targetValue ?? definition.target,
    unlockedAt: row?.unlockedAt,
  );

  DateTime _parseLocalDate(String value) {
    final List<String> parts = value.split('-');
    if (parts.length != 3) return DateTime(1970);
    return DateTime(
      int.tryParse(parts[0]) ?? 1970,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
  }
}
