# Skill ownership and task selection

Use **one global `app-development` skill** for common app engineering. SwiftUI,
iPad, adaptive layouts, modernization, review, data, and system integrations are
topics inside that skill, not independent global entrypoints.

Trip keeps only its product contracts in `.agents/skills/trip-*`. Source checks,
context generation, and scaffolding work without personal global installations.

## Find the relevant contracts

```sh
python3 scripts/workspace.py locate trip/Features/Explore --json
python3 scripts/workspace.py context Explore --json
```

The context packet identifies owners, dependency guides, and conditional Trip
skills. Every global route points to `app-development`; its entrypoint selects
only the references needed for the actual task. Do not read every topic by default.
A simple copy edit needs no framework guidance.

| Task | Trip contract | Topic inside app-development |
| --- | --- | --- |
| State ownership and composition | `trip-swiftui-vcm` | Architecture, state, concurrency |
| Search, markers, camera, map chrome | `trip-map-decluttering` | Maps, gestures, performance |
| Route engine, sheets, framing, stops | `trip-routing` | Maps, navigation, presentations |
| Split navigation, scenes, platform integration | `trip-universal-app` | Adaptive layouts, windows, spatial input |
| Saved-data system surfaces | `trip-system-integrations` | App Intents, widgets, activities, intelligence |
| Trip previews and requested compilation | `trip-previews-build` | Previews, compiler diagnosis, verification |
| Trip target configuration and profiling | `trip-xcode-tooling` | Tooling and performance diagnosis |

## Maintain one source of common guidance

Reusable techniques extend the appropriate reference in `app-development`.
Trip paths, model names, UX choices, privacy rules, source limits, and commands
stay in project rules, owner guides, or the relevant Trip skill. Keep versions
in baseline/evidence content. Do not create another global specialist for a topic
already covered by the unified skill, or copy/symlink the global skill into Trip.

The installed global skill lives in the configured user skill directory; on this
workstation it is `~/.codex/skills/app-development`. Its standalone source package
is maintained separately and can be shared without Trip or private home-directory
resources. The user-wide ownership policy lives in `~/.codex/AGENTS.md`.
Historical third-party originals and migration backups stay outside all skill
discovery roots and outside the public package. Their earlier application to Trip
is recorded in [the applied review](reviews/apple-guidance-2026-10-24.md).

## Fallback and verification

If the global skill is unavailable, use Trip contracts, installed SDK declarations,
and primary documentation. Do not install a project-local substitute.
`workspace.py check` validates context paths and the single global route.
`check_project_skills.py` checks Trip-only entrypoints, metadata, references, and sizes.
Both run in `bash scripts/check.sh` without reading personal skill directories.

Live `skills/list` discovery checks active names, scope, and parsing errors.
Package validation checks self-contained links and a single entrypoint. Neither
proves perfect implicit selection; use realistic task walkthroughs and report
source checks, builds, and runtime verification separately.
