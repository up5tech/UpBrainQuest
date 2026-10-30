import 'package:drift/drift.dart';

import 'package:up_brain_quest/data/database/tables/game_sessions.dart';

/// One answered (or skipped) question inside a [GameSessions] row (PLAN §7.2).
///
/// Attempts are written in the same transaction as their session so a session
/// and its history are always consistent (PLAN §7.3).
class QuestionAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Owning session; deleting the session removes its attempts.
  IntColumn get sessionId =>
      integer().references(GameSessions, #id, onDelete: KeyAction.cascade)();

  /// Stable question ID from the bundled content.
  TextColumn get questionId => text()();

  /// Domain and skill snapshots for historical reporting.
  TextColumn get domain => text()();

  TextColumn get skill => text()();

  /// Zero-based order within the session.
  IntColumn get questionOrder => integer()();

  /// Typed answer snapshot encoded as JSON (never free-form personal text).
  TextColumn get submittedAnswerJson =>
      text().withDefault(const Constant('null'))();

  /// `null` for EQ items (non-binary) or unattempted questions.
  BoolColumn get isCorrect => boolean().nullable()();

  IntColumn get earnedPoints => integer().withDefault(const Constant(0))();

  IntColumn get possiblePoints => integer().withDefault(const Constant(0))();

  /// Optional EQ dimension scores encoded as JSON.
  TextColumn get rubricScoresJson => text().nullable()();

  IntColumn get elapsedMs => integer().nullable()();

  BoolColumn get hintUsed => boolean().withDefault(const Constant(false))();

  DateTimeColumn get answeredAt => dateTime().nullable()();

  /// One attempt per session + question (PLAN §7.2).
  @override
  List<String> get customConstraints => <String>[
    'UNIQUE(session_id, question_id)',
  ];
}
