# Question Authoring Guide

All question content is **bundled JSON** under `assets/content/`. It is validated at
load time; a malformed record produces a typed issue instead of crashing or silently
becoming a wrong question (PLAN §5.2).

## File layout

```text
assets/content/
├── manifest.json
├── en/
│   ├── iq_questions.json
│   ├── puzzle_questions.json
│   └── eq_scenarios.json
└── vi/                     # same files and ids, Vietnamese text
    ├── iq_questions.json
    ├── puzzle_questions.json
    └── eq_scenarios.json
```

`manifest.json`:

```json
{
  "schemaVersion": 1,
  "contentPackVersion": "0.4.0-draft",
  "supportedLocales": ["en", "vi"],
  "files": [
    "en/iq_questions.json", "en/puzzle_questions.json", "en/eq_scenarios.json",
    "vi/iq_questions.json", "vi/puzzle_questions.json", "vi/eq_scenarios.json"
  ],
  "expectedItemCounts": { "iq": 120, "puzzle": 90, "eq": 120 }
}
```

`expectedItemCounts` is asserted by `test/unit/content_scan_test.dart`, so update it
whenever you add or remove items.

## Common fields

Every item needs:

| Field | Notes |
| --- | --- |
| `id` | **Stable, authored, unique.** Never derive it from time or randomness; progress depends on it. |
| `domain` | `iq`, `puzzle`, or `eq` |
| `contentType` | `multiple_choice`, `memory_sequence`, `reorder_sequence`, `scenario_choice`, `visual_pattern`, `odd_one_out`, `matching_pairs` |
| `skill` | Free-form skill key (e.g. `number_patterns`, `logical_deduction`, `matching_pairs`) |
| `difficulty` | `easy`, `medium`, `hard` |
| `locale` | `en` or `vi`; must match the folder and be in `manifest.supportedLocales` |
| `status` | `draft` or `final`; draft items surface a warning |
| `prompt` | The question text |
| `explanation` | Shown in review; required for objective items |
| `hint` | Optional |
| `estimatedSeconds` | Optional |
| `pointsWeight` | Default `1` |
| `tags` | String list |
| `contentVersion` | Integer, bump when the item changes |

## IQ / reasoning (`multiple_choice`)

```json
{
  "id": "iq_seq_001",
  "domain": "iq",
  "contentType": "multiple_choice",
  "skill": "pattern_recognition",
  "difficulty": "easy",
  "locale": "en",
  "status": "draft",
  "prompt": "Which number comes next in the sequence?",
  "instructions": "Look for the rule that connects each number.",
  "options": [
    { "id": "a", "text": "24" },
    { "id": "b", "text": "30" },
    { "id": "c", "text": "32" },
    { "id": "d", "text": "64" }
  ],
  "correctOptionId": "c",
  "explanation": "Each number is doubled: 2, 4, 8, 16, so the next is 32.",
  "hint": "Compare each number with the one before it.",
  "estimatedSeconds": 25,
  "pointsWeight": 1,
  "tags": ["sequence", "numbers"],
  "contentVersion": 1
}
```

`correctOptionId` must reference one of `options`.

## Puzzles

### Memory sequence

```json
{
  "id": "puzzle_mem_002",
  "domain": "puzzle",
  "contentType": "memory_sequence",
  "skill": "memory",
  "difficulty": "medium",
  "locale": "en",
  "status": "draft",
  "prompt": "Memorize the sequence, then reproduce it in order.",
  "instructions": "Watch the tiles, then tap them in the same order.",
  "expectedAnswer": [4, 8, 2, 6, 5],
  "interactionConfig": { "length": 5, "minValue": 1, "maxValue": 9 },
  "explanation": "The target order was 4, 8, 2, 6, 5.",
  "hint": "Chunk it as 48, 26, 5.",
  "estimatedSeconds": 35,
  "pointsWeight": 1,
  "tags": ["memory", "sequence"],
  "contentVersion": 1
}
```

`expectedAnswer` must be integers.

### Reorder sequence

```json
{
  "id": "puzzle_reorder_002",
  "domain": "puzzle",
  "contentType": "reorder_sequence",
  "skill": "pattern_recognition",
  "difficulty": "easy",
  "locale": "en",
  "status": "draft",
  "prompt": "Arrange the morning routine into a sensible order.",
  "instructions": "Drag the tiles to form the sequence.",
  "expectedAnswer": ["Wake up", "Breakfast", "Commute", "Start work"],
  "interactionConfig": { "tiles": ["Wake up", "Breakfast", "Commute", "Start work"] },
  "explanation": "A common order is: wake up, breakfast, commute, start work.",
  "hint": "What happens first in the morning?",
  "estimatedSeconds": 30,
  "pointsWeight": 1,
  "tags": ["reorder", "ordering"],
  "contentVersion": 1
}
```

`expectedAnswer` must reference strings that appear in `interactionConfig.tiles`.

### Visual pattern and odd one out

```json
{
  "id": "puz_pattern_easy_001",
  "domain": "puzzle",
  "contentType": "visual_pattern",
  "skill": "visual_pattern",
  "difficulty": "easy",
  "locale": "en",
  "status": "draft",
  "prompt": "Which shape comes next?",
  "expectedAnswer": ["circle"],
  "options": [
    { "id": "circle", "text": "Circle" },
    { "id": "square", "text": "Square" }
  ],
  "interactionConfig": {
    "previewSymbols": ["circle", "square", "circle", "square", "blank"]
  },
  "explanation": "The pattern alternates circle and square."
}
```

`expectedAnswer` holds exactly one option id. `previewSymbols` is optional; use
`blank` for the missing slot. `odd_one_out` uses the identical shape — only the
prompt differs, and it must state the property being tested.

Symbol ids the app can draw: `circle`, `square`, `triangle`, `pentagon`,
`star`, `moon`, `leaf` (also accepted with a `symbol_` prefix). An unknown id
falls back to the option text, so new symbols stay readable.

### Matching pairs

```json
{
  "id": "puz_match_hard_001",
  "domain": "puzzle",
  "contentType": "matching_pairs",
  "skill": "matching_pairs",
  "difficulty": "hard",
  "locale": "en",
  "status": "draft",
  "prompt": "Find all three matching pairs.",
  "expectedAnswer": ["symbol_star", "symbol_moon", "symbol_leaf"],
  "options": [
    { "id": "symbol_star", "text": "Star" },
    { "id": "symbol_moon", "text": "Moon" },
    { "id": "symbol_leaf", "text": "Leaf" }
  ],
  "interactionConfig": { "maxFlips": 14 },
  "explanation": "The board holds a star pair, a moon pair, and a leaf pair."
}
```

Each pair id is placed twice and shuffled with a seed derived from the item id,
so the board is deterministic in tests. `maxFlips` caps the card reveals: the
item scores only when every pair was found inside that budget.

### Memory variants

`interactionConfig.revealSequence` shows a sequence that differs from the
scored answer, which is how the starter set authors "enter the third number",
"enter the sequence in reverse", and "positions 1, 3, 5" items.

## EQ scenarios (`scenario_choice`)

```json
{
  "id": "eq_comm_001",
  "domain": "eq",
  "contentType": "scenario_choice",
  "skill": "constructive_communication",
  "difficulty": "medium",
  "locale": "en",
  "status": "draft",
  "scenarioContext": "A teammate gives you critical feedback in a meeting…",
  "prompt": "What is a constructive next step?",
  "options": [
    { "id": "a", "text": "Ask for a specific example and listen before responding." },
    { "id": "b", "text": "Agree with every point immediately, even if you are unsure." },
    { "id": "c", "text": "Respond with a personal criticism of your teammate." }
  ],
  "rubricByOption": {
    "a": {
      "scores": {
        "emotion_awareness": 2,
        "self_regulation": 2,
        "perspective_taking": 2,
        "constructive_communication": 3,
        "boundaries_and_agency": 2
      },
      "feedback": "Asking for an example clarifies the concern and gives you time to respond thoughtfully."
    }
  },
  "skillDimensions": [
    "emotion_awareness",
    "self_regulation",
    "perspective_taking",
    "constructive_communication",
    "boundaries_and_agency"
  ],
  "followUpReflection": "What would help you feel ready to respond to difficult feedback?",
  "contentVersion": 1
}
```

### Rubric scale

All 120 scenarios use the same four-point scale, so a score means the same thing
everywhere:

| Score | The response… |
| --- | --- |
| 3 | does it explicitly and well: names the signal or feeling, offers a real choice, sets a limit with the relationship intact, or tests an alternative explanation before concluding. |
| 2 | does it partly, or does it well at a cost: honest but blunt, clear but with no alternative, right conclusion from an unchecked assumption. |
| 1 | touches it weakly or trades it away: a hint instead of a request, a kept peace that hides the impact, a limit without a reason. |
| 0 | leaves it out, dismisses it, blames the person, or escalates. |

On an item's practised dimension there must be exactly one 3, at least one option at
0 or 1, and a gap of at least 2 points; the option holding the 3 must also earn the
highest total. The scan test enforces all of that, so the rubric cannot drift back
into a single template.

Rules (PLAN §4.6):

- **Every option must have a rubric entry**; the parser rejects an EQ item when an
  option lacks one.
- Dimension scores are integers `0..3`.
- **Score each dimension on its own merits.** The same option is rarely equally
  strong everywhere: a boundary stated calmly can be a 3 for
  `boundaries_and_agency` and a 1 for `emotion_awareness` if it names no feeling.
  Copying one score across all five dimensions turns the per-dimension summary on
  the result screen into decoration.
- **Keep the spread on the item's primary dimension.** Exactly one option scores
  3 there, at least one scores 0 or 1, and the gap is at least 2 points. That is
  what lets the rubric separate a good answer from a weak one.
- Feedback explains trade-offs ("may help because…", "one risk is…"); never shame the
  player or assert a single universally correct response.
- No clinical, diagnostic, or mental-health claims; no stereotypes.
- `skillDimensions` lists the dimensions the item practises.

## Validation

Run:

```sh
flutter test test/unit/content_scan_test.dart
python3 tool/eq_audit.py          # EQ rubric spread, duplicates, wording
```

The content scan test also fails when an EQ item has no single best answer by
total points, when two options tie at 3 on the practised dimension, or when the
spread on that dimension is under 2 — so the tests and the audit enforce the same
rubric contract from both directions.

The test parses every file through the real parser and asserts no error issues, unique
IDs, per-domain counts matching the manifest, and that draft items surface warnings.

Common issue codes: `duplicateId`, `missingField`, `unknownDomain`, `unknownType`,
`invalidCorrectOption`, `missingRubric`, `invalidInteractionConfig`, `unexpectedUrl`
(warns if a prompt/option/explanation contains an `http(s)://` URL).

## Adding a locale

1. Add `assets/content/<locale>/…` with the same item IDs and translated text, and
   register the folder in `pubspec.yaml` (`assets/content/<locale>/`).
2. Add the locale to `manifest.json` (`supportedLocales`) and list its files.
3. Add and translate `lib/core/localization/l10n/app_<locale>.arb`, run
   `flutter gen-l10n`, then add the code to `AppLanguages.supported`.
4. `flutter test test/unit/content_scan_test.dart` — it validates each locale and
   asserts the translated pack keeps the same IDs, option IDs, answers, and rubric
   scores as `en`.

Only then expose the language in the selector; keep it hidden while a locale is
incomplete.
