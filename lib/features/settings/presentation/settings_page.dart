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
/// Reset-local-data and full language selection are deferred to later phases.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppSettings> settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Text(
            AppStrings.settingsPreferences,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          settings.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, _) => const Text(AppStrings.settingsLoadError),
            data: (AppSettings data) => Column(
              children: <Widget>[
                SwitchListTile(
                  title: const Text(AppStrings.settingReducedMotion),
                  subtitle: const Text(AppStrings.settingReducedMotionHint),
                  value: data.reducedMotion,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setReducedMotion(value),
                ),
                SwitchListTile(
                  title: const Text(AppStrings.settingSound),
                  value: data.soundEnabled,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setSoundEnabled(value),
                ),
                SwitchListTile(
                  title: const Text(AppStrings.settingHaptics),
                  value: data.hapticsEnabled,
                  onChanged: (bool value) async => ref
                      .read(appSettingsProvider.notifier)
                      .setHapticsEnabled(value),
                ),
                ListTile(
                  title: const Text(AppStrings.settingAbout),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
                ListTile(
                  title: const Text(AppStrings.resetLocalData),
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

  void _showAbout(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text(AppStrings.aboutTitle),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${AppStrings.aboutVersion}: ${AppInfo.version}'),
                SizedBox(height: AppSpacing.sm),
                Text(AppStrings.aboutOffline),
                SizedBox(height: AppSpacing.sm),
                Text(AppStrings.aboutDisclaimer),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => showLicensePage(
                context: dialogContext,
                applicationName: AppStrings.appName,
                applicationVersion: AppInfo.version,
              ),
              child: const Text(AppStrings.aboutLicenses),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.aboutClose),
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
        title: const Text(AppStrings.resetLocalData),
        content: const Text(AppStrings.resetLocalDataBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.resetLocalDataCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.resetLocalDataConfirm),
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
          const SnackBar(content: Text(AppStrings.resetLocalDataDone)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.resetLocalDataFailed)),
        );
      }
    }
  }
}
