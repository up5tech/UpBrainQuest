import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_gradients.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';
import 'package:up_brain_quest/core/widgets/app_empty_state.dart';
import 'package:up_brain_quest/core/widgets/app_error_state.dart';
import 'package:up_brain_quest/core/widgets/app_progress_bar.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';
import 'package:up_brain_quest/features/gameplay/application/session_completion_service.dart';
import 'package:up_brain_quest/features/gameplay/application/session_controller.dart';

/// Results screen for a completed session (PLAN §3.1, Phase 3–5).
///
/// Shows the in-game IQ Challenge Score and/or EQ Practice Score with visible
/// disclaimers, a completion summary, and a per-question review that reflects
/// the player's exact recorded responses. Neither number is ever presented as a
/// standardized IQ result or a clinical EQ assessment (PLAN §4.1–§4.3).
class SessionResultPage extends ConsumerStatefulWidget {
  const SessionResultPage({this.result, super.key});

  final SessionResult? result;

  @override
  ConsumerState<SessionResultPage> createState() => _SessionResultPageState();
}

/// Whether the completed session has been durably saved (PLAN §7.3).
enum _SaveState { saving, saved, failed }

class _SessionResultPageState extends ConsumerState<SessionResultPage> {
  _SaveState _saveState = _SaveState.saving;

  @override
  void initState() {
    super.initState();
    final SessionResult? result = widget.result;
    if (result != null && _isConsistent(result)) {
      // Save after the first frame so we never touch providers during build.
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        unawaited(_save(result));
      });
    }
  }

  bool _isConsistent(SessionResult data) =>
      data.answers.length == data.questions.length &&
      data.evaluations.length == data.questions.length;

  /// Persists [result] once, surfacing success or a recoverable failure. A
  /// failed save is never presented as durable (PLAN §7.3).
  Future<void> _save(SessionResult result) async {
    if (!mounted) return;
    setState(() => _saveState = _SaveState.saving);
    try {
      final SessionCompletionService service = await ref.read(
        sessionCompletionServiceProvider.future,
      );
      await service.complete(result, now: DateTime.now());
      if (!mounted) return;
      setState(() => _saveState = _SaveState.saved);
      ref
        ..invalidate(sessionHistoryProvider)
        ..invalidate(progressSummaryProvider)
        ..invalidate(achievementsProvider)
        ..invalidate(dailyStatusProvider)
        ..invalidate(streakProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saveState = _SaveState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SessionResult? result = widget.result;
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.sessionResultTitle)),
        body: AppEmptyState(
          message: AppStrings.sessionNotAvailable,
          actionLabel: AppStrings.sessionBackHome,
          onAction: () => context.go('/'),
        ),
      );
    }

    final SessionResult data = result;
    // Defensive: a result whose answers/evaluations do not line up with its
    // questions cannot be reviewed honestly, so fail closed (PLAN §5.2).
    if (!_isConsistent(data)) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.sessionResultTitle)),
        body: AppErrorState(
          message: AppStrings.sessionResultError,
          onRetry: () => context.go('/'),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final bool reduceMotion =
        MediaQuery.of(context).disableAnimations ||
        (ref.watch(appSettingsProvider).value?.reducedMotion ?? false);

    final Widget body = ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        _SaveBanner(state: _saveState, onRetry: () => _save(data)),
        const SizedBox(height: AppSpacing.md),
        ..._scoreCards(data),
        _ProgressSummary(data: data),
        const SizedBox(height: AppSpacing.lg),
        if (data.objectiveCount > 0) ...<Widget>[
          _AccuracyCard(data: data),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(AppStrings.sessionReview, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        for (int i = 0; i < data.questions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ReviewCard(
              index: i,
              item: data.questions[i],
              answer: data.answers[i],
              evaluation: data.evaluations[i],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: AppStrings.sessionPlayAgain,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  ref.read(sessionControllerProvider.notifier).reset();
                  context.go('/session/setup/${data.mode.key}');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: AppStrings.sessionBackHome,
                onPressed: () {
                  ref.read(sessionControllerProvider.notifier).reset();
                  context.go('/');
                },
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sessionResultTitle)),
      // Restrained entrance animation. Values are final from the first frame;
      // only opacity animates, and reduced-motion users skip it entirely
      // (PLAN §8.4, Phase 5 task 7).
      body: reduceMotion
          ? body
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (BuildContext context, double value, Widget? child) =>
                  Opacity(opacity: value, child: child),
              child: body,
            ),
    );
  }

  List<Widget> _scoreCards(SessionResult data) {
    final List<Widget> cards = <Widget>[];
    final bool hasObjective = data.objectiveCount > 0;
    final bool hasEq = data.eqScore.possible > 0;

    if (hasObjective) {
      cards
        ..add(
          _ScoreCard(
            label: AppStrings.sessionIqScoreLabel,
            value: data.iqScore.valid && data.iqScore.score != null
                ? data.iqScore.score!.toString()
                : '—',
            disclaimer: AppStrings.sessionScoreDisclaimer,
          ),
        )
        ..add(const SizedBox(height: AppSpacing.lg));
    }
    if (hasEq) {
      cards
        ..add(
          _ScoreCard(
            label: AppStrings.sessionEqScoreLabel,
            value: data.eqScore.valid && data.eqScore.score != null
                ? data.eqScore.score!.toString()
                : '—',
            disclaimer: AppStrings.sessionEqScoreDisclaimer,
          ),
        )
        ..add(const SizedBox(height: AppSpacing.lg))
        ..add(_DimensionBreakdown(score: data.eqScore))
        ..add(const SizedBox(height: AppSpacing.lg));
    }
    if (!hasObjective && !hasEq) {
      cards
        ..add(
          const _ScoreCard(
            label: AppStrings.sessionIqScoreLabel,
            value: '—',
            disclaimer: AppStrings.sessionScoreDisclaimer,
          ),
        )
        ..add(const SizedBox(height: AppSpacing.lg));
    }
    return cards;
  }
}

/// Human-readable text for the option a player selected.
String _optionText(List<QuestionOption> options, String optionId) {
  for (final QuestionOption option in options) {
    if (option.id == optionId) return option.text;
  }
  return optionId;
}

/// The player's exact recorded response, formatted for review.
String _playerResponse(QuestionItem item, PlayerAnswer? answer) {
  if (answer == null || answer is UnansweredAnswer) {
    return AppStrings.sessionNotAnswered;
  }
  if (answer is SelectedOptionAnswer) {
    if (item is MultipleChoiceItem) {
      return _optionText(item.options, answer.optionId);
    }
    if (item is EqScenarioItem) {
      return _optionText(item.options, answer.optionId);
    }
    return answer.optionId;
  }
  if (answer is SequenceAnswer) {
    return answer.sequence.join(' · ');
  }
  if (answer is ReorderAnswer) {
    return answer.order.join(' → ');
  }
  return '—';
}

/// The authored correct response, or `null` for non-binary EQ items.
String? _correctResponse(QuestionItem item) {
  if (item is MultipleChoiceItem) {
    return _optionText(item.options, item.correctOptionId);
  }
  if (item is PuzzleItem) {
    if (item.contentType == ContentType.memorySequence) {
      return item.expectedAnswer.map((dynamic e) => '$e').join(' · ');
    }
    if (item.contentType == ContentType.reorderSequence) {
      return item.expectedAnswer.map((dynamic e) => '$e').join(' → ');
    }
  }
  return null;
}

/// Per-dimension rubric summary for an EQ answer (earned / possible).
String? _rubricSummary(AnswerEvaluation? evaluation) {
  final Map<EqDimension, int>? earned = evaluation?.rubricScores;
  if (earned == null || earned.isEmpty) return null;
  final Map<EqDimension, int>? possible = evaluation?.dimensionPossible;
  final List<String> parts = <String>[];
  for (final EqDimension dimension in EqDimension.values) {
    final int? value = earned[dimension];
    if (value == null) continue;
    final int max = possible?[dimension] ?? 0;
    parts.add('${AppStrings.eqDimensionLabel(dimension)} $value/$max');
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

/// The large, gradient score card with a visible disclaimer.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.disclaimer,
  });

  final String label;
  final String value;
  final String disclaimer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return MergeSemantics(
      child: AppCard(
        gradient: AppGradients.primary,
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textOnAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.score.copyWith(
                color: AppColors.textOnAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              disclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textOnAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Questions-completed summary with an honest incomplete note.
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.data});

  final SessionResult data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.sessionQuestionsCompleted,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.fractionOf(data.answeredCount, data.questionCount),
            style: theme.textTheme.bodyLarge,
          ),
          if (!data.isComplete) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              AppStrings.sessionIncompleteNote,
              style: AppTypography.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Objective accuracy summary (IQ / puzzle items only).
class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({required this.data});

  final SessionResult data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AppStrings.sessionAccuracy, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.correctOutOf(data.correctCount, data.objectiveCount),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// One review card: prompt, the player's exact response, the correct answer or
/// rubric summary, and the explanation (PLAN Phase 5 task 4).
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.item,
    required this.answer,
    required this.evaluation,
  });

  final int index;
  final QuestionItem item;
  final PlayerAnswer? answer;
  final AnswerEvaluation? evaluation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QuestionItem question = item;
    final List<Widget> children = <Widget>[
      Text(
        '${index + 1}. ${question.prompt}',
        style: theme.textTheme.bodyLarge,
      ),
      _ReviewRow(
        label: AppStrings.sessionYourAnswer,
        value: _playerResponse(question, answer),
      ),
    ];

    if (question is EqScenarioItem) {
      final String? rubric = _rubricSummary(evaluation);
      if (rubric != null) {
        children.add(
          _ReviewRow(label: AppStrings.sessionRubricSummary, value: rubric),
        );
      }
      final String? feedback = evaluation?.feedback;
      if (feedback != null && feedback.isNotEmpty) {
        children.add(
          _ReviewRow(label: AppStrings.sessionEqReflection, value: feedback),
        );
      }
      if (question.followUpReflection != null &&
          question.followUpReflection!.isNotEmpty) {
        children.add(
          _ReviewRow(
            label: AppStrings.sessionEqFollowUp,
            value: question.followUpReflection!,
          ),
        );
      }
    } else {
      final String? correct = _correctResponse(question);
      if (correct != null) {
        children.add(
          _ReviewRow(label: AppStrings.sessionCorrectAnswer, value: correct),
        );
      }
      final String status;
      if (evaluation == null) {
        status = '—';
      } else if (evaluation!.isCorrect == true) {
        status = AppStrings.sessionCorrect;
      } else {
        status = AppStrings.sessionIncorrect;
      }
      children.add(
        _ReviewRow(label: AppStrings.sessionResultStatus, value: status),
      );
      final String? explanation = question.explanation;
      if (explanation != null && explanation.isNotEmpty) {
        children.add(
          _ReviewRow(label: AppStrings.sessionExplanation, value: explanation),
        );
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// A "Label: value" row used in the review cards.
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: AppTypography.bodySecondary,
      ),
    );
  }
}

/// Per-dimension EQ practice breakdown — shows where practice was concentrated
/// without framing any dimension as a deficiency (PLAN §4.3, §4.6).
class _DimensionBreakdown extends StatelessWidget {
  const _DimensionBreakdown({required this.score});

  final EqScoreResult score;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<EqDimension> dimensions = score.dimensions;
    if (dimensions.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.sessionEqDimensionsTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final EqDimension dimension in dimensions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppProgressBar(
                value: score.dimensionScore(dimension) / 100,
                label: AppStrings.eqDimensionLabel(dimension),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact banner that reports whether the result was saved to local history.
class _SaveBanner extends StatelessWidget {
  const _SaveBanner({required this.state, required this.onRetry});

  final _SaveState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String text, Color color) = switch (state) {
      _SaveState.saving => (
        Icons.sync,
        AppStrings.sessionSaving,
        AppColors.textSecondary,
      ),
      _SaveState.saved => (
        Icons.check_circle_outline,
        AppStrings.sessionSaved,
        AppColors.positive,
      ),
      _SaveState.failed => (
        Icons.error_outline,
        AppStrings.sessionSaveFailed,
        AppColors.error,
      ),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(text, style: AppTypography.bodySecondary)),
            ],
          ),
          if (state == _SaveState.failed) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: AppStrings.sessionSaveRetry,
              variant: AppButtonVariant.outline,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
