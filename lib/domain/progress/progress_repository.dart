import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';

/// Persistence boundary for local achievements and daily activity
/// (PLAN Phase 7 task 3).
///
/// The domain defines the contract; the data layer owns Drift details so the UI
/// never touches the database (PLAN §6.3).
abstract interface class ProgressRepository {
  /// Aggregate achievement inputs derived from persisted sessions and activity.
  Future<AchievementStats> achievementStats({required String todayLocalDate});

  /// All catalog achievements, including ones not yet persisted (progress 0).
  Future<List<AchievementRecord>> loadAchievements();

  /// Persists progress and records unlocks at most once per achievement.
  Future<void> saveAchievements(
    List<AchievementProgress> progress, {
    required DateTime nowUtc,
  });

  /// Activity for one local date.
  Future<DailyStatus> dailyStatus(String localDate);

  /// Records a completed session on [localDate], marking the Daily Challenge
  /// when [dailyChallenge] is true.
  Future<void> recordDailyCompletion({
    required String localDate,
    required bool dailyChallenge,
    required DateTime nowUtc,
  });

  /// Current and longest local streaks.
  Future<StreakSummary> streak(String todayLocalDate);

  /// Deletes all achievement and daily-activity records.
  ///
  /// Used by "Reset local data" together with the session history reset so a
  /// reset really returns the player to a clean state.
  Future<void> clearAll();
}
