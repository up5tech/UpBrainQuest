# Known Limitations

These are current gaps, not defects. They are tracked so a release decision is explicit.

## Content

- **All content is `status: draft`.** A human copy-edit and EQ safety review is still
  recommended before a store release.
- **Puzzle coverage is 10 items** (3 memory sequences, 3 reorder sequences, 2 visual
  patterns, 1 odd-one-out, 1 matching-pairs board). That is enough for Quick Quest's
  2-item puzzle target but thin for a future Puzzle Sprint mode.
- **Content is the PLAN §5.10 starter set (32 items), not the 330-item release
  quota.** The bank must grow before a public release (PLAN §5.3).
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
