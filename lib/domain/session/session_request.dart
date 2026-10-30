import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';

/// A request to build a session (PLAN §5.7).
///
/// The selection logic is pure and deterministic given the optional [seed], so
/// tests can reproduce any session.
class SessionRequest {
  const SessionRequest({
    required this.mode,
    required this.count,
    this.difficulties,
    this.recentQuestionIds = const <String>[],
    this.seed,
    this.contentPackVersion = '',
    this.scoreAlgorithmVersion = IqScoreCalculator.scoreAlgorithmVersion,
    this.domainMix,
  });

  /// The game mode, which drives the domain mix.
  final GameMode mode;

  /// How many questions the session should contain.
  final int count;

  /// Optional difficulty filter. `null` means any difficulty.
  final Set<Difficulty>? difficulties;

  /// Recently used question IDs to avoid repeating when alternatives exist.
  final List<String> recentQuestionIds;

  /// Optional deterministic seed for selection. `null` uses the default RNG.
  final int? seed;

  /// Content-pack version, recorded on the result for future-proofing.
  final String contentPackVersion;

  /// Score-algorithm version recorded with the result (PLAN §4.5).
  final int scoreAlgorithmVersion;

  /// Optional per-domain target mix. When `null`, [SessionBuilder] applies
  /// [SessionBuilder.quickQuestMix] for [GameMode.quickQuest] and no mix for
  /// other modes. Counts are targets, not hard limits (PLAN §2.2A, §5.7).
  final Map<ContentDomain, int>? domainMix;
}
