import 'package:up_brain_quest/domain/session/game_mode.dart';

/// A compact, read-only summary of one persisted session (PLAN §7.2).
///
/// This is what history lists display; it deliberately does not carry the full
/// question/answer detail, which lives in the database for review only.
class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.mode,
    required this.completedAtUtc,
    required this.questionCount,
    required this.answeredCount,
    this.iqScore,
    this.eqScore,
  });

  final int id;
  final GameMode mode;
  final DateTime completedAtUtc;
  final int questionCount;
  final int answeredCount;

  /// In-game IQ Challenge Score, or `null` when the session had no objective
  /// items.
  final int? iqScore;

  /// In-game EQ Practice Score, or `null` when the session had no EQ items.
  final int? eqScore;

  /// Whether every question received a real response.
  bool get isComplete => answeredCount >= questionCount;
}
