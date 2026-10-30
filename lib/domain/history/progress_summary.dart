import 'package:up_brain_quest/domain/session/game_mode.dart';

/// Aggregate progress derived from persisted sessions (PLAN §7.1).
///
/// Values are honest summaries of local records, never a standardized or
/// clinical measurement (PLAN §4). No trend is implied unless there is enough
/// data, so the UI only shows "recent game performance" (PLAN Phase 6 task 7).
class ProgressSummary {
  const ProgressSummary({
    required this.sessionCount,
    required this.completedCount,
    required this.modeCounts,
    this.iqBest,
    this.eqBest,
  });

  /// An empty summary for a fresh install (no fabricated progress).
  const ProgressSummary.empty()
    : sessionCount = 0,
      completedCount = 0,
      modeCounts = const <GameMode, int>{},
      iqBest = null,
      eqBest = null;

  final int sessionCount;
  final int completedCount;
  final Map<GameMode, int> modeCounts;

  /// Best IQ Challenge Score across history, or `null` when none exists.
  final int? iqBest;

  /// Best EQ Practice Score across history, or `null` when none exists.
  final int? eqBest;

  bool get hasHistory => sessionCount > 0;
}
