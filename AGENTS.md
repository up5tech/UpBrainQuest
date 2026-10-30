# AGENTS.md

Operating instructions for AI agents and tools working on **UpBrainQuest**.

This file is the short version. `PLAN.md` is the source of truth for *what* to build;
this file is the contract for *how* to build it. When the two disagree, `PLAN.md` wins
on product intent and this file wins on engineering practice.

---

## 1. What this project is

A fully offline, single-player **IQ & EQ Challenge** game for Android and iOS, built
with Flutter. IQ-inspired reasoning puzzles, memory/pattern challenges, and EQ social
scenarios in short replayable sessions.

**Non-negotiables (PLAN §1.2, §7.4, §10):**

- **No backend.** No server, no remote APIs, no Firebase, no remote config.
- **No network at runtime.** No analytics, no crash reporting, no ads, no social SDK.
- **No remote assets.** All questions, illustrations, and rules ship inside the app.
- **No accounts, no login.** The player is anonymous by design.

If a change would introduce any of the above, it is out of scope for the MVP.

---

## 2. Current state

| Phase | Scope | Status |
| --- | --- | --- |
| 0 | Repository discovery and project baseline | **Complete** |
| 1 | App shell, theme, navigation, design system | **Complete** |
| 2–8 | Content, engine, gameplay, EQ, Quick Quest, persistence, achievements, polish | **Complete** |
| 9 | Release readiness, offline audit, documentation | **Complete** |

`PLAN.md` holds the full task list and acceptance criteria per phase.

**The working rule (PLAN, preamble):** implement and verify **one phase at a time**.
Do not begin the next phase while the current phase has failing acceptance criteria.

---

## 3. Commands

```sh
flutter pub get                                    # fetch dependencies
dart run build_runner build                        # regenerate *.g.dart
dart format --output=none --set-exit-if-changed .  # formatting is enforced
flutter analyze                                    # zero warnings required
flutter test                                       # host test suite
flutter test integration_test/ -d <device-id>      # on-device suite
flutter build ios --simulator --debug              # iOS debug build
flutter build apk --debug                          # Android debug build
```

### Environment gotchas

- **A system HTTP proxy breaks `flutter test` and `flutter build` on this machine.**
  Without a `NO_PROXY` override the test runner cannot open its local WebSocket and
  fails with `WebSocketException: Invalid WebSocket upgrade request`. Always use:

  ```sh
  NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter test
  ```

- **Flutter lives at `/Users/up5techjacky/Documents/sdk/flutter`** (3.47.8 stable,
  Dart 3.13.7). It is already on `PATH`.
- **The Android toolchain is incomplete here**: `cmdline-tools` is missing and the SDK
  licences are not accepted. `flutter build apk --debug` succeeds, but no emulator image
  is available. Use the **iPhone 17 Pro simulator** (UDID
  `F3C58321-6F34-4505-B1A5-8FA98E8AB880`) as the runtime target.

---

## 4. Architecture

Feature-first structure with a lightweight MVVM separation (PLAN §6.1). Strict
dependency direction:

```
Presentation  ──▶  Domain  ◀──  Data
 (widgets,        (models,         (JSON loading,
  view models)     engines,          SQLite, repos,
                    use cases)       preferences)
```

| Path | Owns |
| --- | --- |
| `lib/app/` | Bootstrap, router, provider composition point |
| `lib/features/` | Pages and widgets, grouped by feature |
| `lib/domain/` | Typed models, enums, engines, use cases — **pure Dart** |
| `lib/data/` | JSON loading, Drift database, repositories, preferences |
| `lib/core/` | Theme tokens, logging, errors, result types, shared widgets |
| `assets/content/` | Bundled question JSON (Phase 2) |

### Dependency rules (PLAN §6.3)

1. **Domain logic is pure Dart.** No Flutter widget imports, no SQLite, no platform
   APIs in `lib/domain/`. This is what makes score calculators unit-testable without a
   widget tree.
2. **Widgets never touch the database.** They talk to view models and providers; the
   data layer owns persistence.
3. **Randomness and clocks are injectable.** Session building and daily challenges take
   a seeded random source and an injectable date provider so tests are deterministic.
4. **No service locators, no global mutable singletons** outside the app composition
   root.
5. **Never import a concrete data source into a view model** when a repository
   interface keeps the boundary clear.

---

## 5. Coding conventions

### Static analysis is strict and enforced

`analysis_options.yaml` enables `strict-casts`, `strict-inference`, and
`strict-raw-types`, treats `unawaited_futures` / `dead_code` / `unused_local_variable` /
`unused_element` as **errors**, and adds ~40 extra lints. `riverpod_lint` is enabled
through the top-level `plugins:` mapping.

**Do not silence a warning to make the pipeline green.** Fix the cause, or add a
narrowly scoped `// ignore:` with a written justification.

### Style rules

- `always_use_package_imports` — always `package:up_brain_quest/...`, never relative.
- `prefer_single_quotes`, `require_trailing_commas`, `lines_longer_than_80_chars`.
- `const` constructors everywhere they are possible; `prefer_const_declarations`.
- Sort constructors first, then child properties last.
- Extract reusable widgets into their own files; no widget building inside `build()`.

### Design tokens — no magic values (PLAN §8.2)

Every colour, spacing value, radius, and text style comes from `lib/core/theme/`.
Literal values like `Color(0xFF...)` or `EdgeInsets.all(13)` in widget code are a bug.

| Token | File |
| --- | --- |
| Colours | `lib/core/theme/app_colors.dart` |
| Gradients | `lib/core/theme/app_gradients.dart` |
| Radii | `lib/core/theme/app_radii.dart` |
| Spacing | `lib/core/theme/app_spacing.dart` |
| Typography + `ThemeData` | `lib/core/theme/app_theme.dart` |

### Dark theme only, for now

PLAN §8.2 forbids shipping an incomplete theme toggle. Do not add a light theme or a
theme switcher until the full token set supports it.

### Honest UI

PLAN §14.12 — never present placeholder data as real user progress. No fake scores, no
fake history, no lorem ipsum in release screens. Where a feature is not implemented,
show an empty state that says so.

---

## 6. Content rules (Phase 2 onward)

- Question content is **bundled JSON** in `assets/content/`, validated at load time. A
  malformed record must produce a typed, understandable error — never a crash and never
  a silently wrong question.
- **Stable, authored IDs.** Never derive a question ID from a random or timestamp
  source; progress depends on IDs staying stable across releases.
- Every item needs: `id`, `type`, `skill`, `difficulty`, `prompt`, `options`, and for EQ
  scenarios a `rubric` with dimensions.
- **EQ content-quality rules (PLAN §4.6) apply.** No clinical or diagnostic framing, no
  stereotypes, no mental-health claims.

---

## 7. Score and interpretation rules

Read PLAN §4 before touching anything score-related. In short:

- The app shows an **IQ Challenge Score** and an **EQ Practice Score**, each 0–100,
  derived from the app's own content and rules.
- These are **never** converted into a standardized IQ value, a percentile, a clinical
  label, or a diagnosis. The UI must not imply otherwise.
- The EQ score is **not** a personality measurement.
- Score algorithms are **versioned**. When the algorithm changes, bump the version so
  historical sessions remain interpretable.

---

## 8. Persistence rules (Phase 6 onward)

- **Drift/SQLite is the source of truth** for completed sessions, attempts, and
  progress.
- **Schema changes go through migrations.** Never delete the database or drop a table
  to "fix" a migration — that destroys player progress.
- Bump `schemaVersion` whenever `migration` is extended.
- Sessions and their attempts are written **atomically** in one transaction.
- The database connection runs on a background isolate; UI code never blocks on it.
- `sqlite3` 3.x bundles SQLite via Dart build hooks. **Do not add
  `sqlite3_flutter_libs` or `sqlcipher_flutter_libs`** — both are EOL and obsolete.

---

## 9. Code generation

Generated files are **committed** so a clean checkout builds without extra tooling.

| Generated | Builder | Source |
| --- | --- | --- |
| `lib/data/database/app_database.g.dart` | `drift_dev` | `lib/data/database/app_database.dart` |
| JSON model `*.g.dart` | `json_serializable` | the annotated model |

Regenerate with `dart run build_runner build`. **Never hand-edit a `*.g.dart`.**

> **Drift 2.x column syntax.** Columns need the trailing call:
> `text()()`, `text().withDefault(const Constant(''))()`, `dateTime()()`.
> A stray extra `()` (e.g. `dateTime()()();`) makes `drift_dev` fail with a misleading
> `FunctionExpressionInvocationImpl is not a subtype of MethodInvocation` cast error.

---

## 10. Testing

| Level | Location | Covers |
| --- | --- | --- |
| Unit | `test/data/`, `test/domain/` | Engines, calculators, repositories, validation |
| Widget | `test/widget_test.dart` | Screen behaviour, overflow, semantics, theming |
| Integration | `integration_test/` | On-device behaviour (e.g. the local database) |

Rules of thumb (PLAN §11.6):

- Test **behaviour**, not implementation details.
- Domain logic is tested as pure Dart — no widget tree needed.
- For every widget that can overflow, test at a narrow phone width (320dp).
- Every interactive element needs a meaningful **semantic label**.
- A test that would still pass with the feature deleted is not a test.

---

## 11. Definition of done for any change

A change is complete when:

1. `dart format --output=none --set-exit-if-changed .` is clean.
2. `flutter analyze` reports **no issues**.
3. `flutter test` passes, plus `flutter test integration_test/ -d <device>` when the
   change touches device behaviour.
4. The debug build still launches on the iOS simulator.
5. New behaviour is covered by tests at the appropriate level.
6. Colours, spacing, radii, and type come from tokens — no literals.
7. The change respects the offline guarantee: no new network dependency, no new
   permission, no remote asset.
8. Commit with a focused message describing *why*, not just *what*.

---

## 12. Things that will bite you

| Symptom | Cause | Fix |
| --- | --- | --- |
| `flutter test` → `WebSocketException: Invalid WebSocket upgrade request` | System HTTP proxy hijacking the local socket | Set `NO_PROXY="localhost,127.0.0.1,::1"` |
| `drift_dev` → `FunctionExpressionInvocationImpl is not a subtype of MethodInvocation` | Malformed column expression (usually an extra `()`) | Fix the column getter; see §9 |
| `custom_lint` and `drift_dev` fail to resolve together | Conflicting `analyzer`/`dart_style` ranges | Do not add `custom_lint`; `riverpod_lint` 3.x needs no such dependency |
| `sqlite3_flutter_libs` warnings | EOL package pulled in transitively | Do not use `drift_flutter`; depend on `drift` + `sqlite3` + `path_provider` |
| Android build fails on `dev.flutter.plugins.integration_test does not exist` | Plugin registrant regenerated mid-build (e.g. `pub add` racing a build) | Re-run the build after `pub get` settles |
| `flutter build_runner` warns `--delete-conflicting-outputs was removed` | build_runner 2.17 removed the flag | Harmless — `build_runner build` already resolves conflicts |

---

## 13. Available skills

Three Flutter skills ship **with this repository**. They are project-scoped on purpose:
nothing is installed globally, so the skill set travels with the checkout and cannot
drift between machines.

| Skill | Use it for |
| --- | --- |
| `flutter-dev` | Widget patterns, Riverpod/Bloc, GoRouter, responsive layout, perf profiling |
| `flutter-master` | Audits and pre-release checks. Ships `references/` (architecture, code-style, state-management, testing, performance, security, ux-quality, audit-checklist, release-checklist) and `scripts/audit_scan.sh` |
| `flutter-dev-skill` | Material 3, layout constraints, adaptive/responsive, large screens, Hero & staggered animations, navigation components |

### Where the files live

`.agents/skills/` is the **canonical** location and holds the real files. Every other
agent directory contains **relative symlinks** back to it, so each tool finds the same
skills without a second copy that could drift:

| Agent directory | Serves |
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

**Add or update a skill in `.agents/skills/` only.** Never put a real copy in one of the
symlinked directories — the two versions would silently diverge.

Guidance:

- **Phase 1 / Phase 8 (UI, navigation, motion)** → `flutter-dev-skill` first, then
  `flutter-master` for the quality bar.
- **Before calling a phase complete, or before a release** → `flutter-master`'s
  `audit-checklist.md` and `release-checklist.md`.
- **Debugging a widget or layout problem** → `flutter-dev`.
- Skills are reference material, not authority. `PLAN.md` and this file win when they
  disagree — for example, `flutter-dev-skill` suggests patterns we deliberately do not
  use (a light theme, `Hive`, `Dio`), because PLAN §8.2 and §7.4 forbid them here.

---

## 14. Reference

| Document | Purpose |
| --- | --- |
| `PLAN.md` | Product requirements, architecture, roadmap, acceptance criteria |
| `README.md` | Setup, baseline commands, package decisions, regeneration commands |
| `CLAUDE.md` / `GEMINI.md` | Thin pointers to this file for agents that read those names |
| `.workbuddy-ai/memory/` | Dated work log and long-term project notes |

<!-- trail:start -->
## Trail — repo context graph

This repo is indexed in `.trail/cache/`: small linked markdown nodes that explain each
system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives,
or scoping a change — get context from the graph before grepping or opening
source files. Re-ask freely (it's cheap) and reuse literal identifiers you
already have (symbol, error string, file name) as the query. New to this repo?
Run `trail map` first — a token-budgeted orientation (dir clusters, hubs,
hotspots), no LLM, no key.

- Run `trail ask "<your question>" --source` → ranked nodes with the relevant
  code spans inlined (each hit's ≤8-line crux by default; `--full` for whole
  definitions when the crux isn't enough). Match the tool to the task shape:
  for understanding or editing, the top node IS the answer — cite its
  `covers:` file:line spans and edit straight from `--source`. For
  exhaustive tasks ("every occurrence / every caller of this pattern"), ranked
  results are top-N, not complete — run `trail grep "<literal>"` instead
  (exhaustive over indexed files, grouped by enclosing symbol), falling back
  to raw `grep -rn` only for unindexed files.
- `trail skeleton <file>` → every definition's signature + span, ~10× cheaper
  than reading the file; use it to skim an API surface.
- `trail callers <symbol>` gives precomputed, exact edges — who calls this.
  Add `--direction out` for what it calls, or `--depth N` to walk
  transitively for the full blast radius. For structural questions, skip
  ranking and use this directly.
- Or browse: `.trail/cache/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects —
  hits carry `[scope/]` labels naming which one they're from. Narrow with
  `trail ask "<task>" --in <scope>/` once you know where you're working.

If a returned span is truncated ("+N more lines"), open the file at that exact
range before finalizing. Only open source files when a node genuinely lacks a
needed detail, and then at the exact file:line the node points to — never
re-read whole files.

After big code changes, refresh the graph with `trail build` (deterministic,
no API key, $0).
<!-- trail:end -->
