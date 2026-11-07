import 'dart:math' show Random;

import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/puzzle_symbols.dart';

/// Matching-pairs puzzle (PLAN §5.10.B).
///
/// The board is generated from [PuzzleItem.expectedAnswer]: every pair id is
/// placed twice and shuffled with a seed derived from the item id, so the same
/// item always lays out the same board in tests while still looking random.
/// The player spends one flip per card reveal and submits the pairs found; the
/// item is correct only when every pair was found inside the authored budget.
class MatchingPairsQuestionWidget extends StatefulWidget {
  const MatchingPairsQuestionWidget({
    required this.item,
    this.submission,
    this.evaluation,
    required this.onChanged,
    super.key,
  });

  final PuzzleItem item;
  final PlayerAnswer? submission;
  final AnswerEvaluation? evaluation;
  final ValueChanged<PlayerAnswer?> onChanged;

  @override
  State<MatchingPairsQuestionWidget> createState() =>
      _MatchingPairsQuestionWidgetState();
}

class _MatchingPairsQuestionWidgetState
    extends State<MatchingPairsQuestionWidget> {
  late final List<String> _board;
  final Set<int> _matched = <int>{};
  final Set<String> _found = <String>{};
  final List<int> _revealed = <int>[];
  int _flips = 0;

  bool get _locked => widget.evaluation != null;

  int get _budget {
    final dynamic raw = widget.item.interactionConfig?['maxFlips'];
    return raw is int && raw > 0 ? raw : defaultPairFlipBudget;
  }

  List<String> get _pairs =>
      widget.item.expectedAnswer.whereType<String>().toList();

  bool get _exhausted => _flips >= _budget;

  bool get _allMatched => _matched.length == _board.length;

  @override
  void initState() {
    super.initState();
    _board = _buildBoard();
    final PlayerAnswer? submission = widget.submission;
    if (submission is PairMatchAnswer && submission.flips >= _budget) {
      _flips = submission.flips;
    }
  }

  List<String> _buildBoard() {
    final List<String> cards = <String>[..._pairs, ..._pairs]
      ..shuffle(Random(_seedFor(widget.item.id)));
    return cards;
  }

  /// Stable 31-based hash so the board is deterministic per item.
  int _seedFor(String id) {
    int hash = 7;
    for (final int unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  void _tap(int index) {
    if (_locked || _allMatched || _exhausted) return;
    if (_matched.contains(index) || _revealed.contains(index)) return;
    if (_revealed.length == 2) _revealed.clear();
    setState(() {
      _revealed.add(index);
      _flips++;
      if (_revealed.length == 2) {
        final String first = _board[_revealed[0]];
        final String second = _board[_revealed[1]];
        if (first == second) {
          _matched
            ..add(_revealed[0])
            ..add(_revealed[1]);
          _found.add(first);
          _revealed.clear();
        }
      }
    });
    _report();
  }

  String _optionText(String id) {
    for (final QuestionOption option in widget.item.options) {
      if (option.id == id) return option.text;
    }
    return id;
  }

  void _report() {
    if (_allMatched || _exhausted) {
      widget.onChanged(
        PairMatchAnswer(
          pairIds: _pairs.where(_found.contains).toList(),
          flips: _flips,
        ),
      );
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(context.l10n.sessionPairsHint, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              context.l10n.sessionPairsFound(_found.length, _pairs.length),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              context.l10n.sessionPairsFlipsLeft(_budget - _flips),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              children: <Widget>[
                for (int i = 0; i < _board.length; i++)
                  _PairCard(
                    symbol: _board[i],
                    label: _optionText(_board[i]),
                    faceUp: _matched.contains(i) || _revealed.contains(i),
                    matched: _matched.contains(i),
                    onTap: () => _tap(i),
                  ),
              ],
            ),
          ),
        ),
        if (_exhausted && !_locked) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.sessionPairsBudgetSpent,
            style: AppTypography.bodySecondary,
          ),
        ],
        if (_locked) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _LockedBanner(
            correct: widget.evaluation?.isCorrect ?? false,
            pairs: _pairs,
            options: widget.item.options,
          ),
        ],
      ],
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({
    required this.symbol,
    required this.label,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  final String symbol;
  final String label;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A matched card is filled with the bright positive colour, so its icon
    // and label need the near-black on-accent text to stay readable.
    final Color foreground = matched
        ? AppColors.textOnAccent
        : AppColors.textPrimary;
    return Semantics(
      button: !faceUp,
      label: faceUp ? label : context.l10n.sessionPairsHiddenCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: matched ? AppColors.positive : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: AppColors.elevatedSurface, width: 2),
          ),
          child: faceUp
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      puzzleSymbolIcon(symbol) ?? Icons.help_outline,
                      color: foreground,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(color: foreground),
                    ),
                  ],
                )
              : const Icon(Icons.question_mark, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner({
    required this.correct,
    required this.pairs,
    required this.options,
  });

  final bool correct;
  final List<String> pairs;
  final List<QuestionOption> options;

  String _text(String id) {
    for (final QuestionOption option in options) {
      if (option.id == id) return option.text;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: correct ? AppColors.positive : AppColors.error,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Text(
            correct
                ? context.l10n.sessionCorrect
                : context.l10n.sessionIncorrect,
            style: AppTypography.title.copyWith(color: AppColors.textOnAccent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${context.l10n.sessionPairsAnswer}: '
          '${pairs.map(_text).join(' · ')}',
          style: AppTypography.body,
        ),
      ],
    );
  }
}
