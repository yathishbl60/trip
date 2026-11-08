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
discovery roots and outside the public package.

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

## Task selection review

The [engineering lessons](EngineeringLessons.md) map demonstrated problems to their
owning contracts and checks. Use these concrete walkthroughs when changing routing:

| Example task | Relevant selection | Keep outside scope |
| --- | --- | --- |
| Cancel a packing request when its review closes | Trips context, trip-swiftui-vcm, app-development state/concurrency | Map layout and target configuration |
| Fix a Duo control after unfolding | Explore/App context, trip-map-decluttering and trip-universal-app, adaptive/map references | New custom controls or navigation redesign |
| Reuse native place conversion in another client | TripPlaces context, app-development architecture | App-owned appearance and autocomplete state |
| Diagnose a hosted model-test build | App context, trip-previews-build and trip-xcode-tooling, compiler/verification references | Physical Siri evaluation |
| Correct wording in a guide | Owning document | Framework skill bulk reading |

These are reviewed selection examples, not a claim of automated skill-discovery
accuracy. Repository route tests validate the catalog; actual task selection still
requires judgment against the request and available evidence.
