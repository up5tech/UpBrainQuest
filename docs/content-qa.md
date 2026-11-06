# Content QA, Accessibility, and Localization Readiness

_Phase 8 deliverable. Last verified with the Phase 8 test run (`flutter test` →
96/96; after this phase's additions the suite is re-run and recorded in the phase
notes)._

## 1. Content inventory

| Domain | Items | Types | Notes |
| --- | --- | --- | --- |
| IQ / reasoning | 120 | `multiple_choice` | Five skills at the PLAN §5.3 quota of 24 each: number patterns, logical deduction, verbal analogies, spatial reasoning, working memory |
| Puzzle | 90 | `visual_pattern` (18), `odd_one_out` (18), `matching_pairs` (18), `memory_sequence` (18), `reorder_sequence` (18) | Every mechanic sits at its PLAN §5.3 quota of 18 (6 per difficulty) |
| EQ | 120 | `scenario_choice` | Five dimensions at the PLAN §5.3 quota of 24 each (8 easy / 8 medium / 8 hard); every option carries a full five-dimension rubric |
| **Total** | **330** | | All items are `status: draft` |

The manifest declares `expectedItemCounts` (`iq: 120`, `puzzle: 90`, `eq: 120`) and the
validation test asserts the parsed bank matches those counts exactly. Every locale
must ship the same IDs; the parity test compares answers, option IDs, rubric scores
and symbol IDs across languages.

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

The bank holds 120 scenarios: 24 per dimension, split 8 easy / 8 medium / 8 hard.
Themes span work, family, friendship, neighbours, online disagreements and
service encounters, with difficulty coming from the number of competing needs and
from the responder's own state, never from obscure wording.

Run the automated audit after any EQ edit:

```sh
python3 tool/eq_audit.py
```

It fails on a missing dimension score, an item whose rubric cannot separate a good
answer from a poor one, duplicate option wording, feedback too short to teach
anything, near-duplicate scenarios, an uneven difficulty split, and any
clinical/diagnostic/personality-labelling language in either locale.

Audit of the 120-scenario expansion (all findings fixed):

- Ten scenarios shipped with only two options, so no option represented the weakest
  response and the rubric could not span the full 0-3 range. Each gained a third,
  clearly weak option with its own feedback in both locales.
- Six feedback strings were too terse to explain the trade-off; each was rewritten
  to say what the response achieves or costs.
- No clinical, diagnostic or personality-labelling wording was found in either
  locale, and no pair of scenarios was a near-duplicate.

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

- **UI copy lives in ARB files:** `lib/core/localization/l10n/app_en.arb` and
  `app_vi.arb`, compiled by `flutter gen-l10n` into
  `lib/core/localization/generated/`. Widgets read copy through
  `context.l10n`; `lib/core/localization/app_strings.dart` is the barrel that
  re-exports the generated API.
- `AppStrings` no longer exists as a hand-maintained class. Never hardcode a
  user-visible string in widget code.
- The app ships **English and Vietnamese**, with a working language selector in
  Settings (`AppLanguages.supported`). The selector is only present because UI
  copy and question content are complete for both.
- Content is locale-scoped: `assets/content/<locale>/…`, with `supportedLocales`
  and `files` declared in `assets/content/manifest.json`. `ContentLoader` reads
  only the active language's files, and `ContentParser` rejects an item whose
  `locale` does not match the pack being loaded.
- Dates use `intl`'s `DateFormat`, which is locale-aware once locale data is loaded.

To add another locale (only when translations are complete):

1. Add `assets/content/<locale>/…` with the same item IDs and translated text, and
   list the locale plus its files in the manifest. Register the folder in
   `pubspec.yaml` (`assets/content/<locale>/`) — declaring only `assets/content/`
   does not bundle subdirectories.
2. Add `lib/core/localization/l10n/app_<locale>.arb` with every key from
   `app_en.arb`, then run `flutter gen-l10n`.
3. Add the code to `AppLanguages.supported`; `supportedLocales` follows the ARB
   set, and `manifest.supportedLocales` must match it (a test enforces this).
4. Run `content_scan_test` (per-item parity with `en`) and the language-switch
   widget test.

## 6. Known limitations

- Content is draft; a human copy-edit and EQ safety review is still recommended.
- All three domains reach the Version 1 quota: IQ 120, puzzle 90 and EQ 120,
  every skill, mechanic and EQ dimension with an even 8/8/8 or 6/6/6 split. The
  bank is content-complete for PLAN §5.3 but still all `status: draft`.
- No audio assets; sound feedback uses the platform click.
- Two locales (English, Vietnamese), both complete for UI copy and content. The
  Vietnamese translation is machine-authored and still needs native review.
- No illustrations beyond Material icons, so no third-party asset licensing is
  involved.
