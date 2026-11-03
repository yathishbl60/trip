# Contributing to Trip

Use the shared `trip` scheme in `trip.xcodeproj`. Local packages resolve from
`Packages/TripKit`; source work needs no remote package registry or private service.
Read [project rules](AGENTS.md) and the [guide for your task](docs/README.md).

## Make a change

1. Identify the behavior and owner. Use the commands below to find its source,
   contracts, consumers, and relevant guides.
2. Run `bash scripts/check.sh` to establish the source baseline.
3. Follow the existing view → struct controller → model flow. Use local previews
   and inject services through the app composition root.
4. Update the owning guide when behavior or contracts change. Keep shared module
   and ownership manifests aligned with deliberate boundary changes.
5. Run source checks again. Report compilation, executable checks, and visual
   verification separately when they are requested.

```sh
python3 scripts/workspace.py list
python3 scripts/workspace.py locate trip/Features/Trips --json
python3 scripts/workspace.py context Trips --json
```

[Development](docs/Development.md) covers task templates, scaffolding, review, and
coordination across owners. [Dependencies](docs/Dependencies.md) describes service
lifetimes; [Testing](docs/Testing.md) identifies test seams. Select skills by the
actual task using [Skills](docs/Skills.md). Personal global skills are optional for
repository tooling and must not be copied into the project.

## Verify at the right level

| Check | Command | What it establishes |
| --- | --- | --- |
| Source gate | `bash scripts/check.sh` | Ownership, workspace references, localization, source limits, previews, UIKit exclusion, whitespace |
| Architecture | `python3 scripts/check_architecture.py` | Package graph and app source boundaries |
| Localization | `python3 scripts/check_localization.py` | Catalog coverage and generated-resource consistency |
| Project skills | `python3 scripts/check_project_skills.py` | Skill names, references, and size limits |
| Checker regression suite | `python3 -m unittest discover -s scripts -p test_architecture.py` | Required when changing enforcement code |

Source audits do not type-check Swift or exercise the UI. For agent tasks, run
builds and benchmarks only when requested. Choose the smallest relevant target:

```sh
bash scripts/build.sh TripDomain Debug
bash scripts/build.sh TripIntegrations Debug
bash scripts/build.sh app Debug
bash scripts/build.sh visionOS Debug
```

Package targets are `TripLocalization`, `TripDomain`, `TripRouting`, `MapEngine`,
`TripStorage`, `TripIntelligence`, and `TripIntegrations`. Package commands build
for the host Mac. App commands use generic simulator destinations with signing
disabled. Use `Release` instead of `Debug` for an optimized build.

The scripts honor `DEVELOPER_DIR` and select Xcode for their own process without
changing global `xcode-select`. Output stays in ignored `.build` directories.
Unsigned app output is for compilation checks; use the signed Xcode scheme for
runtime work involving existing App Group data. See [tooling](scripts/README.md).

Requested routing tests are documented in [Directions](DIRECTIONS.md), standalone
checks in [Performance](Performance/README.md), and device profiling in
[Performance validation](PERFORMANCE.md). Compilation does not verify gestures,
accessibility, signing, or real service responses.

## Commit and review

Keep commits focused on a behavior or contract. Preserve unrelated local edits.
Coordinate public API and manifest changes across consumers; separate checkouts
help avoid conflicting edits. Do not publish or push unless requested.

A review should explain the user-visible result, the owning component, compatibility
risks, and the exact verification performed. Use the repository's task, decision,
and pull-request templates when appropriate.
