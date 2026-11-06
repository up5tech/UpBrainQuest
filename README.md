# UpBrainQuest

**IQ & EQ Challenge** — a fully offline, single-player mobile game for Android and iOS.

UpBrainQuest combines IQ-inspired reasoning puzzles, memory and pattern challenges, and
EQ-oriented interactive scenarios into short, replayable sessions. There is no backend,
no account, no analytics, and no network access: every question, illustration, and rule
ships inside the app.

> **Status: feature-complete through Phase 8; Phase 9 release readiness verified.**
> Debug and release artifacts build and the full test suite passes. Store signing is
> the remaining step — see [`docs/release-checklist.md`](docs/release-checklist.md) and
> [`docs/known-limitations.md`](docs/known-limitations.md).

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Baseline commands](#baseline-commands)
- [Release builds](#release-builds)
- [Testing](#testing)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Documentation](#documentation)
- [Offline guarantees](#offline-guarantees)
- [Generated files](#generated-files)
- [Dependency decisions](#dependency-decisions)
- [Known limitations](#known-limitations)
- [Roadmap](#roadmap)

---

## Requirements

| Tool | Version | Notes |
| --- | --- | --- |
| Flutter | **3.47.8** (stable) | Verified with this SDK. |
| Dart | **3.13.7** | Ships with Flutter 3.47.8. `pubspec.yaml` declares `sdk: ^3.13.5`. |
| Xcode | **26.1.1** | iOS builds. CocoaPods **1.16.2** required. |
| Android SDK | compile/target **36**, min **24** | NDK **28.2.13676358**, Java 17, AGP 9.1.0, Gradle 9.3.1. |
| iOS deployment target | **15.0** | |

Verify your toolchain with `flutter doctor -v`.

---

## Getting started

```sh
# 1. Fetch dependencies
flutter pub get

# 2. Regenerate committed code-generation outputs (Drift / JSON)
dart run build_runner build

# 3. Run on a connected device or simulator
flutter run

# 4. Run the test suite
flutter test
```

> **Proxy gotcha.** If `flutter test` fails with
> `WebSocketException: Invalid WebSocket upgrade request`, a system-wide HTTP proxy is
> intercepting the test runner. Bypass it for localhost:
>
> ```sh
> NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter test
> ```

---

## Baseline commands

```sh
dart format --output=none --set-exit-if-changed .   # formatting is enforced
flutter analyze                                     # zero warnings required
flutter test                                        # host suite (109 tests)
flutter build apk --debug                           # Android debug build
flutter build ios --simulator --debug               # iOS debug build
```

`flutter analyze` treats info-level lints as fatal in this configuration, so run
`dart format lib test` (and `dart fix --apply` when needed) first.

---

## Release builds

```sh
# Android (universal APK; use --split-per-abi or appbundle for smaller downloads)
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk

# iOS (unsigned; sign in Xcode / with a provisioning profile before distribution)
flutter build ios --release --no-codesign
# -> build/ios/iphoneos/Runner.app
```

Verified artifacts: **`app-release.apk` (61.1 MB)** and **`Runner.app` (20.1 MB)**.

**Signing is not configured for the store yet.** `android/app/build.gradle.kts` still
uses the debug key for release; replace it with a real keystore before uploading. See
[`docs/release-checklist.md`](docs/release-checklist.md).

---

## Testing

- **Host suite:** `flutter test` — 109 tests covering content parsing/validation, the
  session builder, IQ/EQ scoring, achievements, streaks, the daily selector, database
  migrations, repositories, and widget behaviour (navigation, results, progress, text
  scaling, contrast, offline audit).
- **Content validation:** `flutter test test/unit/content_scan_test.dart` parses every
  bundled file through the real parser.
- **Integration tests:** `flutter test integration_test/ -d <device-id>` — verifies the
  bundled SQLite native library on a real device/simulator.

---

## Architecture

Feature-first with a lightweight MVVM separation and a strict dependency direction:

```
Presentation  ──▶  Domain  ◀──  Data
 (pages,          (models,         (JSON loading,
  widgets,         engines,          SQLite, repos,
  controllers)     use cases)        preferences)
```

- **Domain is pure Dart** — score calculators, `SessionBuilder`, `AchievementEngine`,
  `StreakCalculator`, and `DailyChallengeSelector` are unit-testable without a widget
  tree.
- **Widgets never touch the database** — they read Riverpod providers; the data layer
  owns persistence.
- **Deterministic where it matters** — seeded random selection, a date+content-version
  daily seed, and an injectable `today` for streaks.

Full details: [`docs/architecture.md`](docs/architecture.md).

---

## Project structure

```text
up_brain_quest/
├── android/                     # Android host project
├── ios/                         # iOS host project
├── assets/content/              # Bundled question JSON (en/)
├── docs/                        # Architecture, authoring, scoring, audits, release
├── lib/
│   ├── main.dart
│   ├── app/                     # Bootstrap, router, providers
│   ├── core/                    # Theme tokens, strings, feedback, widgets
│   ├── data/                    # Content loading, Drift, repositories, preferences
│   ├── domain/                  # Models, engines, use cases
│   └── features/                # Home, Explore, Gameplay, Progress, Settings
├── test/                        # Domain, data, widget, release tests
├── integration_test/
├── analysis_options.yaml
├── pubspec.yaml
├── PLAN.md
└── README.md
```

---

## Documentation

| Document | Contents |
| --- | --- |
| [`docs/architecture.md`](docs/architecture.md) | Layers, components, data flow, schema |
| [`docs/question-authoring.md`](docs/question-authoring.md) | JSON schema for IQ, puzzle, and EQ items; validation; locales |
| [`docs/scoring.md`](docs/scoring.md) | IQ and EQ formulas, dimensions, versioning |
| [`docs/offline-audit.md`](docs/offline-audit.md) | Permissions, dependencies, code scan, privacy |
| [`docs/content-qa.md`](docs/content-qa.md) | Content inventory, EQ review, accessibility, localization readiness |
| [`docs/release-checklist.md`](docs/release-checklist.md) | Tool versions, build results, signing, manual checks |
| [`docs/known-limitations.md`](docs/known-limitations.md) | Current gaps and caveats |
| [`PLAN.md`](PLAN.md) | Product and engineering plan |

---

## Offline guarantees

- No backend, remote API, Firebase, remote config, analytics, crash upload, ads, or
  social SDK.
- No remote fonts, images, questions, or feature flags; all content is bundled.
- The **release** Android manifest declares no `INTERNET` permission (it exists only in
  the debug/profile manifests for Flutter tooling).
- iOS declares no App Transport Security exception.
- `test/release/offline_audit_test.dart` fails the build if any network API, remote
  image, or network dependency is reintroduced.

---

## Generated files

Generated files are **committed** so a clean checkout builds without an extra step:

| File | Produced by | Source |
| --- | --- | --- |
| `lib/data/database/app_database.g.dart` | `drift_dev` | `lib/data/database/app_database.dart` |
| `**/*.g.dart` (JSON models) | `json_serializable` | Annotated models |

Regenerate with `dart run build_runner build`. Never hand-edit `*.g.dart`.

> `build_runner` 2.17 removed `--delete-conflicting-outputs`; it is ignored with a
> warning and conflict resolution happens automatically.

---

## Dependency decisions

1. **`drift` + `sqlite3` + `path_provider` directly** (not `drift_flutter`). The latter
   pulls `sqlite3_flutter_libs` / `sqlcipher_flutter_libs`, both `+eol`; `package:sqlite3`
   3.x bundles SQLite through Dart build hooks.
2. **`custom_lint` is not used.** It conflicts with `drift_dev` 2.35.x on `analyzer` /
   `dart_style` ranges. `riverpod_lint` 3.x runs as an analysis-server plugin.
3. **No charting, UUID, or Flame dependency.** Charts are not needed for the honest
   progress list; question IDs are authored; puzzles use standard Flutter widgets.

---

## Known limitations

- Content is still `status: draft`; a human copy-edit and EQ review is recommended.
- Puzzle coverage is 6 items; Puzzle Sprint is not playable yet.
- Dark theme only; UI and content ship in English and Vietnamese; no audio assets.
- Release signing is not configured (debug key on Android, unsigned iOS).
- The Android toolchain on this machine has no emulator; the iOS simulator is the
  verified runtime target.

Full list: [`docs/known-limitations.md`](docs/known-limitations.md).

---

## Roadmap

| Phase | Scope | Status |
| --- | --- | --- |
| 0 | Repository discovery and baseline | Complete |
| 1 | App shell, theme, navigation, design system | Complete |
| 2 | Content models, JSON loader, validation | Complete |
| 3 | Session engine and IQ Challenge | Complete |
| 4 | EQ scenario gameplay and rubric scoring | Complete |
| 5 | Mixed Quick Quest, results, review, scores | Complete |
| 6 | Local database, history, progress | Complete |
| 7 | Achievements, daily challenge, replayability | Complete |
| 8 | Visual polish, accessibility, localization readiness | Complete |
| 9 | Release readiness, offline audit, documentation | Complete |

See [`PLAN.md`](PLAN.md) for the full task list and acceptance criteria.
