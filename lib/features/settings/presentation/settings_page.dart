import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/app_info.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/progress/progress_repository.dart';

/// Settings screen.
///
/// Holds real, persisted UI preferences (PLAN §7.1). The reduced-motion flag is
/// the preference animation components must read (PLAN §8.4, Phase 1 task 8).
/// Language selection is offered because both UI copy and question content are
/// complete for every bundled language.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppSettings> settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Text(
            context.l10n.settingsPreferences,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          settings.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, _) => Text(context.l10n.settingsLoadError),
            data: (AppSettings data) => Column(
              children: <Widget>[
                SwitchListTile(
                  title: Text(context.l10n.settingReducedMotion),
                  subtitle: Text(context.l10n.settingReducedMotionHint),
                  value: data.reducedMotion,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setReducedMotion(value),
                ),
                SwitchListTile(
                  title: Text(context.l10n.settingSound),
                  value: data.soundEnabled,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setSoundEnabled(value),
                ),
                SwitchListTile(
                  title: Text(context.l10n.settingHaptics),
                  value: data.hapticsEnabled,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setHapticsEnabled(value),
                ),
                // The selector is shown because both UI copy and question
                // content are complete for every bundled language (PLAN
                // Phase 8 task 7 forbids a non-functional language switch).
                ListTile(
                  title: Text(context.l10n.settingLanguage),
                  subtitle: Text(context.l10n.settingLanguageHint),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(_languageName(context.l10n, data.languageCode)),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => unawaited(_pickLanguage(context, ref, data)),
                ),
                ListTile(
                  title: Text(context.l10n.settingAbout),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
                ListTile(
                  title: Text(context.l10n.resetLocalData),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () => unawaited(_confirmReset(context, ref)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display name for a language code, shown in that language so people can
  /// find their own language even when the UI is currently in another one.
  String _languageName(AppLocalizations l10n, String code) => switch (code) {
    AppLanguages.vietnamese => l10n.languageVietnamese,
    _ => l10n.languageEnglish,
  };

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final String? chosen = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => SimpleDialog(
        title: Text(context.l10n.settingLanguage),
        children: <Widget>[
          RadioGroup<String>(
            groupValue: settings.languageCode,
            onChanged: (String? value) =>
                Navigator.of(dialogContext).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final String code in AppLanguages.supported)
                  RadioListTile<String>(
                    title: Text(_languageName(context.l10n, code)),
                    value: code,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null || chosen == settings.languageCode) return;
    await ref.read(appSettingsProvider.notifier).setLanguageCode(chosen);
  }

  void _showAbout(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(context.l10n.aboutTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${context.l10n.aboutVersion}: ${AppInfo.version}'),
                const SizedBox(height: AppSpacing.sm),
                Text(context.l10n.aboutOffline),
                const SizedBox(height: AppSpacing.sm),
                Text(context.l10n.aboutDisclaimer),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => showLicensePage(
                context: dialogContext,
                applicationName: context.l10n.appName,
                applicationVersion: AppInfo.version,
              ),
              child: Text(context.l10n.aboutLicenses),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.aboutClose),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms and performs a local-history reset (PLAN §7.3).
  ///
  /// The dialog states exactly what is deleted; preferences are kept.
  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.resetLocalData),
        content: Text(context.l10n.resetLocalDataBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.resetLocalDataCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.resetLocalDataConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final SessionHistoryRepository history = await ref.read(
        sessionHistoryRepositoryProvider.future,
      );
      final ProgressRepository progress = await ref.read(
        progressRepositoryProvider.future,
      );
      await history.clearAll();
      await progress.clearAll();
      ref
        ..invalidate(sessionHistoryProvider)
        ..invalidate(progressSummaryProvider)
        ..invalidate(achievementsProvider)
        ..invalidate(dailyStatusProvider)
        ..invalidate(streakProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.resetLocalDataDone)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.resetLocalDataFailed)),
        );
      }
    }
  }
}
