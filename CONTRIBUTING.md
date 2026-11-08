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
python3 scripts/workspace.py impact trip/Features/Trips --json
python3 scripts/workspace.py doctor --require-ready --json
```

[Development](docs/Development.md) covers task templates, scaffolding, review, and
coordination across owners. [Dependencies](docs/Dependencies.md) describes service
lifetimes; [Testing](docs/Testing.md) identifies test seams. Select skills by the
actual task using [Skills](docs/Skills.md). Personal global skills are optional for
repository tooling and must not be copied into the project.

## Verify at the right level

| Check | Command | What it establishes |
| --- | --- | --- |
| Source gate | `bash scripts/check.sh` | Ownership, references, localization, design policy, source limits, named preview syntax, UIKit exclusion, local/staged whitespace |
| Architecture | `python3 scripts/check_architecture.py` | Package graph and app source boundaries |
| Localization | `python3 scripts/check_localization.py` | Catalog coverage and generated-resource consistency |
| Project skills | `python3 scripts/check_project_skills.py` | Skill names, references, and size limits |
| Portable tooling regression suite | `python3 -m unittest discover -s scripts -p 'test_*.py'` | Ownership, context, scaffolding, policy, impact, provenance, and comparison-tool behavior |
| Complete tooling suite | `bash scripts/test.sh tooling` | Python tests plus executable SwiftSyntax checker fixtures; no app target build |
| Read-only prerequisites | `python3 scripts/workspace.py doctor --require-ready --json` | Python/tools, shared scheme, and SDK minimums; no compilation |

Use `bash scripts/check.sh --base <ref> --head <ref>` to include committed whitespace
changes from the merge base. `workspace.py impact --base <ref> --json` lists direct
owners and transitive consumers; unowned paths need review. Its commands are suggestions,
not executed checks. `workspace.py metrics --owner Trips --json` reports advisory
file/type concentration without changing the 100/20 limits.

Source audits do not type-check Swift or exercise the UI. For agent tasks, run
builds and benchmarks only when requested. Choose the smallest relevant target:

```sh
bash scripts/build.sh TripDomain Debug
bash scripts/build.sh TripIntegrations Debug
bash scripts/build.sh app Debug
bash scripts/build.sh visionOS Debug
bash scripts/build.sh models Debug
```

Package targets are `TripLocalization`, `TripDomain`, `TripPlaces`, `TripRouting`, `MapEngine`,
`TripStorage`, `TripIntelligence`, and `TripIntegrations`. Package commands build
for the host Mac. App commands use generic simulator destinations with signing
disabled. `models` builds the hosted `TripAppTests` bundle without executing tests.
Use `Release` instead of `Debug` for an optimized app/package build.

The scripts honor `DEVELOPER_DIR` and select Xcode for their own process without
changing global `xcode-select`. Output defaults to ignored `.build` directories;
an absolute `TRIP_BUILD_ROOT` isolates app/package build and test output.
Unsigned app output is for compilation checks; use the signed Xcode scheme for
runtime work involving existing App Group data. See [tooling](scripts/README.md).

Requested routing tests are documented in [Directions](DIRECTIONS.md), standalone
checks in [Performance](Performance/README.md), and device profiling in
[Performance validation](PERFORMANCE.md). Compilation does not verify gestures,
accessibility, signing, or real service responses.

Run requested package tests with `bash scripts/test.sh package`. Hosted model tests
use `bash scripts/test.sh models 'platform=iOS Simulator,id=<simulator-UDID>'` or
`TRIP_TEST_DESTINATION`; the `TripModels` test plan isolates live service startup.
The existing hosted `TripSiriEvaluations` suite remains separate. See [Testing](docs/Testing.md)
for fixture ownership, current coverage, and remaining behavior gaps.

`python3 scripts/verify.py --kind <category> -- <command> ...` records the exact
command result, revision/dirty state, source digests, and toolchain in a new JSON
file under `.build/verification`. Include platform/configuration for build evidence.
The result only establishes what that command checked; retain unverified categories.

The checked-in [Quality workflow](.github/workflows/quality.yml) provides a portable
tooling lane and a conditional GitHub-hosted `macos-latest` lane. Enable native jobs
only when that image supplies the required SDKs and the explicitly
configured simulator. `doctor --require-ready` rejects missing tools/SDKs. Repository
variables control enablement, optional Xcode selection, and the simulator destination.
The workflow installs Python 3.12; no personal runner is used.
This follows GitHub's [runner isolation guidance](https://docs.github.com/en/actions/reference/security/secure-use#hardening-for-self-hosted-runners).
This checkout does not establish remote activation or a passing CI run.
[Development](docs/Development.md#automation) documents setup and scope.

## Commit and review

Keep commits focused on a behavior or contract. Preserve unrelated local edits.
Coordinate public API and manifest changes across consumers; separate checkouts
help avoid conflicting edits. Assign one integrator for shared manifests and target
wiring, agree on cross-owner contracts first, and verify the combined revision after
handoff. Separate build directories do not isolate concurrent source edits.
Do not publish or push unless requested.

A review should explain the user-visible result, the owning component, compatibility
risks, and the exact verification performed. Use the repository's task, decision,
and pull-request templates when appropriate.
