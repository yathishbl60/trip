# Test seams and future coverage

The repository has routing package tests and standalone performance checks.
The dedicated `TripSiriEvaluations` target exercises public system integration
contracts; there is no general app-model test target. Source audits parse Swift
and enforce contracts; they do not execute application behavior.

Prepared [Siri evaluation sources](../Performance/SiriEvaluations/README.md) use
the public SiriEvaluations runner, exact fixture identities, and all three runtime
skills. `bash scripts/check_siri_evaluations.sh` type-checks them;
`bash scripts/build_siri_evaluations.sh Debug` builds the app, widget, and test
bundle for iPhoneOS without running tests. The user requested build-only
verification; actual device evaluation requires a renewed execution request.

## Where later tests belong

| Behavior | Location when requested | Dependency seam |
| --- | --- | --- |
| Trip values, time zones, editing, projections | TripKit/Tests/TripDomainTests | Sendable value inputs and fixed dates |
| Ranking, layout, cache behavior | TripKit/Tests/MapEngineTests | Deterministic coordinates and bounded policies |
| Store migration and revision handling | TripKit/Tests/TripStorageTests | Isolated in-memory container or temporary store |
| Routing | Existing TripKit/Tests/TripRoutingTests | DirectionsProviding |
| AI output assembly and validation | TripKit/Tests/TripIntelligenceTests | Supplied data and bounded generated drafts |
| UI model workflows and cross-window edits | An app model test target, when requested | TripStoring, TripAIClient, TripStopOrderSuggesting |
| Native navigation, maps, accessibility | UI/device verification, when requested | Stable identities and explicit states |

Add a `.testTarget` only for the module under test, retaining Swift 6 isolation
and current deployment requirements. App source features share a binary, so their
models are not independently importable packages. Introduce an app test target
when app workflow tests are authorized; do not copy production files into test
targets or export app internals merely to make testing possible.

## Useful fakes

Create a TripStoring actor that can suspend, fail, and resume loads/saves. Inject
it into TripLibraryModel and verify latest-revision persistence, retry after failure,
and concurrent window edits. Keep fake state scoped to each test.

Inject a TripAIClient with a controlled protocol implementation, availability
closure, and error mapper. Suspend a request, change inputs, then resume the old
request to verify stale-result rejection. Check cancellation and deadline behavior
without contacting live services or requiring an eligible AI device. Do not assert
the exact text of a live language-model response.

Supply TripStopOrderSuggesting to review a known proposal or error. Verify current
day matching, visit-tracking restrictions, stable stop IDs, and preserved notes.
Use PreviewTripServices for interactive local previews; later tests should own
their own providers and fixtures rather than importing DEBUG preview types.

## High-value regression cases

- Load failure and retry; edits during an outstanding save; out-of-order completion.
- Cancelling a draft preserves saved values; concurrent edits merge only changed fields.
- Query changes, backgrounding, and dismissal cancel work and reject stale output.
- Deleted or changed days invalidate proposals without losing unrelated edits.
- Legacy payloads still decode; identifiers and user data survive round trips.
- Dynamic Type, VoiceOver, Reduce Motion, long text, and supported window layouts.

Record the exact command/configuration and outcome. Keep source checks,
compilation, executable tests, and visual verification separate in reports.
