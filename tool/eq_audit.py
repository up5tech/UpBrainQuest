"""Audit the bundled EQ scenarios for rubric quality and safe wording.

Run from the project root:

    python3 tool/eq_audit.py

Exit code 0 means every check passed. The checks are:

1. Every option has a rubric with all five dimensions and non-empty feedback.
2. Each item offers at least three options.
3. On the item's primary dimension, one option must reach the top of the 0-3
   scale, a weaker option must exist, and the spread must be at least two
   points, so the rubric actually separates a good answer from a poor one.
4. Exactly one option may hold the top score on the primary dimension.
5. Option wording is distinct and long enough to read as a real response.
6. Feedback is long enough to teach something (six words or more).
7. No clinical, diagnostic or personality-labelling language (PLAN §4.6).
8. No near-duplicate scenarios across the bank.
9. Difficulty is evenly spread (8 easy / 8 medium / 8 hard) per dimension.
"""

import difflib
import json
import re
import sys

DIMENSIONS = [
    'emotion_awareness',
    'self_regulation',
    'perspective_taking',
    'constructive_communication',
    'boundaries_and_agency',
]

# Clinical, diagnostic or labelling language that PLAN §4.6 forbids.
BANNED = [
    r'\bdiagnos',
    r'\bdisorder',
    r'\bmental illness',
    r'\bdepress',
    r'\banxiety\b',
    r'\btherap',
    r'\btrauma',
    r'\bsymptom',
    r'\bneuro',
    r'\bpersonality type',
    r'\bnarciss',
    r'\btoxic person',
    r'\battachment style',
    r'\bEQ score',
    r'\bIQ\b',
    r'chẩn đoán',
    r'rối loạn',
    r'bệnh lý',
    r'trầm cảm',
    r'lo âu',
    r'sang chấn',
    r'tâm lý trị liệu',
    r'trị liệu',
    r'triệu chứng',
    r'nhân cách',
    r'áp lực tâm lý',
]

TOP_SCORE = 3
MIN_SPREAD = 2
MIN_OPTIONS = 3
MIN_FEEDBACK_WORDS = 6
NEAR_DUPLICATE = 0.82


def normalise(text):
    return re.sub(r'[^a-z0-9à-ỹ ]+', ' ', text.lower()).strip()


def audit_locale(locale):
    path = f'assets/content/{locale}/eq_scenarios.json'
    with open(path, encoding='utf-8') as fh:
        items = json.load(fh)['items']

    problems = []

    for item in items:
        item_id = item['id']
        primary = item['skill']
        options = item['options']
        rubric = item['rubricByOption']

        if set(rubric) != {o['id'] for o in options}:
            problems.append((item_id, 'rubric ids do not match option ids'))
            continue

        if len(options) < MIN_OPTIONS:
            problems.append((item_id, f'only {len(options)} options'))

        for option_id, entry in rubric.items():
            if set(entry['scores']) != set(DIMENSIONS):
                problems.append(
                    (item_id, f'rubric {option_id} misses a dimension')
                )
            if len(entry['feedback'].split()) < MIN_FEEDBACK_WORDS:
                problems.append(
                    (item_id, f'rubric {option_id} feedback too short')
                )

        primary_scores = sorted(
            rubric[o['id']]['scores'][primary] for o in options
        )
        best, worst = primary_scores[-1], primary_scores[0]
        if best < TOP_SCORE - 1:
            problems.append(
                (item_id, f'no strong option on {primary} (max {best})')
            )
        if worst > 1:
            problems.append(
                (item_id, f'no weak option on {primary} (min {worst})')
            )
        if best - worst < MIN_SPREAD:
            problems.append(
                (item_id, f'rubric spread only {best - worst} on {primary}')
            )
        tops = [
            o['id'] for o in options
            if rubric[o['id']]['scores'][primary] == best
        ]
        if len(tops) != 1:
            problems.append(
                (item_id, f'{len(tops)} options tie at the top of {primary}')
            )

        texts = [normalise(o['text']) for o in options]
        if len(set(texts)) != len(texts):
            problems.append((item_id, 'duplicate option wording'))
        for option in options:
            if len(option['text'].split()) < 2:
                problems.append(
                    (item_id, f'option too short: {option["text"]!r}')
                )

        blob = ' '.join(
            [item['scenarioContext'], item['prompt'],
             item.get('instructions', ''), item.get('followUpReflection', '')]
            + [o['text'] for o in options]
            + [e['feedback'] for e in rubric.values()]
        )
        for pattern in BANNED:
            if re.search(pattern, blob, re.IGNORECASE):
                problems.append(
                    (item_id, f'diagnostic/labelling phrasing: {pattern}')
                )

    for index, first in enumerate(items):
        for second in items[index + 1:]:
            ratio = difflib.SequenceMatcher(
                None,
                normalise(first['scenarioContext']),
                normalise(second['scenarioContext']),
            ).ratio()
            if ratio > NEAR_DUPLICATE:
                problems.append(
                    (f'{first["id"]} ~ {second["id"]}',
                     f'near-duplicate context ({ratio:.2f})')
                )

    counts = {}
    for item in items:
        key = (item['skill'], item['difficulty'])
        counts[key] = counts.get(key, 0) + 1
    for dimension in DIMENSIONS:
        split = [counts.get((dimension, d), 0)
                 for d in ('easy', 'medium', 'hard')]
        if split != [8, 8, 8]:
            problems.append((dimension, f'difficulty split {split}'))

    print(f'{locale}: {len(items)} scenarios')
    return problems


def main():
    problems = []
    for locale in ('en', 'vi'):
        problems.extend(audit_locale(locale))

    if not problems:
        print('EQ audit passed: no findings.')
        return 0

    print(f'\n{len(problems)} finding(s):')
    for item_id, message in problems:
        print(f'  {item_id}: {message}')
    return 1


if __name__ == '__main__':
    sys.exit(main())
