# Development workflow

Use this workflow to find the right owner, make a focused change, and verify it.
The workspace tools read the ownership manifests and provide optional scaffolding;
feature behavior lives in the existing Swift types.

## Contents

- [Find the smallest owning area](#find-the-smallest-owning-area)
- [From task to review](#from-task-to-review)
- [Start a new feature](#start-a-new-feature)
- [AI-assisted changes](#ai-assisted-changes)
- [Use this repository as a reference](#use-this-repository-as-a-reference)
- [Automation](#automation)

## Find the smallest owning area

```sh
python3 scripts/workspace.py list
python3 scripts/workspace.py locate trip/Features/Trips/Models/Workspace/TripModel.swift
python3 scripts/workspace.py context Trips
python3 scripts/workspace.py context TripDomain --json
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

`bash scripts/check.sh` is the source-only gate for local work and a macOS CI
runner with the required Xcode installed. The repository does not provision a
runner. [The opt-in workflow template](../templates/ci/source-checks.yml.template)
uses a dedicated `trip-xcode` runner label; copy it into `.github/workflows` only
after provisioning that runner. Never run untrusted fork jobs on a personal runner.
Builds, performance jobs, signing, and publishing are explicit separate steps.
