# UpBrainQuest — Long-Term Project Notes

Durable facts only. Dated work logs live in `YYYY-MM-DD.md` beside this file.

## Identity & hard constraints

Fully offline, single-player IQ & EQ Challenge game (Flutter, Android + iOS).
Package `com.upbrainquest.up_brain_quest`, Dart package `up_brain_quest`.
`PLAN.md` = product intent (wins on product), `AGENTS.md` = engineering contract
(wins on practice). Phases 0–9 complete and verified: `flutter analyze` clean,
`flutter test` 109/109, release APK + iOS builds OK.

No backend, no runtime network, no analytics/ads/crash reporting, no remote assets,
no accounts. All content ships as bundled JSON in `assets/content/{en,vi}/`.

## Toolchain & environment (repeat offenders)

- Flutter 3.47.8 / Dart 3.13.7 at `/Users/up5techjacky/Documents/sdk/flutter`, on PATH.
- **System HTTP proxy breaks `flutter test`/`build`** (`WebSocketException: Invalid
  WebSocket upgrade request`). Always prefix:
  `NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1"`.
- Android toolchain incomplete (no cmdline-tools, licences unaccepted, no emulator).
  Use iPhone 17 Pro simulator UDID `F3C58321-6F34-4505-B1A5-8FA98E8AB880`.
- Android: minSdk 24, compile/target 36, NDK 28.2.13676358, Java 17, AGP 9.1.0,
  Gradle 9.3.1. iOS deployment target 15.0, Xcode 26.1.1, CocoaPods 1.16.2.
- `flutter analyze` treats **info** lints as fatal → run `dart format lib test` first.
  Baseline: `flutter pub get` → `dart format lib test` → `flutter analyze` →
  `flutter test` (all with the NO_PROXY prefix). Regenerate `*.g.dart` with
  `dart run build_runner build`; generated files are committed, never hand-edited.

## Dependency decisions (settled — do not churn)

- **No `drift_flutter`** (pulls obsolete `sqlite3_flutter_libs`/`sqlcipher`); use
  `drift` + `sqlite3` + `path_provider`. SQLite ships via Dart build hooks.
- **No `custom_lint`** (conflicts with `drift_dev` 2.35.x on analyzer/dart_style);
  `riverpod_lint` 3.x is enabled via the top-level `plugins:` in analysis_options.yaml.
- `sqlite3: ^3.8.0` pinned directly (transitive would resolve 3.5.2).
- Versions: flutter_riverpod 3.4.3, go_router 18.1.1, drift 2.35.3, drift_dev 2.35.2,
  shared_preferences 2.5.6, intl 0.20.3, json_serializable 6.15.2,
  build_runner 2.17.1, riverpod_lint 3.1.9, analyzer 14.6.0.
- Drift 2.x column syntax needs the trailing call: `text()()`, `dateTime()()`,
  `text().withDefault(const Constant(''))()`. A stray extra `()` produces the cryptic
  `FunctionExpressionInvocationImpl is not a subtype of MethodInvocation` error.

## Architecture & conventions

- Feature-first MVVM: `lib/app`, `lib/features`, `lib/domain` (pure Dart), `lib/data`,
  `lib/core`. Direction: Presentation → Domain ← Data. Widgets never touch the DB.
- Randomness/clocks injectable; no service locators or global mutable singletons.
- Design tokens only (`lib/core/theme/`: AppColors, AppSpacing, AppRadii,
  AppGradients, AppTheme, AppTypography). No literal `Color(0xFF...)` in widgets.
- Dark theme only. Honest UI (no fake progress). Scores 0–100, non-clinical — never
  a standardized IQ, percentile, or diagnosis. EQ score is not a personality measure.
- Schema changes via migrations only, never destructive resets. DB schema **v3**:
  `game_sessions`, `question_attempts`, `achievements`, `daily_activity`. Sessions +
  attempts written atomically in one transaction. Drift reads `DateTime` back as local
  time — compare `.toUtc()` in tests.
- Content: stable authored IDs (never random/timestamp), validated at load; malformed
  records produce typed errors. EQ options all need rubric entries; no clinical or
  stereotyping framing.
- Quick Quest mix `{iq:5, puzzle:2, eq:3}`; daily seed = FNV-1a of
  `localDate|contentVersion`, daily selection ignores recent IDs. 5 achievements,
  unlock exactly once. No "Quest Completion Score" (intentional, PLAN §4.4).
- Test gotchas: `Override` is not exported by flutter_riverpod (use untyped
  `overrides:`); lazy ListView review needs tall `tester.view.physicalSize`; widget
  tests booting Home/Progress must override `appDatabaseProvider` with an in-memory DB
  (`test/support/test_app.dart`).
- Localization: `lib/core/localization/l10n/app_{en,vi}.arb`; content mirrored under
  `assets/content/{en,vi}/`. `docs/content-qa.md` holds content/accessibility QA notes.
  After editing an ARB, run `flutter gen-l10n` — generated files are committed.
- **Vietnamese copy conventions (settled 2026-11-06):** modern spellings only
  (`khóa`, `hủy`, `xóa`, `tòa`, `tùy`, `thỏa`); 2nd person is always `bạn` (never
  `cậu`); clock time needs `lúc` ("lúc 3 giờ"), durations don't; `CC` uppercase for
  email copies. Puzzles that depend on English letter positions must say
  "bảng chữ cái tiếng Anh 26 chữ".

## Skills are project-scoped (settled)

**Canonical real files: `.agents/skills/`** (`flutter-dev`, `flutter-master`,
`flutter-dev-skill`). All other agent dirs hold relative symlinks back to it:
`.claude/skills`, `.windsurf/skills`, `.trae/skills`, `.qoder/skills`,
`.minimax/skills`, `.codebuddy/skills`, `.kiro/skills`, `.workbuddy-ai/skills`.
Never put a real copy in a symlinked dir. `.agents/skills/` also serves 14 other
agents — it is not redundant with `.claude/skills/`. `.gemini/skills/` is Gemini's
GLOBAL path (dead weight in a repo). Path table:
`~/.npm/_npx/*/node_modules/skills/docs/agents.md`.

`~/.workbuddy-ai/skills/flutter-dev` remains globally on purpose (other Flutter
projects may use it); earlier global copies parked in
`~/.workbuddy-ai/backups/skills-global-removed-20261027`.
`search_and_install_skills` returns HTTP 404 — use the SkillHub registry
(`https://lightmake.site/api/v1/search?q=`, `/api/v1/download?slug=`).

`AGENTS.md` is the source of truth; `CLAUDE.md` / `GEMINI.md` are thin pointers —
keep them short so rules cannot drift.

## Workflow

One phase at a time; never start the next while the current has failing acceptance
criteria. Run the full baseline after every change set.
