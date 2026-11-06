import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/feedback/app_feedback.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';
import 'package:up_brain_quest/core/widgets/app_empty_state.dart';
import 'package:up_brain_quest/core/widgets/app_error_state.dart';
import 'package:up_brain_quest/core/widgets/app_progress_bar.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';
import 'package:up_brain_quest/features/gameplay/application/session_controller.dart';
import 'package:up_brain_quest/features/gameplay/widgets/eq_scenario_question.dart';
import 'package:up_brain_quest/features/gameplay/widgets/matching_pairs_question.dart';
import 'package:up_brain_quest/features/gameplay/widgets/memory_sequence_question.dart';
import 'package:up_brain_quest/features/gameplay/widgets/multiple_choice_question.dart';
import 'package:up_brain_quest/features/gameplay/widgets/reorder_sequence_question.dart';
import 'package:up_brain_quest/features/gameplay/widgets/symbol_choice_question.dart';

/// Active gameplay screen for a reasoning session (PLAN §3.1, §8.3).
///
/// Presents one question at a time with progress, the right mechanics widget
/// for the item type, immediate feedback, and a single continue action.
/// Repeated taps cannot double-score because the controller ignores a second
/// [submit] for the same question (PLAN §3.2).
class GameplayPage extends ConsumerStatefulWidget {
  const GameplayPage({super.key});

  @override
  ConsumerState<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends ConsumerState<GameplayPage> {
  PlayerAnswer? _answer;
  int _activeIndex = -1;
  bool _navigated = false;

  void _onAnswerChanged(PlayerAnswer? answer) {
    if (_navigated || !mounted) return;
    setState(() => _answer = answer);
  }

  void _confirmAbandon() {
    unawaited(
      showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(context.l10n.sessionAbandonTitle),
          content: Text(context.l10n.sessionAbandonBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.l10n.sessionAbandonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(context.l10n.sessionAbandonConfirm),
            ),
          ],
        ),
      ).then((bool? leave) {
        if (leave == true && mounted) {
          ref.read(sessionControllerProvider.notifier).reset();
          context.go('/');
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SessionControllerState> state = ref.watch(
      sessionControllerProvider,
    );

    ref.listen<AsyncValue<SessionControllerState>>(sessionControllerProvider, (
      AsyncValue<SessionControllerState>? prev,
      AsyncValue<SessionControllerState> next,
    ) {
      final SessionControllerState? data = next.value;
      if (data is ActiveSession && data.completed && !_navigated) {
        _navigated = true;
        final SessionResult? result = ref
            .read(sessionControllerProvider.notifier)
            .toResult();
        if (result != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/session/result', extra: result);
          });
        }
      }
    });

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object e, StackTrace? st) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.modeIqChallenge)),
        body: AppErrorState(
          message: context.l10n.sessionNotAvailable,
          onRetry: () => ref.read(sessionControllerProvider.notifier).reset(),
        ),
      ),
      data: (SessionControllerState controllerState) {
        if (controllerState is! ActiveSession) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.modeIqChallenge)),
            body: AppEmptyState(
              message: context.l10n.sessionNotAvailable,
              actionLabel: context.l10n.sessionBackHome,
              onAction: () => context.go('/'),
            ),
          );
        }
        return _buildActive(controllerState);
      },
    );
  }

  Widget _buildActive(ActiveSession session) {
    final int index = session.currentIndex;
    final int total = session.plan.items.length;
    final QuestionItem item = session.currentItem;
    final AnswerEvaluation? evaluation = session.currentEvaluation;
    final PlayerAnswer? submission = session.currentSubmission;
    final bool answered = evaluation != null;

    // Reset transient selection when advancing to a new question.
    if (!answered && _activeIndex != index) {
      _activeIndex = index;
      _answer = null;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _confirmAbandon();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.l10n.sessionQuestionOf} ${index + 1} / $total',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmAbandon,
            tooltip: context.l10n.sessionAbandonTitle,
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: AppProgressBar(
                value: index / total,
                label: '${context.l10n.sessionAccuracy} · ${index + 1}/$total',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  _PromptCard(item: item),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuestion(item, submission, evaluation),
                  if (answered) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _FeedbackCard(item: item, evaluation: evaluation),
                  ],
                ],
              ),
            ),
            _ActionBar(
              answered: answered,
              canSubmit: _answer != null,
              onSubmit: () {
                if (_answer == null) return;
                final settings = ref.read(appSettingsProvider).value;
                unawaited(
                  const AppFeedback().answerSubmitted(
                    haptics: settings?.hapticsEnabled ?? false,
                    sound: settings?.soundEnabled ?? false,
                  ),
                );
                ref.read(sessionControllerProvider.notifier).submit(_answer!);
              },
              onContinue: () {
                final int next = index + 1;
                ref.read(sessionControllerProvider.notifier).continueNext();
                if (mounted) {
                  setState(() {
                    _activeIndex = next;
                    _answer = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(
    QuestionItem item,
    PlayerAnswer? submission,
    AnswerEvaluation? evaluation,
  ) {
    if (item is MultipleChoiceItem) {
      return MultipleChoiceQuestionWidget(
        key: ValueKey<String>(item.id),
        item: item,
        submission: submission,
        evaluation: evaluation,
        onChanged: _onAnswerChanged,
      );
    }
    if (item is EqScenarioItem) {
      return EqScenarioQuestionWidget(
        key: ValueKey<String>(item.id),
        item: item,
        submission: submission,
        evaluation: evaluation,
        onChanged: _onAnswerChanged,
      );
    }
    if (item is PuzzleItem) {
      if (item.contentType == ContentType.memorySequence) {
        return MemorySequenceQuestionWidget(
          key: ValueKey<String>(item.id),
          item: item,
          submission: submission,
          evaluation: evaluation,
          onChanged: _onAnswerChanged,
        );
      }
      if (item.contentType == ContentType.reorderSequence) {
        return ReorderSequenceQuestionWidget(
          key: ValueKey<String>(item.id),
          item: item,
          submission: submission,
          evaluation: evaluation,
          onChanged: _onAnswerChanged,
        );
      }
      if (item.contentType == ContentType.visualPattern ||
          item.contentType == ContentType.oddOneOut) {
        return SymbolChoiceQuestionWidget(
          key: ValueKey<String>(item.id),
          item: item,
          submission: submission,
          evaluation: evaluation,
          onChanged: _onAnswerChanged,
        );
      }
      if (item.contentType == ContentType.matchingPairs) {
        return MatchingPairsQuestionWidget(
          key: ValueKey<String>(item.id),
          item: item,
          submission: submission,
          evaluation: evaluation,
          onChanged: _onAnswerChanged,
        );
      }
    }
    return const AppErrorState(message: 'Unsupported question type.');
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.item});

  final QuestionItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QuestionItem promptItem = item;
    final EqScenarioItem? eqItem = promptItem is EqScenarioItem
        ? promptItem
        : null;
    final List<Widget> columnChildren = <Widget>[
      if (eqItem != null && eqItem.scenarioContext.isNotEmpty) ...<Widget>[
        Text(
          context.l10n.sessionEqScenarioContext,
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(eqItem.scenarioContext, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.sm),
      ],
      if (item.instructions != null) ...<Widget>[
        Text(item.instructions!, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
      ],
      Text(item.prompt, style: theme.textTheme.titleLarge),
      if (item.hint != null) ...<Widget>[
        const SizedBox(height: AppSpacing.sm),
        _HintTile(hint: item.hint!),
      ],
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}

class _HintTile extends StatelessWidget {
  const _HintTile({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(context.l10n.sessionHint, style: AppTypography.bodySecondary),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(hint, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.item, required this.evaluation});

  final QuestionItem item;
  final AnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String heading = context.l10n.sessionExplanation;
    String body = item.explanation ?? evaluation.feedback ?? '';

    if (item is EqScenarioItem) {
      heading = context.l10n.sessionEqReflection;
      final EqScenarioItem eq = item as EqScenarioItem;
      final StringBuffer buffer = StringBuffer();
      if (evaluation.feedback != null && evaluation.feedback!.isNotEmpty) {
        buffer.write(evaluation.feedback);
      }
      if (eq.followUpReflection != null && eq.followUpReflection!.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('\n\n');
        buffer.write(
          '${context.l10n.sessionEqFollowUp}\n${eq.followUpReflection}',
        );
      }
      body = buffer.toString();
    }

    if (body.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(heading, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.answered,
    required this.canSubmit,
    required this.onSubmit,
    required this.onContinue,
  });

  final bool answered;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.elevatedSurface)),
      ),
      child: answered
          ? AppButton(
              label: context.l10n.sessionContinue,
              onPressed: onContinue,
              fullWidth: true,
            )
          : AppButton(
              label: context.l10n.sessionSubmit,
              onPressed: canSubmit ? onSubmit : null,
              fullWidth: true,
            ),
    );
  }
}
