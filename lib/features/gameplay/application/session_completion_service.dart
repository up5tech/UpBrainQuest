import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/progress/progress_repository.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

/// Orchestrates the durable side effects of finishing a session.
///
/// Order matters: the session is saved first, then daily activity is recorded,
/// then achievements are evaluated from the updated records and persisted
/// (PLAN Phase 7 tasks 3–5). If a later step fails, the session remains saved
/// and achievements are recomputed on the next completion.
class SessionCompletionService {
  const SessionCompletionService({
    required this.history,
    required this.progress,
    this.engine = const AchievementEngine(),
  });

  final SessionHistoryRepository history;
  final ProgressRepository progress;
  final AchievementEngine engine;

  Future<void> complete(SessionResult result, {required DateTime now}) async {
    await history.saveSession(result);

    final String localDate = localDateKey(now);
    await progress.recordDailyCompletion(
      localDate: localDate,
      dailyChallenge: result.mode == GameMode.dailyChallenge,
      nowUtc: now.toUtc(),
    );

    final AchievementStats stats = await progress.achievementStats(
      todayLocalDate: localDate,
    );
    final List<AchievementProgress> evaluated = engine.evaluate(stats);
    await progress.saveAchievements(evaluated, nowUtc: now.toUtc());
  }
}
