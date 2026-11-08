# Development workflow

Use this guide to locate responsibility, plan a focused change, and hand it off for
review. Complete [local setup](../CONTRIBUTING.md#local-setup) first. Apply
[AGENTS.md](../AGENTS.md) throughout.

## Find the smallest owning area

```sh
python3 scripts/workspace.py list
python3 scripts/workspace.py locate trip/Features/Trips/Models/Workspace/TripModel.swift --json
python3 scripts/workspace.py context Trips --json
python3 scripts/workspace.py impact trip/Features/Trips --json
```

Use `locate` for a known source path and `context` for its declared owner. Context
contains entry points, contracts, dependencies, consumers, and guides. Ownership is
declared in `scripts/architecture/app-ownership.json`; package edges are in
`Packages/TripKit/modules.json` and must match `Package.swift`.

Read skill candidates only when their `when` condition matches the task. Follow
dependency guides only for crossed contracts. Personal global skills are optional;
use repository contracts and SDK documentation when unavailable. See [Skills](Skills.md).

Scope a larger change before assigning work:

```sh
python3 scripts/workspace.py impact --base origin/main --head HEAD --json
python3 scripts/workspace.py impact --json
python3 scripts/workspace.py metrics --owner Trips --json
```

Without paths or a base, `impact` includes working-tree, staged, and untracked
changes. A base compares merge-base to head. Review unowned paths explicitly.
Suggested checks are not executed. The graph is conservative, not symbol
resolution. Treat lexical metrics as signals to inspect responsibility; they do
not relax the 100-line file and 20-line member limits.

## From task to review

1. Describe the observable improvement and existing entry point. For a small fix,
   use the PR description; for a substantial feature or cross-owner change, use
   [the task template](../templates/task.md).
2. Read the owner guide, inspect the flow, and establish the relevant source baseline.
3. Agree on crossed contracts before implementation. App composes live services;
   models receive contracts. Record a lasting dependency or persistence choice
   using [the decision template](../templates/decision.md).
4. Implement a coherent slice: value/contract → model → controller → view → local
   preview → host integration. Reuse existing domain operations and localize UI.
5. Apply [DesignSystem](DesignSystem.md) to UI work. Explain any geometry exception
   in the policy file and review loading, failure, accessibility, and adaptive states.
6. Run the relevant checks within the authorized scope using [Testing](Testing.md).
   Review adjacent workflows and update owning guidance with changed contracts.

Extend an existing owner when the user task belongs there. Create a feature only
when it has a distinct task, lifetime, and entry contract. Avoid a new module for
each screen or a protocol for each local value.

## Start a new feature

```sh
python3 scripts/workspace.py scaffold Journal --purpose 'Record notes about a trip'
# Inspect the proposed paths before writing:
python3 scripts/workspace.py scaffold Journal --purpose 'Record notes about a trip' --write
```

Scaffolding creates a model, struct controller, view with local previews, and guide.
It registers ownership and permits App composition. It does not connect navigation
or finish the feature. Inject services, implement the task, and use an existing
contextual entry point where possible. Run the source gate afterward.

Use scaffolding in your own checkout. It rejects collisions, escaped paths,
overwrites, and stale manifest snapshots, but it cannot transact with arbitrary
editors. If cleanup reports changed or partially written files, inspect them rather
than overwriting them. Keep the [feature templates](../templates/feature) focused on
structure and injection.

## Parallel changes

Give each worker an outcome, owned paths, crossing contracts, and check scope.
Prefer separate worktrees/checkouts. Assign one integrator for shared manifests,
target wiring, localization, and public API changes. Do not scaffold concurrently
against the same manifest.

At handoff, provide changed paths, contract differences, exact checks, and unresolved
cases. Review the integrated diff and check the combined revision. Isolate requested
build output when needed:

```sh
TRIP_BUILD_ROOT="$PWD/.build/worker-a" bash scripts/build.sh app Debug
```

Separate output paths do not isolate source edits. Run benchmarks without competing
workloads or source changes.

## AI-assisted changes

Start with the request, `AGENTS.md`, the owner context, and relevant guide. Specify
allowed paths, acceptance cases, privacy constraints, and verification scope.
Separate product requirements from implementation guesses. Inspect generated code
for cancellation, isolation, stable identity, persistence, and practical user value.

Keep Markdown useful for the next task: explain when to read it, where to edit,
which contracts to preserve, how to proceed, and which checks apply. Keep one owner
for each rule and link to it. Put temporary execution records in ignored
`.build/verification`; keep commit recaps and dated delivery reports out of guides.
Reusable framework methods belong in global guidance; Trip adoption belongs here.

## Automation

The [Quality workflow](../.github/workflows/quality.yml) uses GitHub-hosted runners.
Its Ubuntu lane runs Python tooling tests, workspace/skill/design-policy checks,
and changed-commit whitespace checks. Keep these checks portable.

To configure the native lane:

1. Confirm the GitHub-hosted `macos-latest` image supplies the required Xcode/SDKs
   and a macOS host meeting TripKit's deployment minimum.
2. Set `TRIP_TEST_DESTINATION` to an available iOS or visionOS simulator with one
   explicit `id` or `name`; use an explicit OS runtime with names when appropriate.
3. Set optional `TRIP_DEVELOPER_DIR` to the intended installed Xcode developer directory.
4. Set `TRIP_MACOS_CI_ENABLED` to `true`.
5. Inspect the first workflow run before making its checks required for merges.

The native preflight validates destination syntax, tools, SDK minimums, and host
macOS. Confirm that the configured simulator actually exists on the runner.
The lane separates source checks, app compilation, package behavior, algorithm
checks, and isolated app-model tests. Keep benchmarks and visual/device review
separate.

Keep workflow credentials read-only and use disposable hosted runners for public
PR code. See GitHub's [runner guidance](https://docs.github.com/en/actions/reference/security/secure-use#hardening-for-self-hosted-runners).
Use the checked-in workflow as the integration entry point;
[the source-check template](../templates/ci/source-checks.yml.template) is a smaller
manual example. Configure reviewer ownership, repository rules, and community
reporting contacts with real maintainer identities rather than inventing defaults.

## Capture a check result

```sh
python3 scripts/verify.py --kind source -- bash scripts/check.sh
python3 scripts/verify.py --kind compilation --platform iOS --configuration Debug -- bash scripts/build.sh app Debug
```

The wrapper runs exactly the supplied command and writes a unique JSON record
under `.build/verification`. It records exit status, revision/dirty state,
before/after content digests, timestamps, and toolchain. Use a new path inside
repository `.build` for `--output`. Treat a `running` record as incomplete and a
changed source digest as requiring review. Report results in the PR or delivery
message; do not turn the owning guide into a run log.
