# Development workflow

Use this workflow to find the right owner, make a focused change, and verify it.
The workspace tools read the ownership manifests and provide optional scaffolding;
feature behavior lives in the existing Swift types.

## Contents

- [Find the smallest owning area](#find-the-smallest-owning-area)
- [From task to review](#from-task-to-review)
- [Start a new feature](#start-a-new-feature)
- [Parallel changes](#parallel-changes)
- [AI-assisted changes](#ai-assisted-changes)
- [Use this repository as a reference](#use-this-repository-as-a-reference)
- [Automation](#automation)

## Find the smallest owning area

```sh
python3 scripts/workspace.py list
python3 scripts/workspace.py locate trip/Features/Trips/Models/Workspace/TripModel.swift
python3 scripts/workspace.py context Trips
python3 scripts/workspace.py context TripDomain --json
python3 scripts/workspace.py doctor --json
bash scripts/check.sh
```

Context is generated from the enforcement manifests. It includes the owner,
dependencies, consumers, entry points, source files, required reading, and conditional
skill routes. `locate` accepts a source file or directory and resolves its exact
manifest owner, including paths planned inside an existing owner; it never guesses
from keywords. Unknown or ambiguous ownership is an error.
Use the JSON output as an AI context packet; attach the concrete task and relevant
files rather than pasting the entire repository. It contains paths and contracts,
not secrets or generated build artifacts. The checker verifies referenced guides
and entry points exist. It also validates project skill routes and dependency-guide
references without requiring any personal/global skill installation. Source ownership is authoritative in
`scripts/architecture/app-ownership.json`; package edges live in
`Packages/TripKit/modules.json` and must match `Package.swift`.

The packet's `skills.candidates` are choices with a `when` condition, not mandatory
bulk reading. `skills.workflow` points to the installed global `app-development`
skill for a feature spanning several layers. `dependencyGuides` are lookup paths
for contracts actually crossed. Read only relevant entries. If a global skill is
missing, follow repository contracts and verified SDK/documentation; do not copy
global guidance into this project. Routes live in `scripts/factory/skill-routes.json`.

Use the declared dependency graph to scope a change before assigning work:

```sh
python3 scripts/workspace.py impact trip/Features/Trips --json
python3 scripts/workspace.py impact --base origin/main --head HEAD --json
python3 scripts/workspace.py impact --json
python3 scripts/workspace.py metrics --owner Trips --json
```

`impact` reports direct owners, transitive consumers, relevant guides, and suggested
verification commands. Explicit paths may include deleted or planned sources.
`--base` compares the merge base with `--head`; without paths or a base it includes
working-tree, staged, and untracked changes. Unowned paths remain explicit review
work. This is conservative graph analysis, not symbol resolution or executed tests.
Package recommendations identify affected declared test targets; hosted test sources
and the TripModels plan map to App. Model-test commands contain an explicit simulator
placeholder that must be replaced with an available destination before execution.
`metrics` groups logical type/extension families and summarizes owner file sizes.
Its lexical counts are advisory: they help locate concentrated responsibilities,
not score quality or justify extra modules. The 100/20 limits remain unchanged.

`doctor` reads Python, Git, Xcode/SwiftSyntax, SDK minimums, shared schemes, and output
locations. It does not build, install, select a device, or change global Xcode state.
Use `doctor --require-ready --json` to fail when source or compilation prerequisites
are missing. SDK minimum checks do not pin an exact Xcode release or prove compilation.

## From task to review

1. Write a brief using [the task template](../templates/task.md). Identify the user
   task, observable benefit, existing entry point, owner, and acceptance cases.
2. Read that owner's guide and inspect the current behavior. Record the baseline
   source-check result and preserve unrelated working-tree changes.
3. Define contracts before crossing boundaries. Inject services through model
   initializers; App composes features and live services. Use a small decision
   record for a new package, dependency edge, or persistence strategy.
4. Implement a coherent vertical slice: value/contract → model → controller → view
   → local preview → host integration. Localize user-facing content.
   For UI work, apply [Trip's visual contract](DesignSystem.md), record why the
   text/color/spacing/motion roles fit, and review any new design-policy exception.
5. Run source checks. Run relevant existing tests, builds, benchmarks, or runtime
   checks within the user's requested scope. State each result separately.
6. Review data compatibility, async lifetime, accessibility, and adjacent flows.
   Document changed contracts, limitations, and recovery behavior in the PR.

Existing features receive new workflows in their current owner. A separate feature
is appropriate when it has its own user task, state lifetime, and entry contract.
Do not create a module for every screen or a protocol for every local value type.

## Start a new feature

```sh
python3 scripts/workspace.py scaffold Journal --purpose 'Record notes about a trip'
# Review the dry-run paths, then create the starter when appropriate:
python3 scripts/workspace.py scaffold Journal --purpose 'Record notes about a trip' --write
```

The command creates a model, struct controller, view with local previews, and
feature guide. It registers ownership and permits App composition. It rejects
existing owners, type collisions, invalid names, escaped destinations, and overwrites. It does not add
navigation or expose an unfinished screen. Implement the task, inject its services,
and connect an existing contextual entry point in App. Run `bash scripts/check.sh`.
New owners inherit the feature skill route. The generated guide identifies
composition, dependency, state-lifetime, acceptance, and verification work that
remains; scaffolding is not feature completion. If ownership changes while files
are being prepared, scaffolding rejects the stale snapshot and removes its newly
created files only if their identity and content still match this invocation.
Changed, replaced, or partially written files remain on disk and are reported for
review. Only scaffold in your own checkout: filesystem comparisons and subsequent
replace/removal operations are not transactions with arbitrary editors, so
coordinate manifest and generated-file edits.

The [feature templates](../templates/feature) are intentionally small. They encode
structure and injection, not a speculative CRUD framework. Existing domain models,
design components, and storage must be reused where their semantics match.

## Parallel changes

Assign each worker a concrete outcome, owning paths, contract, and verification
scope. Use separate checkouts/worktrees for independent writers. Name one integrator
for shared ownership manifests, package dependencies, project targets, localization,
and public contract changes; agree on those contracts before consumers implement them.
Do not run scaffolding concurrently against the same manifest. Its conflict checks
protect known writes but are not a filesystem transaction with arbitrary editors.

At handoff, provide the changed paths, contract differences, exact completed checks,
and unresolved cases. The integrator reviews the combined diff and reruns the affected
checks on the integrated revision. A passing worker result does not verify a later merge.
For requested build/test jobs, an absolute `TRIP_BUILD_ROOT` isolates build outputs:

```sh
TRIP_BUILD_ROOT="$PWD/.build/worker-a" bash scripts/build.sh app Debug
```

Separate output paths do not isolate source edits or make simultaneous benchmarks
comparable. Run benchmarks alone with the source unchanged. Source-audit temporary
scripts are unique; their caches remain local to each checkout.

## AI-assisted changes

- Start with `AGENTS.md`, the context packet, and the owner guide.
- Select conditional skills by the actual behavior being changed. Common engineering
  methods belong in global skills; Trip paths, contracts, and commands belong here.
- Specify allowed paths, acceptance cases, service/privacy constraints, and
  verification scope. Separate product requirements from implementation guesses.
- Treat generated code as a change requiring review. Inspect cancellation,
  actor isolation, stable identities, persistence, and real user benefit.
- Keep decisions in the repository, not solely in chat history. Update the guide
  and manifests in the same change when contracts move.
- Preserve existing edits; never claim a source audit compiled or rendered the app.

## Use this repository as a reference

Carry over the VCM conventions, ownership graph, source audits, task and decision
templates, and explicit composition pattern. Substitute the new product's domain,
service adapters, identifiers, entitlements, resource licenses, and UX. Trip's
assets, system integrations, and geography are product-specific.
Extract packages only when another consumer actually needs their public contract.
See [dependency injection](Dependencies.md), [test seams](Testing.md), and
[architecture decisions](decisions/README.md).

## Automation

`bash scripts/check.sh` is the source-only gate. It checks working-tree and staged
whitespace; use `--base <ref> --head <ref>` to also check committed changes from their
merge base. Tooling regression tests are a separate result, documented in [Testing](Testing.md).

The checked-in [Quality workflow](../.github/workflows/quality.yml) runs portable Python
tooling tests and changed-commit whitespace checks on GitHub-hosted Ubuntu. Its native
lane uses GitHub-hosted `macos-latest` and runs only when `TRIP_MACOS_CI_ENABLED` is
`true`. The workflow installs Python 3.12. Enable it only when the hosted image has the required Xcode/SDKs,
and an available simulator matching the `TRIP_TEST_DESTINATION` repository variable.
Use a destination valid for that image, such as a device name and explicit OS runtime.
Set optional `TRIP_DEVELOPER_DIR` to a specific installed Xcode developer directory;
otherwise the scripts use the selected Xcode without changing global selection.
`doctor --require-ready` fails when tool/SDK prerequisites are absent; the configured
simulator must also exist for model tests. The package's deployment minimums remain
authoritative; record the exact installed toolchain separately as hosted images change.

GitHub-hosted runners keep PR code in disposable environments. A PR-editable job
condition cannot protect a persistent personal runner from arbitrary workflow changes;
the repository uses no self-hosted runner for this lane. See GitHub's
[secure-use guidance](https://docs.github.com/en/actions/reference/security/secure-use#hardening-for-self-hosted-runners)
for the difference in isolation guarantees. The workflow keeps token access read-only
and does not add repository secrets for compilation or model tests.

The native lane separates source/tooling checks, iOS and visionOS compilation,
package behavior, deterministic algorithm correctness, and isolated app-model tests.
It uploads verification records. Benchmarks, signed-device checks, visual acceptance,
signing, and publishing remain separate. Adding the workflow file does not set
repository variables, establish hosted-image compatibility, activate remote CI,
or prove any job passed.
The older [source-check template](../templates/ci/source-checks.yml.template) is an optional
manual example; the checked-in Quality workflow is the current integration entry point.

Wrap an authorized command to retain its actual result:

```sh
python3 scripts/verify.py --kind source -- bash scripts/check.sh
python3 scripts/verify.py --kind compilation --platform iOS --configuration Debug -- bash scripts/build.sh app Debug
```

`verify.py` runs exactly the supplied argument vector and writes a unique record in
`.build/verification`. It records timestamps, exit status, Git revision/dirty state,
before/after content digests, toolchain, and declared evidence category. `--output`
accepts a new path inside repository `.build`; existing records and escaped/symlinked
destinations are rejected. A `running` record is incomplete. A changed source digest
requires review before attributing a result to a revision. Categories are caller-supplied;
command success never establishes unexecuted tests, visual quality, or device behavior.
