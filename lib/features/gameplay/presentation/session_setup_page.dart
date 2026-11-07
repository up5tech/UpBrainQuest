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
import 'package:up_brain_quest/core/widgets/app_error_state.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/selection_error.dart';
import 'package:up_brain_quest/domain/session/session_builder.dart';
import 'package:up_brain_quest/domain/session/session_request.dart';
import 'package:up_brain_quest/features/gameplay/application/session_controller.dart';

/// Pre-session screen: explains the mode, question count, and that the mode is
/// untimed (PLAN §3.1, Phase 3 task 7).
///
/// IQ Challenge (Phase 3) and EQ Challenge (Phase 4) are playable; other modes
/// route here and are told they are not available yet (honest UI, PLAN §14.12).
class SessionSetupPage extends ConsumerStatefulWidget {
  const SessionSetupPage({required this.modeKey, super.key});

  final String modeKey;

  @override
  ConsumerState<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends ConsumerState<SessionSetupPage> {
  bool _starting = false;
  String? _error;

  Future<void> _start(
    GameMode mode,
    ContentBank bank,
    int count,
    String packVersion,
  ) async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final List<String> recent = await _recentQuestionIds(mode);
      final int? seed = mode == GameMode.dailyChallenge
          ? const DailyChallengeSelector().seedFor(
              localDate: localDateKey(DateTime.now()),
              contentVersion: packVersion,
            )
          : null;
      ref
          .read(sessionControllerProvider.notifier)
          .start(
            request: SessionRequest(
              mode: mode,
              count: count,
              contentPackVersion: packVersion,
              recentQuestionIds: recent,
              seed: seed,
            ),
            bank: bank,
          );
      if (mounted) context.go('/session/play');
    } on QuestionSelectionFailure {
      if (mounted) {
        setState(() {
          _error = mode == GameMode.quickQuest
              ? context.l10n.sessionQuickQuestMixUnavailable
              : context.l10n.sessionNoContent;
        });
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Recent question IDs for replay avoidance. Daily Challenge deliberately
  /// ignores history so its selection stays deterministic per date.
  Future<List<String>> _recentQuestionIds(GameMode mode) async {
    if (mode == GameMode.dailyChallenge) return const <String>[];
    try {
      final SessionHistoryRepository repository = await ref.read(
        sessionHistoryRepositoryProvider.future,
      );
      return await repository.recentQuestionIds();
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameMode? mode = GameModeX.tryParse(widget.modeKey);
    final bool supported =
        mode == GameMode.iqChallenge ||
        mode == GameMode.eqChallenge ||
        mode == GameMode.quickQuest ||
        mode == GameMode.dailyChallenge;
    if (!supported) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.exploreTitle)),
        body: AppErrorState(
          message: context.l10n.sessionNotAvailable,
          onRetry: () => context.go('/'),
        ),
      );
    }

    final String title = switch (mode) {
      GameMode.quickQuest => context.l10n.modeQuickQuest,
      GameMode.eqChallenge => context.l10n.modeEqChallenge,
      GameMode.dailyChallenge => context.l10n.modeDailyChallenge,
      _ => context.l10n.modeIqChallenge,
    };
    final String description = switch (mode) {
      GameMode.quickQuest => context.l10n.modeQuickQuestDesc,
      GameMode.eqChallenge => context.l10n.modeEqChallengeDesc,
      GameMode.dailyChallenge => context.l10n.modeDailyChallengeDesc,
      _ => context.l10n.modeIqChallengeDesc,
    };

    final AsyncValue<ContentLoadResult> content = ref.watch(contentProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace? st) => AppErrorState(
          message: context.l10n.sessionNoContent,
          onRetry: () => ref.refresh(contentProvider),
        ),
        data: (ContentLoadResult result) {
          if (result is! ContentLoadSuccess) {
            return AppErrorState(message: context.l10n.sessionNoContent);
          }
          final ContentBank bank = result.bank;
          final int available = const SessionBuilder().candidateCount(
            SessionRequest(mode: mode!, count: 1),
            bank,
          );
          if (available == 0) {
            return AppErrorState(message: context.l10n.sessionNoContent);
          }
          final int count = switch (mode) {
            GameMode.quickQuest => 10,
            GameMode.dailyChallenge => DailyChallengeSelector.questionCount,
            _ => available < 10 ? available : 10,
          };
          return _body(
            mode,
            bank,
            count,
            bank.manifest.contentPackVersion,
            title,
            description,
          );
        },
      ),
    );
  }

  Widget _body(
    GameMode mode,
    ContentBank bank,
    int count,
    String packVersion,
    String title,
    String description,
  ) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        AppCard(
          gradient: AppGradients.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Dark on-accent copy keeps AA contrast on the violet gradient.
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColors.textOnAccent,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('$count questions', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.sessionUntimedNote,
          style: AppTypography.bodySecondary,
        ),
        if (mode == GameMode.dailyChallenge) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(context.l10n.dailyLocalNote, style: AppTypography.bodySecondary),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (_error != null) ...<Widget>[
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          label: _starting ? 'Starting…' : context.l10n.sessionStart,
          onPressed: _starting
              ? null
              : () => _start(mode, bank, count, packVersion),
          fullWidth: true,
        ),
      ],
    );
  }
}
