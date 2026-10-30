# Content QA, Accessibility, and Localization Readiness

_Phase 8 deliverable. Last verified with the Phase 8 test run (`flutter test` →
96/96; after this phase's additions the suite is re-run and recorded in the phase
notes)._

## 1. Content inventory

| Domain | Items | Types | Notes |
| --- | --- | --- | --- |
| IQ / reasoning | 16 | `multiple_choice` | Sequences, logic, arithmetic reasoning |
| Puzzle | 6 | `memory_sequence` (3), `reorder_sequence` (3) | Expanded in Phase 8 from 2 → 6 |
| EQ | 16 | `scenario_choice` | All 5 rubric dimensions represented |
| **Total** | **38** | | All items are `status: draft` |

The manifest declares `expectedItemCounts` (`iq: 16`, `puzzle: 6`, `eq: 16`) and the
validation test asserts the parsed bank matches those counts exactly.

## 2. Validation results

`test/unit/content_scan_test.dart` parses every bundled file through the real
`ContentParser` and asserts:

- no error-severity issues (malformed records, unknown domains/types/skills, missing
  prompts/options/explanations, invalid `correctOptionId`, EQ options without a
  rubric);
- **no duplicate IDs** across the pack;
- per-domain counts match the manifest;
- every draft item surfaces a `draftContent` warning (so labels are visible in the
  UI rather than silently shipped as final).

## 3. EQ content review (PLAN §4.6)

Themes covered by the 16 scenarios: receiving critical feedback, anger while late,
a distant colleague, boundary-setting with shift requests, noticing body signals,
verbal/non-verbal mismatch, mixed emotions, giving peer feedback, a heated group
chat, repairing after snapping, a blunt client message, irritation under a deadline,
a friend cancelling, a sharp customer, a premature request for a home address, and
family pressure over a career choice.

Review findings:

- **Non-binary framing.** Options are scored by rubric points; the result screen
  never labels an EQ response "correct/incorrect", and review copy shows "Your
  response" plus a per-dimension rubric summary.
- **No clinical or diagnostic language.** No claims about disorders, diagnoses, or
  measured emotional ability. The EQ score is labelled "EQ Practice Score" with a
  visible disclaimer.
- **No stereotypes or mental-health claims.** Scenarios describe situations, not
  people's worth or identity.
- **Context-aware feedback.** Feedback explains trade-offs ("may help because…",
  "one risk is…") rather than asserting a single universally right answer.
- **Neutralized framing.** The group-chat scenario was reworded to remove a
  political topic, keeping it about de-escalation only.
- **Copy-edit note.** All content remains `status: draft`; a human copy-edit pass is
  still recommended before a release build (wording, tone, and locale review).

## 4. Accessibility checks

| Check | Result |
| --- | --- |
| Meaningful semantics on key controls | `ModeCard`, `AppProgressBar`, score cards, achievement/history tiles use `Semantics`/`MergeSemantics`; option tiles and icon buttons already had explicit labels |
| Text scaling (1.5×, 2.0×) | `test/widget/text_scaling_test.dart` visits all four tabs with no overflow; the result screen is also checked at 2× (`session_result_page_test`) |
| Contrast (WCAG AA) | `test/core/theme_contrast_test.dart` asserts ≥ 4.5:1 for primary/secondary text on all surfaces and for on-accent text on every accent fill |
| Not colour alone | Correct/incorrect states use an icon + a text label in addition to colour; EQ locked state uses a neutral "Your response" label |
| Touch targets | `AppButton` and `AccessibleIconButton` use `AppTheme.minTouchTarget` (48dp) |
| Reduced motion | The app-level preference is folded into `MediaQuery.disableAnimations` (plus the OS setting), so result and route animations are skipped |
| Screen-reader grouping | Composite cards (score, achievement, history) merge their text into one announcement |

Layout fixes made for scaling: the bottom navigation height now grows with the text
scale, empty/error states scroll instead of overflowing, and the result save banner,
achievement tiles, and history tiles were reflowed from tight `Row`s into columns.

## 5. Localization readiness

Current state:

- **All UI copy lives in `lib/core/localization/app_strings.dart`.** Phase 8 moved
  the last hardcoded gameplay strings ("Delete", "Correct sequence", "Your
  sequence", "Correct order", "Retry") and added count-format helpers.
- The app declares `supportedLocales: [Locale('en')]` and shows **no language
  selector**, so there is no nonfunctional control.
- Content is locale-scoped: `assets/content/en/…`, with `supportedLocales` and
  `files` declared in `assets/content/manifest.json`.
- Dates use `intl`'s `DateFormat`, which is locale-aware once locale data is loaded.

To add a second locale (only when translations are complete):

1. Add `assets/content/<locale>/…` with matching item IDs and translations, and list
   the locale in the manifest.
2. Translate `AppStrings` (or migrate to ARB + `gen_l10n`) and add the locale to
   `MaterialApp.supportedLocales` / `localizationsDelegates`.
3. Add a locale setting only after both UI and content are complete; keep the
   selector hidden otherwise.
4. Re-run `content_scan_test` so the new pack is validated.

## 6. Known limitations

- Content is draft; a human copy-edit and EQ safety review is still recommended.
- Puzzle coverage is 6 items (sufficient for Quick Quest's 2-item target, thin for a
  future Puzzle Sprint mode).
- No audio assets; sound feedback uses the platform click.
- One locale (English); no illustrations beyond Material icons, so no third-party
  asset licensing is involved.
