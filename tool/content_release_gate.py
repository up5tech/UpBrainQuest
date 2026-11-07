"""Release gate for the bundled question bank.

Run from the project root before cutting a store build:

    python3 tool/content_release_gate.py

Exit code 0 means the bank may ship. The gate fails while any item is still
`status: draft` or while the pack version carries a `-draft` suffix, because
PLAN §11 requires every Version 1 item to be approved; drafts belong in
development builds only. It also re-checks the structural invariants that a
hand-edit could break: manifest counts, locale parity, answer keys, and EQ
rubric coverage.
"""

import json
import sys

LOCALES = ('en', 'vi')
FILES = {
    'iq': 'iq_questions.json',
    'puzzle': 'puzzle_questions.json',
    'eq': 'eq_scenarios.json',
}
DIMENSIONS = {
    'emotion_awareness',
    'self_regulation',
    'perspective_taking',
    'constructive_communication',
    'boundaries_and_agency',
}


def load(locale, filename):
    path = f'assets/content/{locale}/{filename}'
    with open(path, encoding='utf-8') as handle:
        return json.load(handle)


def audit_domain(domain, manifest):
    blockers = []
    items = {}
    for locale in LOCALES:
        data = load(locale, FILES[domain])
        items[locale] = {item['id']: item for item in data['items']}
        expected = manifest['expectedItemCounts'][domain]
        actual = len(items[locale])
        if actual != expected:
            blockers.append(
                f'{locale} {domain}: {actual} items, manifest expects {expected}'
            )

    if set(items['en']) != set(items['vi']):
        blockers.append(f'{domain}: en and vi disagree on item ids')

    drafts = sorted(
        item_id
        for item_id, item in items['en'].items()
        if item.get('status') != 'final'
    )
    if drafts:
        blockers.append(
            f'{domain}: {len(drafts)} of {len(items["en"])} items are not final '
            f'(first: {drafts[0]})'
        )

    for item_id, item in items['en'].items():
        option_ids = [option['id'] for option in item.get('options', [])]
        if 'correctOptionId' in item and item['correctOptionId'] not in option_ids:
            blockers.append(f'{item_id}: correctOptionId is not an option')

        rubric = item.get('rubricByOption')
        if rubric is None:
            continue
        if set(rubric) != set(option_ids):
            blockers.append(f'{item_id}: rubric does not cover every option')
        for option_id, entry in rubric.items():
            if set(entry.get('scores', {})) != DIMENSIONS:
                blockers.append(f'{item_id}/{option_id}: rubric misses a dimension')

        if 'expectedAnswer' in item and not item['expectedAnswer']:
            blockers.append(f'{item_id}: expectedAnswer is empty')

    return blockers


def main():
    with open('assets/content/manifest.json', encoding='utf-8') as handle:
        manifest = json.load(handle)

    blockers = []
    version = manifest['contentPackVersion']
    if version.endswith('-draft'):
        blockers.append(f'manifest pack version is {version}')

    for domain in FILES:
        blockers.extend(audit_domain(domain, manifest))

    if blockers:
        print(f'Content release gate: {len(blockers)} blocker(s)')
        for blocker in blockers:
            print(f'  - {blocker}')
        return 1

    print('Content release gate: passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
