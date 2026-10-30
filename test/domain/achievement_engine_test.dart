import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/achievements/achievement.dart';

void main() {
  group('AchievementEngine', () {
    const AchievementEngine engine = AchievementEngine();

    AchievementProgress byId(
      List<AchievementProgress> progress,
      AchievementId id,
    ) => progress.firstWhere((AchievementProgress p) => p.id == id);

    test('empty stats leave everything locked', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats.empty(),
      );
      expect(progress.length, AchievementCatalog.all.length);
      expect(progress.every((AchievementProgress p) => !p.met), isTrue);
      expect(progress.every((AchievementProgress p) => p.current == 0), isTrue);
    });

    test('First Quest unlocks at one completed session', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats(
          completedSessions: 1,
          reasoningSessions: 0,
          reflectionSessions: 0,
          longestStreak: 0,
        ),
      );
      expect(byId(progress, AchievementId.firstQuest).met, isTrue);
      expect(byId(progress, AchievementId.firstQuest).current, 1);
      expect(byId(progress, AchievementId.fiveQuests).met, isFalse);
    });

    test('Five Completed Quests unlocks at five', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats(
          completedSessions: 5,
          reasoningSessions: 0,
          reflectionSessions: 0,
          longestStreak: 0,
        ),
      );
      expect(byId(progress, AchievementId.fiveQuests).met, isTrue);
    });

    test('reasoning and reflection use their own counts', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats(
          completedSessions: 10,
          reasoningSessions: 3,
          reflectionSessions: 2,
          longestStreak: 0,
        ),
      );
      expect(byId(progress, AchievementId.reasoningExplorer).met, isTrue);
      expect(byId(progress, AchievementId.reflectionExplorer).met, isFalse);
    });

    test('Consistent Player uses the longest streak', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats(
          completedSessions: 0,
          reasoningSessions: 0,
          reflectionSessions: 0,
          longestStreak: 3,
        ),
      );
      expect(byId(progress, AchievementId.consistentPlayer).met, isTrue);
    });

    test('progress is clamped to each target', () {
      final List<AchievementProgress> progress = engine.evaluate(
        const AchievementStats(
          completedSessions: 100,
          reasoningSessions: 100,
          reflectionSessions: 100,
          longestStreak: 100,
        ),
      );
      expect(
        progress.every((AchievementProgress p) => p.current == p.target),
        isTrue,
      );
      expect(
        progress.every((AchievementProgress p) => p.fraction == 1),
        isTrue,
      );
    });
  });
}
