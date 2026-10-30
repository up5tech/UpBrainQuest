import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

/// Persistence boundary for completed sessions and progress (PLAN §7.1).
///
/// The domain defines the contract; the data layer owns the SQLite/Drift
/// details so widgets and view models never touch the database (PLAN §6.3).
abstract interface class SessionHistoryRepository {
  /// Saves [result] and all of its attempts in a single transaction
  /// (PLAN §7.3).
  ///
  /// Throws if the save fails so the caller can surface a recoverable warning
  /// instead of claiming the result was durably saved.
  Future<void> saveSession(SessionResult result);

  /// Most recent sessions, newest first.
  Future<List<SessionSummary>> recentSessions({int limit = 20});

  /// Question IDs from the most recent sessions, for replay avoidance
  /// (PLAN §5.7, Phase 7 task 7).
  Future<List<String>> recentQuestionIds({int limit = 20});

  /// Aggregate progress derived from persisted sessions.
  Future<ProgressSummary> progressSummary();

  /// Deletes all local session history. Preferences are kept.
  Future<void> clearAll();
}
