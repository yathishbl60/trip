# Feature ownership and explicit composition

Use this decision when placing new behavior, choosing a service lifetime or
considering package extraction. Small source files help reading, but do not by
themselves define ownership or make workflows independent.

## Guiding decision

Keep feature-oriented View–Controller–Model: views render, struct controllers
forward actions, and MainActor models own mutable UI behavior. Organize model files
by workflow. App owns composition and cross-feature navigation; AppTripServices
selects production Trips providers. The same feature models accept local preview
providers and controlled test implementations.

Keep package edges explicit and public APIs small. The current eight-target graph
is in [Architecture](../../ARCHITECTURE.md). Shared capabilities have separate
manifest owners rather than broad permission to reach any app code. Generate
contributor context from those enforced manifests.

## Why this boundary

Moving every feature into a package adds public APIs and resource boundaries
without necessarily creating useful reuse or independent work. App feature
boundaries are checked lexically; compilation and review still assess inferred
dependencies. Extract a package when concrete consumers or independent build
ownership justify the cost.

A global service locator hides selection and lifetime. Explicit initializers make
construction longer but keep availability, failure and cancellation policy visible.
Feature models must not add live fallback defaults. See [Dependencies](../Dependencies.md).

## Apply the decision

1. Resolve the owning source area with `workspace.py locate` or `context`.
2. Prefer the existing workflow owner; define a focused model when state has its
   own lifetime and coherent actions.
3. Put reusable values/contracts in the owning package and live selection in App.
4. Update manifests and owning guides with boundary changes; keep shared code free
   of feature and app dependencies.
5. Use local fixtures and the scoped checks in [Contributing](../../CONTRIBUTING.md).

The scaffold is a source starter, not runtime feature discovery. Navigation remains
intentional and product-specific. File/member limits and advisory metrics support
review; they are not reasons to split a coherent responsibility artificially.
