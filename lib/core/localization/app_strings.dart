/// Centralized, localized user-facing strings for UpBrainQuest.
///
/// All UI copy lives in the ARB files under `lib/core/localization/l10n`
/// rather than scattered across widgets (PLAN §9.1). `app_en.arb` is the
/// template; `app_vi.arb` carries the Vietnamese translation. Flutter
/// generates [AppLocalizations] from them (`flutter gen-l10n`, see
/// `l10n.yaml`), and widgets read copy through `context.l10n`.
library;

import 'package:flutter/widgets.dart';

import 'package:up_brain_quest/core/localization/generated/app_localizations.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';

export 'package:up_brain_quest/core/localization/generated/app_localizations.dart';

/// Convenience accessor for the active [AppLocalizations].
extension AppLocalizationsContext on BuildContext {
  /// The strings for the locale resolved by `MaterialApp`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Domain labels derived from localized strings.
///
/// These live here so widgets never switch on achievement ids, EQ dimensions,
/// or game modes themselves, and so a new locale only needs ARB entries.
extension AppLocalizationsLabels on AppLocalizations {
  /// Localized title for an [id].
  String achievementTitle(AchievementId id) => switch (id) {
    AchievementId.firstQuest => achievementFirstQuestTitle,
    AchievementId.fiveQuests => achievementFiveQuestsTitle,
    AchievementId.reasoningExplorer => achievementReasoningTitle,
    AchievementId.reflectionExplorer => achievementReflectionTitle,
    AchievementId.consistentPlayer => achievementConsistentTitle,
  };

  /// Localized description for an [id].
  String achievementDescription(AchievementId id) => switch (id) {
    AchievementId.firstQuest => achievementFirstQuestDesc,
    AchievementId.fiveQuests => achievementFiveQuestsDesc,
    AchievementId.reasoningExplorer => achievementReasoningDesc,
    AchievementId.reflectionExplorer => achievementReflectionDesc,
    AchievementId.consistentPlayer => achievementConsistentDesc,
  };

  /// Localized label for an EQ rubric [dimension].
  String eqDimensionLabel(EqDimension dimension) => switch (dimension) {
    EqDimension.emotionAwareness => eqDimEmotionAwareness,
    EqDimension.selfRegulation => eqDimSelfRegulation,
    EqDimension.perspectiveTaking => eqDimPerspectiveTaking,
    EqDimension.constructiveCommunication => eqDimConstructiveCommunication,
    EqDimension.boundariesAndAgency => eqDimBoundariesAndAgency,
  };

  /// Localized label for a [mode].
  String gameModeLabel(GameMode mode) => switch (mode) {
    GameMode.quickQuest => modeQuickQuest,
    GameMode.iqChallenge => modeIqChallenge,
    GameMode.eqChallenge => modeEqChallenge,
    GameMode.puzzleSprint => modePuzzleSprint,
    GameMode.dailyChallenge => modeDailyChallenge,
  };
}
