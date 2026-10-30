import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/progress/drift_progress_repository.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';

void main() {
  late AppDatabase database;
  late DriftProgressRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftProgressRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'loadAchievements returns the whole catalog, locked by default',
    () async {
      final List<AchievementRecord> records = await repository
          .loadAchievements();
      expect(records.length, AchievementCatalog.all.length);
      expect(records.every((AchievementRecord r) => !r.unlocked), isTrue);
      expect(records.every((AchievementRecord r) => r.current == 0), isTrue);
    },
  );

  test(
    'an achievement unlocks exactly once and keeps its first date',
    () async {
      final DateTime first = DateTime.utc(2026, 1, 10, 10);
      final DateTime later = DateTime.utc(2026, 1, 11, 10);

      await repository.saveAchievements(const <AchievementProgress>[
        AchievementProgress(
          id: AchievementId.firstQuest,
          current: 1,
          target: 1,
        ),
      ], nowUtc: first);
      await repository.saveAchievements(const <AchievementProgress>[
        AchievementProgress(
          id: AchievementId.firstQuest,
          current: 5,
          target: 1,
        ),
      ], nowUtc: later);

      final List<AchievementRecord> records = await repository
          .loadAchievements();
      final AchievementRecord firstQuest = records.firstWhere(
        (AchievementRecord r) => r.id == AchievementId.firstQuest,
      );
      expect(firstQuest.unlocked, isTrue);
      expect(firstQuest.unlockedAt?.toUtc(), first);
      expect(firstQuest.current, 5);
    },
  );

  test('daily activity increments and marks the daily challenge', () async {
    const String date = '2026-01-10';
    await repository.recordDailyCompletion(
      localDate: date,
      dailyChallenge: false,
      nowUtc: DateTime.utc(2026, 1, 10),
    );
    await repository.recordDailyCompletion(
      localDate: date,
      dailyChallenge: true,
      nowUtc: DateTime.utc(2026, 1, 10),
    );

    final DailyStatus status = await repository.dailyStatus(date);
    expect(status.completedSessionsCount, 2);
    expect(status.completedDailyChallenge, isTrue);
  });

  test('dailyStatus returns none for an untouched date', () async {
    final DailyStatus status = await repository.dailyStatus('2026-02-01');
    expect(status.completedSessionsCount, 0);
    expect(status.completedDailyChallenge, isFalse);
  });

  test('streak counts consecutive days and resets after a gap', () async {
    for (final String date in <String>[
      '2026-01-08',
      '2026-01-09',
      '2026-01-10',
    ]) {
      await repository.recordDailyCompletion(
        localDate: date,
        dailyChallenge: false,
        nowUtc: DateTime.utc(2026, 1, 10),
      );
    }

    final StreakSummary streak = await repository.streak('2026-01-10');
    expect(streak.current, 3);
    expect(streak.longest, 3);

    final StreakSummary afterGap = await repository.streak('2026-01-12');
    expect(afterGap.current, 0);
    expect(afterGap.longest, 3);
  });

  test('clearAll removes achievements and daily activity', () async {
    await repository.saveAchievements(const <AchievementProgress>[
      AchievementProgress(id: AchievementId.firstQuest, current: 1, target: 1),
    ], nowUtc: DateTime.utc(2026));
    await repository.recordDailyCompletion(
      localDate: '2026-01-10',
      dailyChallenge: true,
      nowUtc: DateTime.utc(2026),
    );

    await repository.clearAll();

    final List<AchievementRecord> records = await repository.loadAchievements();
    expect(records.every((AchievementRecord r) => !r.unlocked), isTrue);
    final DailyStatus status = await repository.dailyStatus('2026-01-10');
    expect(status.completedSessionsCount, 0);
    expect(status.completedDailyChallenge, isFalse);
  });

  test(
    'achievementStats counts completed, reasoning and reflection sessions',
    () async {
      await database
          .into(database.gameSessions)
          .insert(
            GameSessionsCompanion.insert(
              mode: 'iq',
              startedAt: DateTime.utc(2026, 1, 10),
              questionCount: 3,
              answeredCount: 3,
              scoreAlgorithmVersion: 1,
              iqScore: const Value<int>(80),
            ),
          );
      await database
          .into(database.gameSessions)
          .insert(
            GameSessionsCompanion.insert(
              mode: 'eq',
              startedAt: DateTime.utc(2026, 1, 10),
              questionCount: 2,
              answeredCount: 2,
              scoreAlgorithmVersion: 1,
              eqScore: const Value<int>(70),
            ),
          );

      final AchievementStats stats = await repository.achievementStats(
        todayLocalDate: '2026-01-10',
      );
      expect(stats.completedSessions, 2);
      expect(stats.reasoningSessions, 1);
      expect(stats.reflectionSessions, 1);
    },
  );
}
