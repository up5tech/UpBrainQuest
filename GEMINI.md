# GEMINI.md

This project's engineering contract lives in **[AGENTS.md](./AGENTS.md)**. Read it
before making changes — it is the single source of truth and is not duplicated here.

## Quick reference

```sh
# A system HTTP proxy breaks the test runner and builds on this machine.
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter test

dart run build_runner build                        # regenerate *.g.dart
dart format --output=none --set-exit-if-changed .  # formatting is enforced
flutter test                                       # host suite
flutter test integration_test/ -d <device-id>      # on-device suite
```

## Non-negotiables

- Fully offline: no backend, no runtime network, no analytics, no remote assets.
- One phase at a time; do not start the next phase while the current one fails.
- Design tokens only — no literal colours, spacing, or radii in widget code.
- `lib/domain/` is pure Dart. Widgets never touch the database.
- Never present placeholder data as real progress.

See [AGENTS.md](./AGENTS.md) for the full rules, architecture, and gotchas.
