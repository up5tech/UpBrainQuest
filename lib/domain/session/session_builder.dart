import 'dart:math' show Random;

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/selection_error.dart';
import 'package:up_brain_quest/domain/session/session_plan.dart';
import 'package:up_brain_quest/domain/session/session_request.dart';

/// Pure, unit-testable question selection (PLAN §5.7).
///
/// Guarantees: no duplicate IDs, the requested domain mix when possible, an
/// optional difficulty filter, avoidance of recent IDs when alternatives exist,
/// and deterministic output for a given seed. Throws
/// [QuestionSelectionFailure] instead of silently returning fewer questions.
class SessionBuilder {
  const SessionBuilder();

  /// Default balanced Quick Quest mix (PLAN §2.2A): five reasoning items, two
  /// puzzle items, and three EQ scenarios. Counts are targets; the builder
  /// rebalances within this domain set when the bank is short and throws when
  /// it cannot reach the requested length — it never substitutes a domain that
  /// is not part of the mix.
  static const Map<ContentDomain, int> quickQuestMix = <ContentDomain, int>{
    ContentDomain.iq: 5,
    ContentDomain.puzzle: 2,
    ContentDomain.eq: 3,
  };

  /// Items eligible for [request] before recent-ID avoidance is applied.
  List<QuestionItem> candidates(SessionRequest request, ContentBank bank) {
    return bank.items.where((QuestionItem item) {
      if (!accepts(request.mode, item)) return false;
      if (request.difficulties != null &&
          !request.difficulties!.contains(item.difficulty)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Convenience count of [candidates].
  int candidateCount(SessionRequest request, ContentBank bank) =>
      candidates(request, bank).length;

  /// Whether [item] belongs to the domain set implied by [mode].
  static bool accepts(GameMode mode, QuestionItem item) {
    switch (mode) {
      case GameMode.iqChallenge:
        return item.domain == ContentDomain.iq ||
            item.domain == ContentDomain.puzzle;
      case GameMode.eqChallenge:
        return item.domain == ContentDomain.eq;
      case GameMode.puzzleSprint:
        return item.domain == ContentDomain.puzzle;
      case GameMode.quickQuest:
      case GameMode.dailyChallenge:
        return true;
    }
  }

  /// Builds the session. [rng] must be injectable so tests are deterministic.
  SessionPlan build({
    required SessionRequest request,
    required ContentBank bank,
    required Random rng,
  }) {
    final List<QuestionItem> pool = candidates(request, bank);
    if (pool.length < request.count) {
      throw const QuestionSelectionFailure(
        'The installed content bank does not have enough questions to build '
        'this session.',
      );
    }

    final Map<ContentDomain, int>? mix =
        request.domainMix ??
        (request.mode == GameMode.quickQuest ? quickQuestMix : null);
    if (mix != null) {
      return SessionPlan(
        items: _selectMixed(request: request, pool: pool, mix: mix, rng: rng),
        mode: request.mode,
      );
    }

    final Set<String> recent = request.recentQuestionIds.toSet();
    final List<QuestionItem> fresh = pool
        .where((QuestionItem q) => !recent.contains(q.id))
        .toList();
    final List<QuestionItem> recentOnly = pool
        .where((QuestionItem q) => recent.contains(q.id))
        .toList();

    fresh.shuffle(rng);
    recentOnly.shuffle(rng);

    final List<QuestionItem> chosen = <QuestionItem>[];
    for (final QuestionItem q in fresh) {
      if (chosen.length >= request.count) break;
      chosen.add(q);
    }
    for (final QuestionItem q in recentOnly) {
      if (chosen.length >= request.count) break;
      chosen.add(q);
    }

    if (chosen.length < request.count) {
      throw const QuestionSelectionFailure(
        'Could not assemble a large enough session after avoiding recent '
        'questions.',
      );
    }

    return SessionPlan(items: chosen, mode: request.mode);
  }

  /// Selects a balanced session from [pool] using per-domain [mix] targets.
  ///
  /// Phase 1 takes up to each (scaled) target, preferring items not listed in
  /// [SessionRequest.recentQuestionIds]. Phase 2 fills any shortfall from the
  /// remaining items of the *same* domain set, so a small bank rebalances the
  /// mix instead of silently substituting an unintended domain. If the
  /// requested length still cannot be reached, a [QuestionSelectionFailure] is
  /// thrown (PLAN §2.2A, §5.7).
  List<QuestionItem> _selectMixed({
    required SessionRequest request,
    required List<QuestionItem> pool,
    required Map<ContentDomain, int> mix,
    required Random rng,
  }) {
    // A mixed mode must actually include each domain it targets; a completely
    // missing domain is a hard failure, not something to silently rebalance
    // away (PLAN §2.2A, §5.7).
    for (final MapEntry<ContentDomain, int> target in mix.entries) {
      if (target.value <= 0) continue;
      final bool hasDomain = pool.any(
        (QuestionItem q) => q.domain == target.key,
      );
      if (!hasDomain) {
        throw const QuestionSelectionFailure(
          'The installed content bank is missing a domain required by this '
          'mode.',
        );
      }
    }

    final Set<String> recent = request.recentQuestionIds.toSet();
    final int totalTarget = mix.values.fold<int>(
      0,
      (int sum, int value) => sum + value,
    );
    final List<QuestionItem> chosen = <QuestionItem>[];
    final Set<String> chosenIds = <String>{};

    for (final MapEntry<ContentDomain, int> target in mix.entries) {
      // Scale targets down proportionally if a shorter session was requested.
      final int desired = request.count >= totalTarget
          ? target.value
          : (target.value * request.count / totalTarget).round();
      final List<QuestionItem> domainPool = pool
          .where((QuestionItem q) => q.domain == target.key)
          .toList();
      final List<QuestionItem> fresh =
          domainPool.where((QuestionItem q) => !recent.contains(q.id)).toList()
            ..shuffle(rng);
      final List<QuestionItem> stale =
          domainPool.where((QuestionItem q) => recent.contains(q.id)).toList()
            ..shuffle(rng);
      int taken = 0;
      for (final QuestionItem q in <QuestionItem>[...fresh, ...stale]) {
        if (taken >= desired || chosen.length >= request.count) break;
        chosen.add(q);
        chosenIds.add(q.id);
        taken++;
      }
    }

    // Fill any shortfall from the same domain set (never a new domain).
    if (chosen.length < request.count) {
      final List<QuestionItem> surplus =
          pool
              .where(
                (QuestionItem q) =>
                    mix.containsKey(q.domain) && !chosenIds.contains(q.id),
              )
              .toList()
            ..shuffle(rng);
      for (final QuestionItem q in surplus) {
        if (chosen.length >= request.count) break;
        chosen.add(q);
        chosenIds.add(q.id);
      }
    }

    if (chosen.length < request.count) {
      throw const QuestionSelectionFailure(
        'The installed content bank cannot satisfy the requested mix.',
      );
    }

    // Interleave domains so a mixed session is not grouped by domain.
    chosen.shuffle(rng);
    return chosen;
  }
}
