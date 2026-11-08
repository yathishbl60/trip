# Select and maintain task guidance

Use this guide when choosing instructions for a task or updating reusable guidance.
Repository Markdown should act as task guidance: a clear purpose, owning paths,
contracts, steps, and relevant checks. Keep temporary run reports out of it.

## Find the relevant contracts

```sh
python3 scripts/workspace.py locate trip/Features/Explore --json
python3 scripts/workspace.py context Explore --json
```

Read the owner guide and only the dependency guides crossed by the task. Context
skill candidates have a `when` condition; do not load every candidate by default.
A wording correction needs its owning document, not a framework review.

Use the global `app-development` skill for common native app engineering when it is
installed. SwiftUI, adaptive layouts, concurrency, review, and system integration
are topics within it. Trip's discoverable skills in `.agents/skills/trip-*` contain
local adoption contracts.

| Task | Trip skill | Global app-development topic |
| --- | --- | --- |
| State ownership and composition | `trip-swiftui-vcm` | Architecture, state, concurrency |
| Search, markers, camera, map chrome | `trip-map-decluttering` | Maps, gestures, performance |
| Route engine, sheets, framing, stops | `trip-routing` | Maps, navigation, presentations |
| Split navigation, scenes, platform integration | `trip-universal-app` | Adaptive layouts, windows, spatial input |
| Saved-data system surfaces | `trip-system-integrations` | App Intents, widgets, activities, intelligence |
| Previews and requested compilation | `trip-previews-build` | Previews, compiler diagnosis, verification |
| Target configuration and profiling | `trip-xcode-tooling` | Tooling and performance diagnosis |

If a global skill is unavailable, continue with Trip contracts, installed SDK
declarations, and primary documentation. Do not install or vendor a project-local
copy. Source checks, context generation, and scaffolding must work without personal
skill directories.

## Put each instruction in its owner

Keep Trip paths, model names, UX choices, data rules, source limits, and commands
in project guides or Trip skills. Extend global guidance for reusable framework
methods. Do not copy or symlink global skills into the repository or create
overlapping global specialists.

Keep formal `SKILL.md` entrypoints in their existing discovery roots; use linked
project guides for detailed procedures. Name skills by responsibility and put
platform minimums in their content. Keep historical archives outside discovery
roots. Each file in a Trip project skill must remain within 50 physical lines.

Runtime Siri skills under `trip/Resources/Skills.skillsbundle` are application
resources. Edit them using [System integrations](../SYSTEM-INTEGRATIONS.md); preserve
tool identifiers, confirmation rules, and resource metadata. Do not rewrite them
as contributor documentation.

## Check a guidance change

```sh
python3 scripts/workspace.py check
python3 scripts/check_project_skills.py
```

Keep owner-guide references, entry points, and conditional routes synchronized.
Validate realistic task selection as well as links: packing cancellation should
lead to Trips/concurrency; a Duo map issue to Explore/adaptive guidance; a hosted
test build to App/build tooling. Read [Engineering safeguards](EngineeringLessons.md)
for cross-cutting Trip contracts. Store command outcomes in the PR, not this guide.
