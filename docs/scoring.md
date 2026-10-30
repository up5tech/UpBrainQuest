# Scoring

UpBrainQuest shows two **in-game** scores. Neither is a standardized IQ value, a
percentile, a clinical EQ assessment, or a diagnosis (PLAN §4).

## IQ Challenge Score (0–100)

Source: `lib/domain/scoring/iq_score_calculator.dart`.

- Only **objectively scored** items contribute (multiple choice and puzzle items).
- EQ items (`isCorrect == null`) are excluded from both numerator and denominator.
- Formula: `score = round(100 × earnedWeightedPoints / possibleWeightedPoints)`.
- Each item contributes `pointsWeight` possible points; a correct answer earns the
  full weight.
- If the denominator is zero (no objective items), the result is **invalid** and the
  UI shows `—` instead of a fabricated 0.

## EQ Practice Score (0–100)

Source: `lib/domain/scoring/eq_score_calculator.dart`.

- Each EQ option carries an authored rubric: a score per skill dimension.
- Formula: `score = round(100 × earnedRubricPoints / possibleRubricPoints)`, where
  `possibleRubricPoints` is the maximum total for the item.
- **Per-dimension scores** are also computed:
  `round(100 × dimensionEarned / dimensionPossible)`, so one aggregate cannot conceal
  what was practised.
- Dimensions: Emotion Awareness, Self-Regulation, Perspective Taking, Constructive
  Communication, Boundaries & Agency.
- EQ items are **non-binary**: the result screen shows "Your response" and a rubric
  summary, never "correct/incorrect".

## Versioning

- Both calculators expose `scoreAlgorithmVersion = 1`.
- Every persisted session records `score_algorithm_version` and
  `content_pack_version`.
- If scoring logic changes, bump the version; historical results must remain
  interpretable and must not be silently recalculated with new rules (PLAN §4.5).

## Interpretation rules

- Scores summarize performance on **this app's challenges**, not intelligence or
  emotional ability in real life.
- The UI never converts them into an IQ value, percentile, clinical label, or
  diagnosis.
- The EQ score is not a personality measurement.
- Disclaimers are shown on the result screen and in the About dialog.

## Worked example

A Quick Quest with 5 reasoning items (weight 1 each, 3 correct), 2 puzzle items
(weight 1 each, 1 correct), and 3 EQ items (rubric max 3 each, 6 earned):

- IQ: earned 4 / possible 7 → `round(100 × 4 / 7) = 57`.
- EQ: earned 6 / possible 9 → `round(100 × 6 / 9) = 67`.
- The two scores are shown separately; there is no combined "IQ/EQ" number.
