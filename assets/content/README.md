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
    puzzle_questions.json     # interactive puzzles (memory_sequence, reorder_sequence)
    eq_scenarios.json         # EQ scenario items (scenario_choice)
```

Add a second language by adding `assets/content/<locale>/...` and a locale entry
in `manifest.json` — never mix languages inside one item.

## manifest.json

```json
{
  "schemaVersion": 1,
  "contentPackVersion": "0.2.0-draft",
  "supportedLocales": ["en"],
  "files": ["en/iq_questions.json", "en/puzzle_questions.json", "en/eq_scenarios.json"],
  "expectedItemCounts": { "iq": 4, "puzzle": 2, "eq": 4 }
}
```

`expectedItemCounts` is a **soft** check: a shortfall produces a warning, not a
crash.

## Item rules (enforced by the validator)

- `id` — stable unique string, e.g. `iq_seq_001`. Never reuse or randomize it;
  progress depends on IDs staying stable. Duplicates are rejected.
- `domain` — one of `iq`, `puzzle`, `eq`. Unknown values are rejected.
- `contentType` — `multiple_choice`, `memory_sequence`, `reorder_sequence`,
  `scenario_choice`.
- `skill` — stable taxonomy key (not display text), e.g. `pattern_recognition`.
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

### puzzle (memory_sequence / reorder_sequence)

- `expectedAnswer`: non-empty list. `memory_sequence` → list of integers;
  `reorder_sequence` → list of tile-id strings.
- `reorder_sequence` also needs `interactionConfig.tiles` (list of ids); every
  `expectedAnswer` entry must be one of those tiles.

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
