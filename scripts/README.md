# Development tools

Run `bash scripts/check.sh` for source-only checks. It runs architecture validation,
workspace references, localization, scoped design policy, project skill names and
references, SwiftSyntax auditing, and diff whitespace validation; it never builds the app or
benchmarks algorithms. Tool output/caches belong in ignored `.build` directories.

| Entry point | Purpose |
| --- | --- |
| workspace.py | Discover owners/context, report change impact/prerequisites/metrics, scaffold a feature (dry-run default) |
| factory/ | Manifest-derived catalog and exclusive-write scaffolding |
| factory/impact.py | Direct owners and transitive consumers for explicit paths or Git changes |
| factory/doctor.py | Read-only environment, SDK minimum, scheme, and output diagnostics |
| factory/metrics.py | Advisory owner sizes and logical type/extension families |
| factory/skill-routes.json | Conditional project/global guidance by source owner; no personal install required |
| architecture/manifest_contracts.py | Exact package declarations and compiler/platform policy |
| check_architecture.py | Package graph/linkage, source manifests, app ownership |
| check_project_skills.py | Trip-only skill names, entrypoints, links, and size limits; no global dependencies |
| architecture/feature_boundaries.py | Feature dependencies and package-to-app references |
| architecture/swift_sources.py | Lexical source scanning, DEBUG preview exclusion |
| audit_sources.sh | Xcode SwiftSyntax interpreter entry point |
| SourceAudit/MemberAudit.swift | Physical member lengths and controller structure |
| SourceAudit/PreviewAudit.swift | Real preview macros with nonempty, distinct names per file |
| audit_sources.swift | File lengths, syntax, named preview presence, UIKit, skill limits |
| check_design_system.py | Scoped literal-style rules, geometry anchors, spacing, and reference palette contrast |
| check_whitespace.py | Working-tree/index whitespace and optional committed base/head range |
| verify.py | Run an explicit command and retain revision/toolchain/result evidence in JSON |
| xcode_environment.sh | Process-local toolchain selection |
| build.sh | Requested package/app compilation or model-test bundle build-only verification |
| test.sh | Requested tooling, package, or hosted app-model test execution |
| test_source_audit.sh | Executable SwiftSyntax preview-audit fixtures; no app target compilation |
| performance.sh | Requested standalone checks and benchmark report |
| annotation-preview.sh | Requested actual SwiftUI annotation gallery rendering |

`build.sh app` disables signing for compilation verification. Do not install that
unsigned product over a Trip simulator installation with App Group data: removing
the entitlement can remove its shared container. Use the existing signed Xcode
scheme for runtime checks and back up simulator app/group data before replacement.

The source ownership manifest is `scripts/architecture/app-ownership.json`; package edges are
in `Packages/TripKit/modules.json`. Unknown source folders, overlapping owners,
cycles, and forbidden direct type references fail the check. Lexical analysis is
not type checking and cannot establish dependencies through inferred expressions;
review and compilation remain necessary. SwiftSyntax audits parse all authored
Swift sources, including Performance and scripts, without compiling app targets.

When changing enforcement, run the focused Python suite, then the complete tooling
and source gates within the authorized verification scope:

```sh
python3 -m unittest discover -s scripts -p 'test_*.py'
bash scripts/test.sh tooling
bash scripts/check.sh
```

The Python suite is portable and does not compile Swift. `test.sh tooling` additionally
executes SwiftSyntax fixtures using Xcode's host libraries. These test the checker;
neither result executes Trip's application behavior. App/package tests and the
standalone algorithm harness are described in [Testing](../docs/Testing.md).

The audit combines its Swift sources into a uniquely named temporary script
under `.build/audit`, then removes it. Concurrent checks cannot overwrite that
script. Respect explicit DEVELOPER_DIR and never change system toolchain selection.

See [Development](../docs/Development.md) for factory commands. `workspace.py`
requires only Python 3.10+ and no network. Full source checks require macOS and the
installed project Xcode for plutil and SwiftSyntax. Template generation does not
compile, add navigation, or run services. `workspace.py check` validates catalog
references and is part of the normal source gate.

## Scope work and record verification

```sh
python3 scripts/workspace.py locate trip/Features/Trips --json
python3 scripts/workspace.py context Trips --json
python3 scripts/workspace.py impact trip/Features/Trips --json
python3 scripts/workspace.py impact --base origin/main --head HEAD --json
python3 scripts/workspace.py doctor --require-ready --json
python3 scripts/workspace.py metrics --owner Trips --json
bash scripts/check.sh --base origin/main --head HEAD
python3 scripts/verify.py --kind tooling -- python3 -m unittest discover -s scripts -p 'test_*.py'
```

Without paths or a base, `impact` includes working-tree, staged, and untracked paths.
A base uses the merge-base-to-head range. It reports unmapped paths and suggests
commands without executing them. Package suggestions identify affected declared test
targets; App/Trips changes and hosted model-test paths suggest `TripAppTests` with an
explicit simulator placeholder. Replace that placeholder before running the command.
Metrics are lexical signals for review, including
extension concentration; they do not establish complexity, defects, or exemptions
from the 100/20 source limits. `doctor` reports prerequisites without building or
changing global selection. `--require-ready` exits nonzero if source/compilation
prerequisites are missing. Its SDK comparison checks deployment minimums; keep the
exact reviewed Xcode build in CI configuration and captured evidence.

`verify.py` accepts `source`, `tooling`, `compilation`, `executable`, or `performance`
as the declared category. It preserves the command's exit status and writes unique
JSON evidence under `.build/verification`, including revision, dirty state, content
digests before/after, timestamps, and toolchain. Use `--configuration` and `--platform`
for meaningful build/test identity. Explicit `--output` destinations must be new paths
inside repository `.build`. A `running` record is incomplete; changed source digests
and reported unverified categories must remain visible in delivery summaries.

`build.sh` and `test.sh` honor an absolute `TRIP_BUILD_ROOT` for independent build
outputs; the default is repository `.build`. Source audit caches, performance output,
and verification records retain their own repository-local paths. Use separate
checkouts for concurrent source writers and one integrator for shared manifests.

## Design policy changes

Each exception in `design_system_policy.json` names a rule and source path, a reason,
and exact code-line occurrences with expected counts. Additional literals in that
file are checked independently; removed or changed reviewed occurrences fail as stale.
Geometry notes need a reason and anchors found in production code. Balanced preview
closures, comments, and strings are excluded without dropping later production code.
These bounded lexical rules and solid-color contrast calculations do not establish
rendered accessibility, native materials, animation behavior, or useful preview coverage.

See [Skill ownership and selection](../docs/Skills.md) for task-specific context.
Global SDK review and specialist synchronization tools live with the global skill.
Repository checks do not require or edit personal skills or access the network.
`bash scripts/check_siri_evaluations.sh` is an optional, requested compilation of
the [prepared Siri scenarios](../Performance/SiriEvaluations/README.md). It uses
the iPhoneOS SDK and Swift Testing macros without creating a target or driving Siri.
`bash scripts/build_siri_evaluations.sh Debug` compiles and links their dedicated
target plus the host and widgets for generic iOS using `build-for-testing`.
Neither script executes scenarios. Device testing requires its own request.
Use `workspace.py locate <path> --json` for exact source ownership.
`workspace.py context <Owner> --json` includes dependency guides and conditional skill suggestions.

The checked-in [Quality workflow](../.github/workflows/quality.yml) separates portable
tooling from the opt-in GitHub-hosted `macos-latest` lane. Enable the native lane only
when the hosted image has the required SDKs and configured simulator; the doctor gate
rejects missing tool/SDK prerequisites. No personal/self-hosted runner is used.
Repository variables and remote activation remain external setup steps, and no remote
run is established by this checkout. See [Development](../docs/Development.md#automation)
and GitHub's [secure-use guidance](https://docs.github.com/en/actions/reference/security/secure-use#hardening-for-self-hosted-runners).
