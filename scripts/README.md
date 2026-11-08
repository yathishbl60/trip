# Use and maintain repository tools

Use this guide when choosing a script, changing contributor tooling, or diagnosing
a failed check. Run commands from the repository root. Complete
[local setup](../CONTRIBUTING.md#local-setup) first: Python 3.10+ is required, and
full source checks need macOS with the selected project Xcode.

## Choose an entry point

| Task | Entry point |
| --- | --- |
| Find ownership, context, impact, prerequisites, or metrics | `python3 scripts/workspace.py <command>` |
| Run the full source gate | `bash scripts/check.sh` |
| Check package edges and app boundaries | `python3 scripts/check_architecture.py` |
| Check context paths and manifest references | `python3 scripts/workspace.py check` |
| Check project skill metadata, paths, and size | `python3 scripts/check_project_skills.py` |
| Check string catalogs and generated resources | `python3 scripts/check_localization.py` |
| Check scoped design policy | `python3 scripts/check_design_system.py` |
| Check whitespace in working tree/index | `python3 scripts/check_whitespace.py` |
| Parse Swift limits, preview syntax, and controller structure | `bash scripts/audit_sources.sh` |
| Compile app/package/model bundle when requested | `bash scripts/build.sh <target> <configuration>` |
| Execute requested tooling/package/model tests | `bash scripts/test.sh <suite>` |
| Run requested algorithm checks or benchmarks | `bash scripts/performance.sh <command>` |
| Render the actual annotation gallery when requested | `bash scripts/annotation-preview.sh` |
| Record an explicitly supplied command | `python3 scripts/verify.py --kind <category> -- <command> ...` |

The full source gate includes whitespace, architecture, workspace references,
project skills, localization, design policy, and SwiftSyntax. It does not build
the app or run benchmarks. Use [Testing](../docs/Testing.md) for portable checks
and exact compilation/test commands.

## Find context and scope

```sh
python3 scripts/workspace.py locate trip/Features/Trips --json
python3 scripts/workspace.py context Trips --json
python3 scripts/workspace.py impact --base origin/main --head HEAD --json
python3 scripts/workspace.py doctor --require-ready --json
python3 scripts/workspace.py metrics --owner Trips --json
```

Use `impact` without paths or a base to include working-tree, staged, and untracked
changes. Inspect unowned paths. Suggested commands are not executed; replace any
simulator placeholder before use. Treat metrics as advisory lexical signals.

The doctor reads tools, schemes, SDK minimums, and output locations without
building or changing global Xcode selection. `--require-ready` fails when source
or compilation prerequisites are missing. Check runtime availability and host OS
separately before executable checks. Follow [Development](../docs/Development.md)
for scaffolding and coordinated ownership changes.

## Maintain contracts at their source

| Contract | Owning files |
| --- | --- |
| App ownership and feature dependencies | `scripts/architecture/app-ownership.json` |
| Package graph | `Packages/TripKit/modules.json`, `Packages/TripKit/Package.swift` |
| Compiler/platform declaration checks | `scripts/architecture/manifest_contracts.py` |
| Conditional guidance selection | `scripts/factory/skill-routes.json` |
| Context/scaffolding/impact/doctor/metrics | `scripts/factory/` |
| Feature boundary scanning | `scripts/architecture/feature_boundaries.py`, `swift_sources.py` |
| Swift member and preview parsing | `scripts/SourceAudit/`, `scripts/audit_sources.swift` |
| Visual policy and exceptions | `scripts/design_system_policy.json` |
| Process-local Xcode selection | `scripts/xcode_environment.sh` |
| Hosted test destination syntax | `scripts/test_destination.sh` |

Keep unknown source folders, overlapping owners, cycles, and forbidden package-to-app
references as failures. Lexical checks cannot resolve every inferred Swift
dependency; retain compilation and code review. Keep personal global skill
installations and network access out of repository source checks.

For design exceptions, record the rule, exact path, reason, and expected code-line
occurrences. Geometry notes need production anchors. Additional literals remain
checked independently; stale exceptions should fail. Do not treat palette math or
lexical rules as rendered accessibility checks.

## Control toolchain and outputs

Set `DEVELOPER_DIR` explicitly when several Xcodes are installed. Scripts respect
it and never change global `xcode-select`. Keep generated output in ignored
`.build` directories. An absolute `TRIP_BUILD_ROOT` isolates app/package build
and test output; source-audit caches, performance reports, and verification records
retain their own repository-local paths.

Source auditing assembles a uniquely named temporary script under `.build/audit`
and removes it afterward. Preserve this isolation when changing the audit runner.
Use separate checkouts for concurrent source writers; output directories do not
isolate edits.

Unsigned app builds are compilation artifacts. Do not install them over a valued
signed Trip/App Group installation. Follow [signing setup](../SYSTEM-INTEGRATIONS.md#signed-run-setup)
for runtime work and use disposable simulator data for experiments.

## Record and interpret checks

```sh
bash scripts/check.sh --base origin/main --head HEAD
python3 scripts/verify.py --kind source -- bash scripts/check.sh
```

The whitespace range starts at the merge base. Verification categories are
`source`, `tooling`, `compilation`, `executable`, and `performance`. The wrapper
preserves the command's exit status and writes unique JSON containing command,
revision, dirty state, source digests, timestamps, and toolchain. Supply
`--platform` and `--configuration` for meaningful build identity. Explicit
`--output` paths must be new files inside repository `.build`.

Review incomplete `running` records and changed source digests before using a
result. Report only what the command exercised. Put outcomes in the PR, leaving
these guides as reusable instructions.

When changing enforcement, choose relevant existing tooling tests and the source
gate within the authorized scope. Keep Python tests portable; SwiftSyntax fixture
execution needs Xcode. Do not add unrelated tests or targets.

For Siri scenario compilation, use the dedicated
[evaluation guide](../Performance/SiriEvaluations/README.md). For GitHub workflow
variables and runner requirements, use [Automation](../docs/Development.md#automation).
