/// Centralized, localization-ready user-facing strings for UpBrainQuest.
///
/// All UI copy lives here rather than scattered across widgets (PLAN §9.1,
/// Phase 1 task 7). A single locale (`en`) ships in this milestone; the
/// structure is ready for additional locales without changing call sites.
/// When a second locale is added, migrate these constants into per-locale
/// resource files and wire a [LocalizationsDelegate] (see PLAN §8.3 / §9.2).
library;

import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';

abstract final class AppStrings {
  const AppStrings._();

  static const String appName = 'UpBrainQuest';

  // Navigation -------------------------------------------------------------
  static const String navHome = 'Home';
  static const String navExplore = 'Explore';
  static const String navProgress = 'Progress';
  static const String navSettings = 'Settings';

  // Home -------------------------------------------------------------------
  static const String homeGreeting = 'Train your mind, one quest at a time';
  static const String homeStartQuickQuest = 'Start Quick Quest';
  static const String homeStartIqChallenge = 'Start IQ Challenge';
  static const String homeProgressSummary = 'Your progress';
  static const String homeNoProgress =
      'No challenges completed yet. Your results will appear here.';
  static const String comingSoon = 'Coming soon';
  static const String notAvailableYet = 'This mode is not available yet.';

  // Explore ----------------------------------------------------------------
  static const String exploreTitle = 'Explore modes';
  static const String exploreSubtitle =
      'Choose a challenge type. Difficulty and length selection arrive in a '
      'later phase.';

  // Progress ---------------------------------------------------------------
  static const String progressTitle = 'Progress';
  static const String progressEmpty =
      'No sessions yet. Complete a challenge to see your history here.';

  // Settings ---------------------------------------------------------------
  static const String settingsTitle = 'Settings';
  static const String settingsPreferences = 'Preferences';
  static const String settingReducedMotion = 'Reduced motion';
  static const String settingReducedMotionHint =
      'Minimise animations across the app.';
  static const String settingSound = 'Sound effects';
  static const String settingHaptics = 'Haptics';
  static const String settingAbout = 'About & score disclaimer';
  static const String settingsLoadError = 'Unable to load settings.';

  // About / disclaimer -----------------------------------------------------
  static const String aboutTitle = 'About UpBrainQuest';
  static const String aboutClose = 'Close';
  static const String aboutVersion = 'Version';
  static const String aboutLicenses = 'Licenses';
  static const String aboutOffline =
      'Fully offline. No account, no network, no analytics, and no ads. All '
      'content and progress stay on this device.';
  static const String aboutDisclaimer =
      'UpBrainQuest scores summarize your performance on these game '
      'challenges. They are not standardized IQ scores, a clinical EQ '
      'assessment, a diagnosis, or a validated measurement of intelligence '
      'or emotional ability. Results can vary with familiarity, attention, '
      'context, language, and the questions included in a session.';

  // Game modes -------------------------------------------------------------
  static const String modeQuickQuest = 'Quick Quest';
  static const String modeQuickQuestDesc =
      'A balanced mix of reasoning, memory, and EQ scenarios.';
  static const String modeIqChallenge = 'IQ Challenge';
  static const String modeIqChallengeDesc =
      'Reasoning puzzles: sequences, patterns, and logic.';
  static const String modePuzzleSprint = 'Puzzle Sprint';
  static const String modePuzzleSprintDesc =
      'Short interactive puzzle mechanics.';
  static const String modeEqChallenge = 'EQ Challenge';
  static const String modeEqChallengeDesc =
      'Scenario choices that practise reflection and communication.';

  // Gameplay (Phase 3) ---------------------------------------------------
  static const String sessionUntimedNote =
      'This mode is untimed — take your time to think.';
  static const String sessionTimedNote =
      'A timed variant is not available in this build.';
  static const String sessionStart = 'Start session';
  static const String sessionSubmit = 'Submit';
  static const String sessionContinue = 'Continue';
  static const String sessionCorrect = 'Correct';
  static const String sessionIncorrect = 'Not quite';
  static const String sessionExplanation = 'Explanation';
  static const String sessionHint = 'Hint';
  static const String sessionResultTitle = 'Session complete';
  static const String sessionIqScoreLabel = 'IQ Challenge Score';
  static const String sessionScoreDisclaimer =
      'This is an in-game score based on the questions in this session. It is '
      'not a standardized IQ result, a clinical measure, or a diagnosis.';
  static const String sessionAccuracy = 'Accuracy';
  static const String sessionReview = 'Review answers';
  static const String sessionPlayAgain = 'Play again';
  static const String sessionBackHome = 'Back to Home';
  static const String sessionAbandonTitle = 'Leave this session?';
  static const String sessionAbandonBody =
      'Your progress in this session will be lost if you leave now.';
  static const String sessionAbandonConfirm = 'Leave';
  static const String sessionAbandonCancel = 'Keep playing';
  static const String sessionNotAvailable = 'This mode is not available yet.';
  static const String sessionNoContent =
      'There are not enough questions available for this mode yet.';
  static const String sessionMemoryReady = 'I memorised it';
  static const String sessionMemoryRecall = 'Reproduce the sequence';
  static const String sessionMemoryClear = 'Clear';
  static const String sessionReorderHint =
      'Drag the tiles into the correct order.';
  // Used as "Question X of Y".
  static const String sessionQuestionOf = 'Question';

  // Gameplay (Phase 4 — EQ) ----------------------------------------------
  static const String sessionEqScenarioContext = 'Situation';
  static const String sessionEqReflection = 'Reflection';
  static const String sessionEqFollowUp = 'Reflect on this';
  static const String sessionYourResponse = 'Your response';
  static const String sessionEqScoreLabel = 'EQ Practice Score';
  static const String sessionEqScoreDisclaimer =
      'This is an in-game practice score based on the rubrics in this session. '
      'It is not a clinical EQ assessment, a diagnosis, or a validated measure '
      'of emotional ability.';
  static const String sessionEqDimensionsTitle = 'Where you focused';
  static const String sessionEqNoScore = 'Practice score not available yet';
  static const String sessionEqReviewHeading = 'Your reflection';

  // Results & review (Phase 5) -------------------------------------------
  static const String sessionYourAnswer = 'Your answer';
  static const String sessionCorrectAnswer = 'Correct answer';
  static const String sessionNotAnswered = 'Not answered';
  static const String sessionRubricSummary = 'Rubric';
  static const String sessionResultStatus = 'Result';
  static const String sessionQuestionsCompleted = 'Questions completed';
  static const String sessionIncompleteNote =
      'Some questions were left unanswered.';
  static const String sessionResultError =
      'This result could not be displayed.';
  static const String sessionQuickQuestMixUnavailable =
      'Not enough questions for a balanced Quick Quest yet.';

  // Persistence & history (Phase 6) --------------------------------------
  static const String sessionSaving = 'Saving to history…';
  static const String sessionSaved = 'Saved to your history';
  static const String sessionSaveFailed = 'This session could not be saved.';
  static const String sessionSaveRetry = 'Retry';
  static const String progressLoadError = 'Could not load your progress.';
  static const String progressSessionsCompleted = 'Sessions completed';
  static const String progressBestIq = 'Best IQ Challenge Score';
  static const String progressBestEq = 'Best EQ Practice Score';
  static const String progressRecentTitle = 'Recent game performance';
  static const String homeProgressError = 'Could not load your progress.';
  static const String resetLocalData = 'Reset local data';
  static const String resetLocalDataBody =
      'This permanently deletes your session history, achievements, and local '
      'streaks on this device. Your preferences are kept.';
  static const String resetLocalDataConfirm = 'Delete';
  static const String resetLocalDataCancel = 'Cancel';
  static const String resetLocalDataDone = 'Local history cleared.';
  static const String resetLocalDataFailed = 'Could not clear local data.';
  static const String modeDailyChallenge = 'Daily Challenge';

  // Achievements, daily challenge & streaks (Phase 7) --------------------
  static const String modeDailyChallengeDesc =
      'A local 5-question challenge chosen by today’s date.';
  static const String dailyDoneToday = 'Done today';
  static const String dailyLocalNote =
      'Generated on this device — not a global competition.';
  static const String achievementsTitle = 'Achievements';
  static const String achievementUnlocked = 'Unlocked';
  static const String achievementsLoadError = 'Could not load achievements.';
  static const String streakDaySuffix = 'day streak';
  static const String streakNone = 'No local streak yet';
  static const String streakLocalNote =
      'Local to this device — not server-verified.';
  static const String achievementFirstQuestTitle = 'First Quest';
  static const String achievementFirstQuestDesc =
      'Complete your first session.';
  static const String achievementFiveQuestsTitle = 'Five Completed Quests';
  static const String achievementFiveQuestsDesc = 'Complete five sessions.';
  static const String achievementReasoningTitle = 'Reasoning Explorer';
  static const String achievementReasoningDesc =
      'Finish three reasoning sessions.';
  static const String achievementReflectionTitle = 'Reflection Explorer';
  static const String achievementReflectionDesc = 'Finish three EQ sessions.';
  static const String achievementConsistentTitle = 'Consistent Player';
  static const String achievementConsistentDesc =
      'Play on three days in a row.';

  // Polish, accessibility & localization readiness (Phase 8) -------------
  static const String retry = 'Retry';
  static const String sessionMemoryDelete = 'Delete';
  static const String sessionCorrectSequence = 'Correct sequence';
  static const String sessionYourSequence = 'Your sequence';
  static const String sessionCorrectOrder = 'Correct order';

  /// Formats "correct / total correct" for summaries.
  static String correctOutOf(int correct, int total) =>
      '$correct / $total correct';

  /// Formats "value / total" for progress summaries.
  static String fractionOf(int value, int total) => '$value / $total';

  /// Localized title for an [id].
  static String achievementTitle(AchievementId id) => switch (id) {
    AchievementId.firstQuest => achievementFirstQuestTitle,
    AchievementId.fiveQuests => achievementFiveQuestsTitle,
    AchievementId.reasoningExplorer => achievementReasoningTitle,
    AchievementId.reflectionExplorer => achievementReflectionTitle,
    AchievementId.consistentPlayer => achievementConsistentTitle,
  };

  /// Localized description for an [id].
  static String achievementDescription(AchievementId id) => switch (id) {
    AchievementId.firstQuest => achievementFirstQuestDesc,
    AchievementId.fiveQuests => achievementFiveQuestsDesc,
    AchievementId.reasoningExplorer => achievementReasoningDesc,
    AchievementId.reflectionExplorer => achievementReflectionDesc,
    AchievementId.consistentPlayer => achievementConsistentDesc,
  };

  // EQ rubric dimension labels (PLAN §4.6) -------------------------------
  static const String eqDimEmotionAwareness = 'Emotion Awareness';
  static const String eqDimSelfRegulation = 'Self-Regulation';
  static const String eqDimPerspectiveTaking = 'Perspective Taking';
  static const String eqDimConstructiveCommunication =
      'Constructive Communication';
  static const String eqDimBoundariesAndAgency = 'Boundaries & Agency';

  /// Localized label for an EQ rubric [dimension].
  static String eqDimensionLabel(EqDimension dimension) => switch (dimension) {
    EqDimension.emotionAwareness => eqDimEmotionAwareness,
    EqDimension.selfRegulation => eqDimSelfRegulation,
    EqDimension.perspectiveTaking => eqDimPerspectiveTaking,
    EqDimension.constructiveCommunication => eqDimConstructiveCommunication,
    EqDimension.boundariesAndAgency => eqDimBoundariesAndAgency,
  };

  /// Localized label for a [mode].
  static String gameModeLabel(GameMode mode) => switch (mode) {
    GameMode.quickQuest => modeQuickQuest,
    GameMode.iqChallenge => modeIqChallenge,
    GameMode.eqChallenge => modeEqChallenge,
    GameMode.puzzleSprint => modePuzzleSprint,
    GameMode.dailyChallenge => modeDailyChallenge,
  };
}
