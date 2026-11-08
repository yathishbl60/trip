# Test ownership and evidence

Trip has portable contributor-tool tests, SwiftSyntax checker fixtures, package
tests, a standalone production-algorithm harness, and hosted test targets. The
dedicated `TripSiriEvaluations` hosted target already existed for system integration
contracts. `TripAppTests` adds deterministic general app-model tests using the
`TripModels` test plan; it does not replace Siri evaluations or UI/device review.
Source audits parse Swift and enforce contracts without executing app behavior.

## Run the intended check

```sh
# Portable Python tooling only; no Swift compilation or app execution.
python3 -m unittest discover -s scripts -p 'test_*.py'

# Python tooling plus executable SwiftSyntax checker fixtures on macOS.
bash scripts/test.sh tooling

# Public package behavior on the host Mac.
bash scripts/test.sh package

# Build the hosted model bundle for generic iOS Simulator without running it.
bash scripts/build.sh models Debug

# Execute model tests only on an explicitly chosen simulator.
bash scripts/test.sh models 'platform=iOS Simulator,id=<simulator-UDID>'

# Production algorithm correctness; neither command runs timing workloads.
bash scripts/performance.sh check
bash scripts/performance.sh system-check
```

Builds, executable tests, benchmarks, and runtime checks stay within the requested
verification scope. `TRIP_TEST_DESTINATION` can supply the model-test destination;
no device is selected implicitly. `TRIP_BUILD_ROOT` must be an absolute path and
isolates app/package build and test outputs when needed. Do not use a simulator containing valued
Trip/App Group data for unsigned test installation; preserve signed runtime data.

Wrap any authorized command with `python3 scripts/verify.py --kind <category> -- ...`
to retain command identity, exit status, source snapshots, and toolchain. Add the
platform/configuration for builds. A source pass, compiled bundle, passing test suite,
and visual/device acceptance are separate results. A checked-in test or configured
CI job is not evidence that the current revision passed it.

The optional native CI lane uses GitHub-hosted `macos-latest`. Enable it only when
the image supplies the required SDKs and the configured simulator; the doctor gate
fails on missing tool/SDK prerequisites. Hosted-image compatibility, repository-variable
enablement, remote activation, and job results remain separate from checked-in tests.
This avoids running PR-controlled code on a persistent personal runner; see GitHub's
[runner isolation guidance](https://docs.github.com/en/actions/reference/security/secure-use#hardening-for-self-hosted-runners).

## Hosted model isolation and current coverage

[TripModels.xctestplan](../TestPlans/TripModels.xctestplan) selects `TripAppTests` and
sets `TRIP_MODEL_TEST_HOST=1`. In Debug, the app entry renders an empty host and skips
live control installation instead of starting `ContentView` and production services.
Tests import the host using `@testable import trip`, construct their own models and
providers, and do not copy app sources into the test target or widen public APIs.
The flag has no effect in Release. Use the shared `TripAppTests` scheme/test plan
so the isolation environment reaches the hosted process.

The current suites cover request URL parsing; missing/deleted navigation targets;
preferred active-window delivery; restoration and superseded requests; editing
protection while loading; checklist draft cancellation and current-data commits;
packing review identity, capacity, and stale itinerary rejection; and propagation
of host callbacks. Library lifetime cases suspend saves and complete them out of order,
check latest-revision publication, retain changes through failure/retry, and reject an
obsolete failure after a newer success. Packing lifetime cases complete canceled or
superseded AI-provider requests late and verify that they cannot publish old suggestions.
Fixtures use controlled stores and local service implementations.
These checks do not evaluate live AI output, native sheets, gestures, accessibility,
MapKit rendering, or actual multi-window scene delivery.

Package tests currently cover `TripRouting`, checklist domain editing in `TripDomain`,
and exported place conversion/classification in `TripPlaces`. The standalone
[Performance harness](../Performance/README.md) supplies broader deterministic domain,
scheduling, map-layout, and persistence-value coverage using production files.
That harness uses `TRIP_STANDALONE`; package tests and app compilation separately
exercise real module boundaries.

## Siri evaluation target

Prepared [Siri evaluation sources](../Performance/SiriEvaluations/README.md) use
the public SiriEvaluations runner, exact fixture identities, and all three runtime
skills. `bash scripts/check_siri_evaluations.sh` type-checks them;
`bash scripts/build_siri_evaluations.sh Debug` builds the app, widget, and test
bundle for iPhoneOS without running tests. Actual Siri/device evaluation requires
its own execution request and supported hardware, configuration, and accounts.
The model-test host flag is specific to `TripModels`; Siri scenarios retain their
own host setup and may intentionally exercise system services.

## Where later tests belong

| Behavior | Current owner or next focused coverage | Dependency seam |
| --- | --- | --- |
| Trip values, time zones, editing, projections | Existing TripKit/Tests/TripDomainTests and standalone checks | Sendable value inputs and fixed dates |
| Native place conversion and classification | Existing TripKit/Tests/TripPlacesTests | Exported adapters and constructed MKMapItem values |
| Ranking, layout, cache behavior | TripKit/Tests/MapEngineTests | Deterministic coordinates and bounded policies |
| Store migration and revision handling | TripKit/Tests/TripStorageTests | Isolated in-memory container or temporary store |
| Routing | Existing TripKit/Tests/TripRoutingTests | DirectionsProviding |
| AI output assembly and validation | TripKit/Tests/TripIntelligenceTests | Supplied data and bounded generated drafts |
| UI model workflows and cross-window edits | Existing TripAppTests hosted target | TripStoring, TripAIClient, TripStopOrderSuggesting |
| Native navigation, maps, accessibility | UI/device verification, when requested | Stable identities and explicit states |

Add a `.testTarget` only for the module under test, retaining Swift 6 isolation
and current deployment requirements. App source features share a binary, so their
models are not independently importable packages. Extend the existing hosted model
target for authorized app workflows; do not copy production files into test targets
or export app internals merely to make testing possible.

## Useful fakes

`ControlledTripStore` suspends and fails saves by revision for library lifetime tests;
`NavigationTestStore` controls pending loads. Keep fake state scoped to each test.
Extend these seams for changed persistence workflows without contacting the live store.

Inject a TripAIClient with a controlled protocol implementation, availability
closure, and error mapper. Suspend a request, change inputs, then resume the old
request to verify stale-result rejection. Check cancellation and deadline behavior
without contacting live services or requiring an eligible AI device.
`ControlledPackingPlanner` intentionally finishes canceled calls to exercise result
rejection. Do not assert the exact text of a live language-model response.

Supply TripStopOrderSuggesting to review a known proposal or error. Verify current
day matching, visit-tracking restrictions, stable stop IDs, and preserved notes.
Use PreviewTripServices for interactive local previews; executable tests own
their own providers and fixtures rather than importing DEBUG preview types.

## High-value regression cases

Extend coverage according to the changed responsibility. The list below includes
remaining work; the presence of a test seam does not establish coverage:

- Load failure and retry; edits during an outstanding save; out-of-order completion.
- Cancelling a draft preserves saved values; concurrent edits merge only changed fields.
- Query changes, backgrounding, and dismissal cancel work and reject stale output.
- Deleted or changed days invalidate proposals without losing unrelated edits.
- Legacy payloads still decode; identifiers and user data survive round trips.
- Dynamic Type, VoiceOver, Reduce Motion, long text, and supported window layouts.

Record the exact command/configuration and outcome. Keep source checks,
compilation, executable tests, and visual verification separate in reports.
