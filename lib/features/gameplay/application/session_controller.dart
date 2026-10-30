import 'dart:math' show Random;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_builder.dart';
import 'package:up_brain_quest/domain/session/session_plan.dart';
import 'package:up_brain_quest/domain/session/session_request.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

/// Reactive state for an active or absent gameplay session (PLAN §3.2).
///
/// The state machine is explicit: a session is created with [start], each
/// question is answered exactly once via [submit], and [continueNext] advances
/// or finalises. The same [PlayerAnswer] can never be scored twice.
sealed class SessionControllerState {
  const SessionControllerState();
}

/// No session is active (initial state or after reset).
class NoSession extends SessionControllerState {
  const NoSession();
}

/// An active or completed session with per-question progress.
class ActiveSession extends SessionControllerState {
  const ActiveSession({
    required this.plan,
    required this.currentIndex,
    required this.submissions,
    required this.evaluations,
    required this.completed,
    required this.scoreAlgorithmVersion,
    required this.startedAt,
    this.contentPackVersion = '',
    this.iqScore,
    this.eqScore,
  });

  final SessionPlan plan;
  final int currentIndex;
  final List<PlayerAnswer?> submissions;
  final List<AnswerEvaluation?> evaluations;
  final bool completed;
  final int scoreAlgorithmVersion;
  final DateTime startedAt;
  final String contentPackVersion;
  final IqScoreResult? iqScore;
  final EqScoreResult? eqScore;

  ActiveSession copyWith({
    SessionPlan? plan,
    int? currentIndex,
    List<PlayerAnswer?>? submissions,
    List<AnswerEvaluation?>? evaluations,
    bool? completed,
    int? scoreAlgorithmVersion,
    DateTime? startedAt,
    String? contentPackVersion,
    IqScoreResult? iqScore,
    EqScoreResult? eqScore,
  }) => ActiveSession(
    plan: plan ?? this.plan,
    currentIndex: currentIndex ?? this.currentIndex,
    submissions: submissions ?? this.submissions,
    evaluations: evaluations ?? this.evaluations,
    completed: completed ?? this.completed,
    scoreAlgorithmVersion: scoreAlgorithmVersion ?? this.scoreAlgorithmVersion,
    startedAt: startedAt ?? this.startedAt,
    contentPackVersion: contentPackVersion ?? this.contentPackVersion,
    iqScore: iqScore ?? this.iqScore,
    eqScore: eqScore ?? this.eqScore,
  );

  QuestionItem get currentItem => plan.items[currentIndex];

  AnswerEvaluation? get currentEvaluation =>
      currentIndex < evaluations.length ? evaluations[currentIndex] : null;

  PlayerAnswer? get currentSubmission =>
      currentIndex < submissions.length ? submissions[currentIndex] : null;
}

/// Provider for the single active gameplay session.
///
/// Deliberately not `autoDispose`: the result screen reads the finished session
/// via a passed [SessionResult] snapshot, but keeping the controller alive
/// across navigation lets "Replay" resume cleanly and avoids losing an
/// in-progress session when the gameplay route is replaced.
final AsyncNotifierProvider<SessionController, SessionControllerState>
sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionControllerState>(
      SessionController.new,
    );

/// Drives the session state machine (PLAN §3.2).
class SessionController extends AsyncNotifier<SessionControllerState> {
  @override
  SessionControllerState build() => const NoSession();

  /// Builds a plan from [request] and [bank] and opens the session.
  ///
  /// Throws [QuestionSelectionFailure] if the bank cannot satisfy the request;
  /// callers should surface that as a recoverable message (PLAN §5.7).
  void start({required SessionRequest request, required ContentBank bank}) {
    final Random rng = request.seed == null ? Random() : Random(request.seed);
    final SessionPlan plan = const SessionBuilder().build(
      request: request,
      bank: bank,
      rng: rng,
    );
    state = AsyncValue<SessionControllerState>.data(
      ActiveSession(
        plan: plan,
        currentIndex: 0,
        submissions: List<PlayerAnswer?>.filled(plan.items.length, null),
        evaluations: List<AnswerEvaluation?>.filled(plan.items.length, null),
        completed: false,
        scoreAlgorithmVersion: request.scoreAlgorithmVersion,
        startedAt: DateTime.now().toUtc(),
        contentPackVersion: request.contentPackVersion,
      ),
    );
  }

  /// Records the answer for the current question exactly once.
  ///
  /// Repeated calls (e.g. fast double-taps) are ignored, so an answer can never
  /// be scored more than once (PLAN §3.2).
  void submit(PlayerAnswer answer) {
    final SessionControllerState current = state.value ?? const NoSession();
    if (current is! ActiveSession || current.completed) return;
    final int index = current.currentIndex;
    if (index >= current.evaluations.length) return;
    if (current.evaluations[index] != null) return; // double-submit guard

    final AnswerEvaluation evaluation = evaluateAnswer(
      current.plan.items[index],
      answer,
    );
    final List<PlayerAnswer?> submissions = List<PlayerAnswer?>.from(
      current.submissions,
    );
    final List<AnswerEvaluation?> evaluations = List<AnswerEvaluation?>.from(
      current.evaluations,
    );
    submissions[index] = answer;
    evaluations[index] = evaluation;
    state = AsyncValue<SessionControllerState>.data(
      current.copyWith(submissions: submissions, evaluations: evaluations),
    );
  }

  /// Advances to the next question, or finalises the session on the last one.
  void continueNext() {
    final SessionControllerState current = state.value ?? const NoSession();
    if (current is! ActiveSession) return;
    final int index = current.currentIndex;
    if (index >= current.evaluations.length) return;
    if (current.evaluations[index] == null) return; // must answer first

    if (index >= current.plan.items.length - 1) {
      final List<AnswerEvaluation> all = current.evaluations
          .whereType<AnswerEvaluation>()
          .toList();
      final IqScoreResult iq = const IqScoreCalculator().calculate(all);
      final EqScoreResult eq = const EqScoreCalculator().calculate(all);
      state = AsyncValue<SessionControllerState>.data(
        current.copyWith(completed: true, iqScore: iq, eqScore: eq),
      );
    } else {
      state = AsyncValue<SessionControllerState>.data(
        current.copyWith(currentIndex: index + 1),
      );
    }
  }

  /// Returns to the no-session state (used when leaving the result screen).
  void reset() {
    state = const AsyncValue<SessionControllerState>.data(NoSession());
  }

  /// Snapshots the completed session for the result and review screens.
  SessionResult? toResult() {
    final SessionControllerState current = state.value ?? const NoSession();
    if (current is! ActiveSession || !current.completed) return null;
    final IqScoreResult iq = current.iqScore ?? const IqScoreResult.invalid();
    final EqScoreResult eq = current.eqScore ?? const EqScoreResult.invalid();
    return SessionResult(
      mode: current.plan.mode,
      questions: current.plan.items,
      answers: current.submissions,
      evaluations: current.evaluations,
      scoreAlgorithmVersion: current.scoreAlgorithmVersion,
      iqScore: iq,
      eqScore: eq,
      startedAtUtc: current.startedAt,
      contentPackVersion: current.contentPackVersion,
      completedAtUtc: DateTime.now().toUtc(),
    );
  }
}
