# Development tools

Run `bash scripts/check.sh` for source-only checks. It runs architecture validation,
workspace references, localization, project skill names and references, SwiftSyntax auditing,
and diff whitespace validation; it never builds the app or
benchmarks algorithms. Tool output/caches belong in ignored `.build` directories.

| Entry point | Purpose |
| --- | --- |
| workspace.py | Discover owners, export AI context, scaffold a feature (dry-run default) |
| factory/ | Manifest-derived catalog and exclusive-write scaffolding |
| factory/skill-routes.json | Conditional project/global guidance by source owner; no personal install required |
| architecture/manifest_contracts.py | Exact package declarations and compiler/platform policy |
| check_architecture.py | Package graph/linkage, source manifests, app ownership |
| check_project_skills.py | Trip-only skill names, entrypoints, links, and size limits; no global dependencies |
| architecture/feature_boundaries.py | Feature dependencies and package-to-app references |
| architecture/swift_sources.py | Lexical source scanning, DEBUG preview exclusion |
| audit_sources.sh | Xcode SwiftSyntax interpreter entry point |
| SourceAudit/MemberAudit.swift | Physical member lengths and controller structure |
| audit_sources.swift | File lengths, syntax, preview presence, UIKit, skill limits |
| xcode_environment.sh | Process-local toolchain selection |
| build.sh | Requested focused package/app compilation |
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

When changing enforcement, run:

```sh
python3 -m unittest discover -s scripts -p test_architecture.py
bash scripts/check.sh
```

The audit combines its two Swift sources into a uniquely named temporary script
under `.build/audit`, then removes it. Concurrent checks cannot overwrite that
script. Respect explicit DEVELOPER_DIR and never change system toolchain selection.

See [Development](../docs/Development.md) for factory commands. `workspace.py`
requires only Python 3.10+ and no network. Full source checks require macOS and the
installed project Xcode for plutil and SwiftSyntax. Template generation does not
compile, add navigation, or run services. `workspace.py check` validates catalog
references and is part of the normal source gate.

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
