import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:up_brain_quest/data/content/content_repository.dart';
import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/database/app_database_opener.dart';
import 'package:up_brain_quest/data/history/drift_session_history_repository.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/data/preferences/settings_repository.dart';
import 'package:up_brain_quest/data/progress/drift_progress_repository.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/progress/progress_repository.dart';
import 'package:up_brain_quest/features/gameplay/application/session_completion_service.dart';

/// Provider exposing the local [SettingsRepository].
///
/// The repository wraps [SharedPreferencesAsync] for lightweight, non-critical
/// UI preferences (PLAN §7.1). It is intentionally not used for authoritative
/// game records.
final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
      return SettingsRepository(SharedPreferencesAsync());
    });

/// Provider exposing the current [AppSettings] and mutations on it.
///
/// Backed by [SettingsRepository]; the reduced-motion flag is the first
/// preference the UI reads, so animation components can honour it (PLAN §8.4,
/// Phase 1 task 8).
final AsyncNotifierProvider<AppSettingsNotifier, AppSettings>
appSettingsProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Notifier that loads and persists [AppSettings].
class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final SettingsRepository repository = ref.watch(settingsRepositoryProvider);
    return repository.load();
  }

  Future<void> setReducedMotion(bool value) async {
    final AppSettings? current = state.value;
    if (current == null) return;
    await ref.read(settingsRepositoryProvider).setReducedMotion(value);
    state = AsyncData<AppSettings>(current.copyWith(reducedMotion: value));
  }

  Future<void> setSoundEnabled(bool value) async {
    final AppSettings? current = state.value;
    if (current == null) return;
    await ref.read(settingsRepositoryProvider).setSoundEnabled(value);
    state = AsyncData<AppSettings>(current.copyWith(soundEnabled: value));
  }

  Future<void> setHapticsEnabled(bool value) async {
    final AppSettings? current = state.value;
    if (current == null) return;
    await ref.read(settingsRepositoryProvider).setHapticsEnabled(value);
    state = AsyncData<AppSettings>(current.copyWith(hapticsEnabled: value));
  }
}

/// Provider exposing the local [AppDatabase].
///
/// The database is opened lazily on first use and shared for the lifetime of
/// the container. Widgets must not access it directly; repositories in the
/// data layer own that responsibility (PLAN §6.3).
///
/// Transactions are started through `AppDatabase.transaction(...)` rather
/// than by exposing the raw connection, so that the transaction boundary
/// stays inside the data layer (PLAN §7.3).
final FutureProvider<AppDatabase> appDatabaseProvider =
    FutureProvider<AppDatabase>((Ref ref) async {
      final AppDatabase database = await openAppDatabase();
      ref.onDispose(database.close);
      return database;
    });

/// Provider exposing the local [ContentRepository].
///
/// The repository reads the bundled JSON question pack — the single source of
/// truth for questions (PLAN §5.1, §7.4). It performs no network access.
final Provider<ContentRepository> contentRepositoryProvider =
    Provider<ContentRepository>((Ref ref) => const ContentRepository());

/// Loads and validates the bundled content pack.
///
/// Exposes a [ContentLoadResult] so the UI can show honest loading, error, or
/// partial-content states (PLAN §5.2). Invalid records are excluded and
/// reported rather than crashing the app.
final FutureProvider<ContentLoadResult> contentProvider =
    FutureProvider<ContentLoadResult>(
      (Ref ref) => ref.watch(contentRepositoryProvider).load(),
    );

/// Repository over the local session history (PLAN §7.1).
///
/// Widgets never touch the database directly; they read history and progress
/// through the providers below (PLAN §6.3).
final FutureProvider<SessionHistoryRepository>
sessionHistoryRepositoryProvider = FutureProvider<SessionHistoryRepository>((
  Ref ref,
) async {
  final AppDatabase database = await ref.watch(appDatabaseProvider.future);
  return DriftSessionHistoryRepository(database);
});

/// Recent completed sessions, newest first.
final FutureProvider<List<SessionSummary>> sessionHistoryProvider =
    FutureProvider<List<SessionSummary>>((Ref ref) async {
      final SessionHistoryRepository repository = await ref.watch(
        sessionHistoryRepositoryProvider.future,
      );
      return repository.recentSessions();
    });

/// Aggregate progress derived from persisted sessions.
final FutureProvider<ProgressSummary> progressSummaryProvider =
    FutureProvider<ProgressSummary>((Ref ref) async {
      final SessionHistoryRepository repository = await ref.watch(
        sessionHistoryRepositoryProvider.future,
      );
      return repository.progressSummary();
    });

/// Repository over local achievements and daily activity (PLAN Phase 7).
final FutureProvider<ProgressRepository> progressRepositoryProvider =
    FutureProvider<ProgressRepository>((Ref ref) async {
      final AppDatabase database = await ref.watch(appDatabaseProvider.future);
      return DriftProgressRepository(database);
    });

/// Orchestrates save + daily activity + achievement evaluation on completion.
final FutureProvider<SessionCompletionService>
sessionCompletionServiceProvider = FutureProvider<SessionCompletionService>((
  Ref ref,
) async {
  final SessionHistoryRepository history = await ref.watch(
    sessionHistoryRepositoryProvider.future,
  );
  final ProgressRepository progress = await ref.watch(
    progressRepositoryProvider.future,
  );
  return SessionCompletionService(history: history, progress: progress);
});

/// All catalog achievements, with persisted progress and unlock state.
final FutureProvider<List<AchievementRecord>> achievementsProvider =
    FutureProvider<List<AchievementRecord>>((Ref ref) async {
      final ProgressRepository repository = await ref.watch(
        progressRepositoryProvider.future,
      );
      return repository.loadAchievements();
    });

/// Local activity for today's date.
final FutureProvider<DailyStatus> dailyStatusProvider =
    FutureProvider<DailyStatus>((Ref ref) async {
      final ProgressRepository repository = await ref.watch(
        progressRepositoryProvider.future,
      );
      return repository.dailyStatus(localDateKey(DateTime.now()));
    });

/// Current and longest local streaks.
final FutureProvider<StreakSummary> streakProvider =
    FutureProvider<StreakSummary>((Ref ref) async {
      final ProgressRepository repository = await ref.watch(
        progressRepositoryProvider.future,
      );
      return repository.streak(localDateKey(DateTime.now()));
    });
