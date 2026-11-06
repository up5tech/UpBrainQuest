# Content authoring — UpBrainQuest

All game content is **bundled JSON**, shipped inside the app. There is no network
at runtime (PLAN §1.2, §7.4). This folder is the single source of truth for
questions.

## Layout

```
assets/content/
  manifest.json              # pack metadata + file list + expected counts
  en/
    iq_questions.json        # objective reasoning items (multiple_choice)
    puzzle_questions.json     # interactive puzzles (5 mechanics)
    eq_scenarios.json         # EQ scenario items (scenario_choice)
  vi/                        # same three files, same ids, Vietnamese text
```

Every locale ships its own complete copy of the item IDs: never mix languages
inside one item, and never leave an item untranslated. `ContentLoader` only
reads the `<locale>/` files for the active language.

## manifest.json

```json
{
  "schemaVersion": 1,
  "contentPackVersion": "0.4.0-draft",
  "supportedLocales": ["en", "vi"],
  "files": [
    "en/iq_questions.json", "en/puzzle_questions.json", "en/eq_scenarios.json",
    "vi/iq_questions.json", "vi/puzzle_questions.json", "vi/eq_scenarios.json"
  ],
  "expectedItemCounts": { "iq": 12, "puzzle": 10, "eq": 10 }
}
```

`expectedItemCounts` is a **soft** check: a shortfall produces a warning, not a
crash.

## Item rules (enforced by the validator)

- `id` — stable unique string, e.g. `iq_num_easy_001`. Never reuse or randomize
  it; progress depends on IDs staying stable. Duplicates are rejected.
- `domain` — one of `iq`, `puzzle`, `eq`. Unknown values are rejected.
- `contentType` — `multiple_choice`, `memory_sequence`, `reorder_sequence`,
  `scenario_choice`, `visual_pattern`, `odd_one_out`, `matching_pairs`.
- `skill` — stable taxonomy key (not display text), e.g. `number_patterns`.
- `difficulty` — `easy`, `medium`, `hard`.
- `locale` — must be listed in `manifest.supportedLocales` (else a warning).
- `prompt` — required. `instructions`, `explanation`, `hint` recommended.
- `status` — `draft` or `final`. Draft items load but emit a warning; mark work
  in progress as `draft`.

### multiple_choice (iq)

- `options`: ≥ 2 objects, each with a stable `id` and `text`.
- `correctOptionId`: must reference exactly one `options[].id`.
- `explanation`: required; explain the rule, not just the answer.
- `pointsWeight`: positive integer.

### puzzle

Five mechanics share the `puzzle` domain and each has its own interaction:

- `memory_sequence` — `expectedAnswer`: integers the player types. Optional
  `interactionConfig.revealSequence` (integers) shows a different sequence than
  the answer, which is how "recall only the third item", "reverse it", and
  "positions 1, 3, 5" items are authored. `minValue`/`maxValue` bound the keypad.
- `reorder_sequence` — `expectedAnswer`: tile-id strings, plus
  `interactionConfig.tiles` (list of the same ids); every answer entry must be
  one of those tiles.
- `visual_pattern` — `options` of symbol ids (`circle`, `square`, `triangle`,
  `pentagon`, `star`, `moon`, `leaf`), `expectedAnswer` exactly one option id,
  and optional `interactionConfig.previewSymbols` (use `blank` for the missing
  slot).
- `odd_one_out` — same shape as `visual_pattern`; the prompt must state the
  property being tested.
- `matching_pairs` — `expectedAnswer`: at least two unique pair ids, each placed
  twice on the board, with `options` supplying the localised labels and optional
  `interactionConfig.maxFlips` (card reveals allowed before the attempt fails).

Symbol ids are language-independent; only the option `text` changes per locale.

### scenario_choice (eq)

- `scenarioContext`: required context so the options make sense.
- `options`: plausible responses.
- `rubricByOption`: every option id must map to `{ scores: {...}, feedback }`.
- `scores` keys are EQ dimensions: `emotion_awareness`, `self_regulation`,
  `perspective_taking`, `constructive_communication`, `boundaries_and_agency`;
  each score is an integer **0–3**. Unknown dimensions warn; out-of-range scores
  reject the item.
- `skillDimensions`: the dimensions the scenario practises (optional).

## Hard constraints

- **No remote URLs** anywhere in text (prompt, explanation, feedback,
  scenarioContext). The product is fully offline. A URL triggers a warning.
- **No executable code** in JSON. Never put formulas or expressions in
  `expectedAnswer`/`interactionConfig` — use plain data.
- **Honesty:** EQ scores are practice only, never a clinical or diagnostic label.
  Keep feedback non-shaming and acknowledge trade-offs.

## Validation

Run the bundled-content scan (no widget tree needed):

```
flutter test test/unit/content_scan_test.dart
```

Invalid records are excluded and reported as typed `ContentIssue`s; they never
crash the app or silently become wrong questions.
