# 0001: Feature ownership and explicit composition

Status: accepted.

## Context

Trip has seven reusable package targets and growing app features. Small Swift files
help local reading, but a flat collection of model extensions and broad shared
permissions make ownership harder to follow. Concrete service defaults inside UI
models also make component previews depend on live infrastructure.

## Decision

Keep feature-oriented View–Controller–Model with structs for controllers and
MainActor UI models. Organize model files by workflow. Retain the seven package
targets with explicit dependency edges. App remains the composition and navigation
owner; AppTripServices supplies production Trips dependencies. The same feature
models accept local preview providers and later controlled test providers.

Give shared capabilities separate ownership entries. Enforce imports, source
boundaries, compiler settings, file/member limits, and guide references through
source checks. Generate contributor context from those manifests. Use small
templates for new features and record behavior/verification in task briefs.

## Alternatives and consequences

Moving every app feature into a package would create new public APIs and resource
boundaries without a demonstrated external consumer. Keep app feature boundaries
lexically enforced; compilation and review are still required for inferred member
dependencies. Extract another package when independent reuse or build ownership
justifies that cost.

A global service locator would hide lifetime and dependency information. Explicit
initializers make construction longer but keep service selection visible and
independently controllable. Feature models must not add live fallback defaults.

The scaffold is a source starter, not runtime feature discovery. Navigation remains
intentional and product-specific. Tests can be added at the documented seams later;
this decision does not claim compilation, runtime correctness, or test coverage.
