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

- Flutter **3.47.7** stable at `/Users/up5techjacky/Documents/sdk/flutter`,
  Dart **3.13.5**. Already on `PATH`.
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

## Skills are PROJECT-scoped (settled — do not move back to global)

The user explicitly wants skills installed **into the project, not globally**, so the
skill set travels with the checkout and cannot drift between machines.

- **Canonical copies:** `.workbuddy-ai/skills/` in this repo.
- **`flutter-dev`, `flutter-master`, `flutter-dev-skill`** — 44 files, 392K.
- **`.claude/skills/` and `.gemini/skills/`** contain **relative symlinks** to the
  canonical copies (`../../.workbuddy-ai/skills/<name>`), so Claude Code and Gemini CLI
  resolve the same files. Git stores them as mode `120000`, not duplicated blobs.
  **Never add real copies beside the symlinks** — the two versions would drift.
- `flutter-dev-skill`'s `name:` field was renamed from `flutter-dev` to
  `flutter-dev-skill` to avoid colliding with `flutter-dev`.

- `flutter-dev` — cross-platform guide (widget patterns, Riverpod, GoRouter, perf).
- `flutter-master` — audit/review toolkit; ships `scripts/audit_scan.sh` plus
  release/audit checklists. Maps to PLAN §6, §9, §11, §14.
- `flutter-dev-skill` — Material 3, layout constraints, adaptive/responsive, Hero &
  staggered animations, large screens.

**A global `~/.workbuddy-ai/skills/flutter-dev` still exists** and was deliberately left
alone: three other Flutter projects on this machine (`UpTowerDefense`, `crmhub-mobile`,
`penguin_nemt_app`) may depend on it. Do not delete it without checking those first.

`~/.copilot/skills` and `~/.windsurf/skills` do **not** exist on this machine and nothing
in their configs references a skills directory, so nothing was created there.

**Skill install path used by the built-in tool is unreliable:** `search_and_install_skills`
returns HTTP 404. Use the SkillHub registry instead —
`https://lightmake.site/api/v1/search?q=<query>` and
`https://lightmake.site/api/v1/download?slug=<slug>`. Install into
`.workbuddy-ai/skills/` in the project, not `~/.workbuddy-ai/skills/`.

## Agent entrypoint files

`AGENTS.md` is the source of truth. `CLAUDE.md` and `GEMINI.md` are thin pointers to it,
because Claude Code and Gemini CLI do not read `AGENTS.md` by name. Keep the pointers
short — never duplicate the rules, or they will drift.

## Workflow

One phase at a time — do not start the next phase while the current one has failing
acceptance criteria. Phase 0 is complete; Phase 1 (app shell, theme, navigation,
design system) is next.
