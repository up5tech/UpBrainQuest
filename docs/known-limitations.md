# Known Limitations

These are current gaps, not defects. They are tracked so a release decision is explicit.

## Content

- **All content is `status: draft`.** A human copy-edit and EQ safety review is
  still recommended before a store release: `tool/eq_audit.py` checks the rubric
  structure and scans for diagnostic wording, but it cannot judge tone, cultural fit
  or whether a scenario's advice is sound.
- **Puzzle coverage is complete at 90 items.** All five mechanics —
  `visual_pattern`, `odd_one_out`, `matching_pairs`, `memory_sequence` and
  `reorder_sequence` — hold 18 each (6 easy / 6 medium / 6 hard), the PLAN §5.3
  quota.
- **The bank reaches the 330-item Version 1 quota** (PLAN §5.3): 120 IQ, 90
  puzzle and 120 EQ. Every item is still `status: draft`, so the content gates
  remain open until a human copy-edit and EQ safety review are signed off.
- **Puzzle Sprint is not playable.** Its card is shown as "Coming soon" rather than
  faking a session (PLAN §14.12).

## Platforms and release

- **Release signing is not configured.** `android/app/build.gradle.kts` signs release
  builds with the debug key (the Flutter template default). Replace it with a real
  keystore before uploading to Google Play.
- **The Android toolchain on this machine is incomplete** (`cmdline-tools` missing, SDK
  licences not accepted). Debug and release APKs build, but no emulator image is
  available; the iOS simulator is the verified runtime target.
- **iOS builds are unsigned here** (`--no-codesign`). App Store distribution requires
  an Apple Developer team, provisioning profile, and signing.
- **The release APK is a universal 61.1 MB build.** Use `--split-per-abi` (or an App
  Bundle) for smaller store downloads.

## UI and features

- **Dark theme only.** A light theme is deliberately absent; PLAN §8.2 forbids shipping
  an incomplete theme toggle.
- **Two locales (English, Vietnamese).** UI copy and questions are complete for both,
  so the Settings language selector is shown. The Vietnamese text is a first-pass
  translation and still needs native review.
- **No audio assets.** Sound feedback uses the platform click; haptics use the platform
  API. Both respect the Settings toggles.
- **No charts or trend lines.** Progress is shown as aggregates plus a recent-session
  list; PLAN Phase 6 asks for honest labels rather than implied trends.
- **Daily Challenge and streaks use the device's local date.** Moving the device clock
  can change them; this is a convenience feature, not a verified record.

## Reliability

- **Completion writes are not one cross-repository transaction.** The session is saved
  first, then daily activity and achievements are recorded. If a later step fails, the
  session remains saved and achievements are recomputed on the next completion. The
  result screen never claims a failed save succeeded.
- **No CI pipeline.** The baseline commands are documented in the README and run
  manually.
- **Integration tests require a device/simulator** and are not part of `flutter test`.

## Scoring

- Scores are in-game figures only (0–100). They are not standardized IQ values,
  percentiles, clinical assessments, or diagnoses. See `docs/scoring.md`.
