import 'package:drift/drift.dart';

/// A completed (or abandoned) game session, persisted locally (PLAN §7.2).
///
/// One row per session; the per-question detail lives in [QuestionAttempts].
/// Scores are nullable so a session without objective items (pure EQ) or
/// without EQ items (pure IQ) does not fabricate a zero (PLAN §4.2, §4.3).
class GameSessions extends Table {
  /// Locally generated primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Stable mode key (`quick`, `iq`, `eq`, `puzzle`, `daily`).
  TextColumn get mode => text()();

  /// `completed` or `abandoned`; unfinished sessions are never scored as
  /// completed (PLAN §7.2).
  TextColumn get status => text().withDefault(const Constant('completed'))();

  /// Session start, stored in UTC (PLAN §7.3).
  DateTimeColumn get startedAt => dateTime()();

  /// Completion time in UTC, nullable while a session is unfinished.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Elapsed duration in milliseconds, when known.
  IntColumn get durationMs => integer().nullable()();

  IntColumn get questionCount => integer()();

  IntColumn get answeredCount => integer()();

  /// In-game IQ Challenge Score (0–100), or `null` when not applicable.
  IntColumn get iqScore => integer().nullable()();

  /// In-game EQ Practice Score (0–100), or `null` when not applicable.
  IntColumn get eqScore => integer().nullable()();

  IntColumn get earnedPoints => integer().nullable()();

  IntColumn get possiblePoints => integer().nullable()();

  /// Score algorithm version so historical scores stay interpretable
  /// (PLAN §4.5).
  IntColumn get scoreAlgorithmVersion => integer()();

  TextColumn get contentPackVersion => text().withDefault(const Constant(''))();

  /// ISO local date for daily challenges, or `null` for other modes.
  TextColumn get dailyLocalDate => text().nullable()();
}
