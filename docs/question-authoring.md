# Question Authoring Guide

All question content is **bundled JSON** under `assets/content/`. It is validated at
load time; a malformed record produces a typed issue instead of crashing or silently
becoming a wrong question (PLAN §5.2).

## File layout

```text
assets/content/
├── manifest.json
└── en/
    ├── iq_questions.json
    ├── puzzle_questions.json
    └── eq_scenarios.json
```

`manifest.json`:

```json
{
  "schemaVersion": 1,
  "contentPackVersion": "0.2.0-draft",
  "supportedLocales": ["en"],
  "files": ["en/iq_questions.json", "en/puzzle_questions.json", "en/eq_scenarios.json"],
  "expectedItemCounts": { "iq": 16, "puzzle": 6, "eq": 16 }
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
| `contentType` | `multiple_choice`, `memory_sequence`, `reorder_sequence`, `scenario_choice` |
| `skill` | Free-form skill key (e.g. `pattern_recognition`, `memory`) |
| `difficulty` | `easy`, `medium`, `hard` |
| `locale` | `en` |
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

Rules (PLAN §4.6):

- **Every option must have a rubric entry**; the parser rejects an EQ item when an
  option lacks one.
- Dimension scores are integers `0..3`.
- Feedback explains trade-offs ("may help because…", "one risk is…"); never shame the
  player or assert a single universally correct response.
- No clinical, diagnostic, or mental-health claims; no stereotypes.
- `skillDimensions` lists the dimensions the item practises.

## Validation

Run:

```sh
flutter test test/unit/content_scan_test.dart
```

The test parses every file through the real parser and asserts no error issues, unique
IDs, per-domain counts matching the manifest, and that draft items surface warnings.

Common issue codes: `duplicateId`, `missingField`, `unknownDomain`, `unknownType`,
`invalidCorrectOption`, `missingRubric`, `invalidInteractionConfig`, `unexpectedUrl`
(warns if a prompt/option/explanation contains an `http(s)://` URL).

## Adding a locale

1. Add `assets/content/<locale>/…` with the same item IDs and translated text.
2. Add the locale to `manifest.json` (`supportedLocales`) and list its files.
3. Translate `AppStrings` (or migrate to ARB + `gen_l10n`) and add the locale to
   `MaterialApp.supportedLocales` / `localizationsDelegates`.
4. Only then expose a language selector; keep it hidden while only one locale exists.
