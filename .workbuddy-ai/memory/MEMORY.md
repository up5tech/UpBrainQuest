# UpBrainQuest — Long-Term Project Notes

Durable facts and conventions for UpBrainQuest. Dated work logs live in
`YYYY-MM-DD.md` alongside this file.

## Project identity

UpBrainQuest is a **fully offline, single-player IQ & EQ Challenge** game for Android
and iOS, built with Flutter. Reasoning puzzles, memory/pattern challenges, and EQ
social scenarios in short replayable sessions.

- **Package id:** `com.upbrainquest.up_brain_quest`
- **Dart package:** `up_brain_quest`
- **Product plan:** `PLAN.md` (source of truth for product intent)
- **Engineering contract:** `AGENTS.md` (source of truth for engineering practice)

## Non-negotiables

No backend, no runtime network, no analytics/crash reporting/ads, no remote assets,
no accounts. All content is bundled JSON in `assets/content/`. These are hard
constraints from PLAN §1.2, §7.4, §10 — never trade them away.

## Toolchain

- Flutter **3.47.8** stable at `/Users/up5techjacky/Documents/sdk/flutter`,
  Dart **3.13.7**. Already on `PATH`.
- Android: minSdk 24, compile/target 36, NDK 28.2.13676358, Java 17, AGP 9.1.0,
  Gradle 9.3.1. iOS deployment target **15.0**. Xcode 26.1.1, CocoaPods 1.16.2.
- Runtime target for verification: **iPhone 17 Pro simulator**,
  UDID `F3C58321-6F34-4505-B1A5-8FA98E8AB880`.

## Two environment gotchas (both bite repeatedly)

1. **System HTTP proxy breaks `flutter test` and `flutter build`.** `HTTP_PROXY` is
   `127.0.0.1:51520` with no `NO_PROXY`. The test runner cannot open its local
   WebSocket → `WebSocketException: Invalid WebSocket upgrade request`.
   Always prefix with `NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1"`.
2. **Android toolchain is incomplete** — `cmdline-tools` missing, SDK licences not
   accepted. `flutter build apk --debug` succeeds; no emulator image is available.

## Dependency decisions (settled — do not churn)

- **`drift_flutter` is deliberately NOT used.** It pulls `sqlite3_flutter_libs` and
  `sqlcipher_flutter_libs`, both `+eol` and obsolete since `package:sqlite3` 3.x.
  Use `drift` + `sqlite3` + `path_provider` directly. SQLite is bundled via Dart
  build hooks (verified: `sqlite3.framework` ships in the iOS app).
- **`custom_lint` is deliberately NOT used.** It conflicts with `drift_dev` 2.35.x on
  `analyzer`/`dart_style` ranges. `riverpod_lint` 3.x is an analysis-server plugin,
  enabled via the top-level `plugins:` mapping in `analysis_options.yaml`.
- `sqlite3: ^3.8.0` is pinned directly — transitive resolution otherwise settles on 3.5.2.

Current versions: flutter_riverpod 3.4.3, go_router 18.1.1, drift 2.35.3,
drift_dev 2.35.2, shared_preferences 2.5.6, intl 0.20.3, json_serializable 6.15.2,
build_runner 2.17.1, riverpod_lint 3.1.9, analyzer 14.6.0.

## Conventions

- **Feature-first structure, MVVM separation.** `lib/app`, `lib/features`,
  `lib/domain`, `lib/data`, `lib/core`. Dependency direction:
  Presentation → Domain ← Data.
- **`lib/domain/` is pure Dart.** No Flutter widgets, no SQLite, no platform APIs.
- **Widgets never touch the database** — they go through view models and providers.
- **Randomness and clocks are injectable** so session building is deterministic.
- **Design tokens only.** All colours/spacing/radii/type come from `lib/core/theme/`
  (`AppColors`, `AppSpacing`, `AppRadii`, `AppGradients`, `AppTheme`). Literals like
  `Color(0xFF...)` in widget code are a bug.
- **Dark theme only** until the full token set supports a light one (PLAN §8.2).
- **Honest UI** — never present placeholder data as real progress (PLAN §14.12).
- **Scores stay non-clinical** — 0–100 in-game figures, never a standardized IQ
  value, percentile, or diagnosis (PLAN §4).
- **Migrations, never destructive resets** — player progress must survive updates.
- **Generated `*.g.dart` files are committed.** Never hand-edit them.

## Gotcha worth remembering

`drift_dev` reports `type 'FunctionExpressionInvocationImpl' is not a subtype of type
'MethodInvocation' in type cast` when a column expression is malformed — most often an
extra `()` such as `dateTime()()();` instead of `dateTime()();`. Drift 2.x syntax needs
the trailing call: `text()()`, `text().withDefault(const Constant(''))()`,
`dateTime()()`.

## Skills are PROJECT-scoped, canonical in `.agents/skills/` (settled)

The user explicitly wants skills installed **into the project, not globally**, so the
skill set travels with the checkout and cannot drift between machines.

**Canonical location: `.agents/skills/`** — real files live here and nowhere else.
`flutter-dev` (15 files), `flutter-master` (13), `flutter-dev-skill` (16) — 44 files, 392K.

**Every other agent directory holds relative symlinks back to it**
(`../../.agents/skills/<name>`), 24 links total:

| Dir | Serves |
| --- | --- |
| `.agents/skills/` | amp, cline, codex, cursor, droid, fx, gemini-cli, github-copilot, kilo, kimi-code-cli, opencode, pi, warp, zed |
| `.claude/skills/` | Claude Code |
| `.windsurf/skills/` | Windsurf |
| `.trae/skills/` | Trae |
| `.qoder/skills/` | Qoder |
| `.minimax/skills/` | MiniMax Code |
| `.codebuddy/skills/` | CodeBuddy |
| `.kiro/skills/` | Kiro CLI |
| `.workbuddy-ai/skills/` | WorkBuddy |

**Never put a real copy inside a symlinked directory** — the versions would drift.
Add or update skills in `.agents/skills/` only.

### Two mistakes already made here — do not repeat

1. **`.agents/skills/` is the shared project path for most agents.** It is not optional
   or redundant with `.claude/skills/`. Leaving it out means 14 agents see nothing.
2. **`.gemini/skills/` is Gemini CLI's GLOBAL path, not its project path.** In a project,
   Gemini CLI reads `.agents/skills/`. A `.gemini/` directory in the repo is dead weight.

The authoritative path table ships with the `skills` CLI:
`~/.npm/_npx/*/node_modules/skills/docs/agents.md`.

### Global state

`~/.workbuddy-ai/skills/flutter-dev` still exists globally and was deliberately left
alone: `UpTowerDefense`, `crmhub-mobile`, and `penguin_nemt_app` are also Flutter
projects that may rely on it. Check those before removing it.

Global copies added earlier were parked in
`~/.workbuddy-ai/backups/skills-global-removed-20261027` (11 dirs, reversible).

**Skill install path used by the built-in tool is unreliable:** `search_and_install_skills`
returns HTTP 404. Use the SkillHub registry instead —
`https://lightmake.site/api/v1/search?q=<query>` and
`https://lightmake.site/api/v1/download?slug=<slug>`. Install into
`.agents/skills/` in the project, never globally.

## Agent entrypoint files

`AGENTS.md` is the source of truth. `CLAUDE.md` and `GEMINI.md` are thin pointers to it,
because Claude Code and Gemini CLI do not read `AGENTS.md` by name. Keep the pointers
short — never duplicate the rules, or they will drift.

## Workflow

One phase at a time — do not start the next phase while the current one has failing
acceptance criteria.

**Phases 0–9 are complete and verified** (Flutter 3.47.8 / Dart 3.13.7):
`flutter analyze` → "No issues found!" (exit 0), `flutter test` → 109/109 passed,
`flutter build apk --release` and `flutter build ios --release --no-codesign` succeed.

### Verified baseline commands

Always prefix with the proxy fix; `flutter analyze` here treats **info** lints as
fatal, so run `dart format lib test` (and `dart fix --apply` when needed) first.

```
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter pub get
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" dart format lib test
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter analyze
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter test
```

### Model facts settled in Phase 4

- `AppTypography` lives in `lib/core/theme/app_typography.dart` (moved out of
  `app_theme.dart`; the rest of the code already imported it from there).
- `EqScenarioItem` carries `options: List<QuestionOption>` (was missing).
- `AnswerEvaluation` carries `dimensionPossible: Map<EqDimension,int>?` alongside
  `rubricScores` (earned); `EqScoreCalculator` needs both for per-dimension scores.
- `SessionResult` carries both `iqScore` and `eqScore`; `ActiveSession` mirrors both.
- `SettingsRepository([SharedPreferencesAsync?])` is injectable; production passes a
  client, tests inject a fake and never touch the platform.
- `ContentLoader.bundle` is nullable and falls back to `rootBundle`.
- EQ content: 16 draft scenarios, all 5 dimensions, every option has a rubric entry
  (parser rejects an EQ item when an option lacks one).
- The whole repo had never been compiled before Phase 4 — expect more latent issues
  in untouched corners; run the baseline after every phase.

### Model facts settled in Phase 5

- Quick Quest uses `SessionBuilder.quickQuestMix` = `{iq:5, puzzle:2, eq:3}`;
  `SessionRequest.domainMix` overrides it. `_selectMixed` requires every targeted
  domain to be present (else `QuestionSelectionFailure`), rebalances within the same
  domain set, and interleaves domains.
- **No Quest Completion Score** is persisted/displayed — intentional (PLAN §4.4).
- `SessionResult.questionCount / answeredCount / isComplete`.
- `SessionResultPage` review shows the exact player response + correct answer or EQ
  rubric summary; entrance fade is skipped under `MediaQuery.disableAnimations` or the
  app reduced-motion setting.
- Test gotchas: `Override` is not exported by `flutter_riverpod` (use an untyped
  `overrides:` list); a lazy `ListView` review needs a tall `tester.view.physicalSize`
  to build below the fold.

### Model facts settled in Phase 6

- DB schema **v2**: `game_sessions` + `question_attempts` (FK cascade, unique
  session+question). `schemaVersion = 2`; `onUpgrade(1→2)` creates only the new tables
  and preserves metadata. Regenerate `app_database.g.dart` with
  `dart run build_runner build`.
- `SessionHistoryRepository` (domain) + `DriftSessionHistoryRepository` (data):
  `saveSession` writes the session + attempts in one transaction; `clearAll` deletes
  attempts then sessions; `progressSummary` aggregates best IQ/EQ.
- Providers: `sessionHistoryRepositoryProvider`, `sessionHistoryProvider`,
  `progressSummaryProvider`.
- The result page saves once on completion and shows saving/saved/failed + Retry;
  a failed save is never presented as durable.
- Home and Progress read the DB, so app-boot widget tests must override
  `appDatabaseProvider` with an in-memory DB (`test/support/test_app.dart`).
- Achievements/daily_activity tables are deferred to Phase 7.

### Model facts settled in Phase 7

- Schema **v3**: `achievements` + `daily_activity`; `onUpgrade` adds them without
  touching prior data.
- `AchievementCatalog` (5 achievements) + `AchievementEngine` are pure; the repository
  unlocks **exactly once** (never re-dates `unlockedAt`).
- `StreakCalculator` and `DailyChallengeSelector` are pure and date-injectable; the
  daily seed is an FNV-1a hash of `localDate|contentVersion`, and daily selection must
  **ignore recent question IDs** to stay deterministic.
- `SessionCompletionService` = save → daily activity → achievement evaluate/persist.
  Providers: `progressRepositoryProvider`, `sessionCompletionServiceProvider`,
  `achievementsProvider`, `dailyStatusProvider`, `streakProvider`.
- Replay avoidance: `SessionHistoryRepository.recentQuestionIds()` (last 2 sessions) is
  passed by the setup page for non-daily modes.
- Gotcha: Drift reads `DateTime` back as local time for the same instant; compare
  `.toUtc()` in tests.

### Model facts settled in Phase 8

- `UpBrainQuestApp` is a `ConsumerWidget` that folds the reduced-motion setting into
  `MediaQuery.disableAnimations`; `AppFeedback` wires haptics/system sound to the
  settings toggles.
- `AppColors.textOnAccent` is `#05070F` to clear WCAG AA 4.5:1 on the violet primary.
- Accessibility patterns: `Semantics` on `ModeCard`/`AppProgressBar`, `MergeSemantics`
  on composite cards; `NavigationBar` height scales with text; empty/error states
  scroll.
- Puzzle content is 6 items (manifest `puzzle: 6`); `docs/content-qa.md` holds the
  content QA, accessibility, and localization-readiness notes.
- Tests: `text_scaling_test`, `theme_contrast_test`; total suite 102.





