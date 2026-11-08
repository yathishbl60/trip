# Siri integration workflow

Use this guide when exposing a Trip action to Siri, changing saved entities,
editing runtime app skills, or reviewing generated App Intents metadata. Trip's
27.3 targets use the installed SDK APIs directly while preserving iOS-only native
capabilities. [System integrations](../SYSTEM-INTEGRATIONS.md) owns product behavior.

## Find the owner

| Change | Owning path |
| --- | --- |
| App-only intent, entity, or query | `trip/App/Intents` |
| Canonical execution and foreground handoff | `trip/App/Models/AppRuntime+*.swift` and App request handling |
| Shared host/widget entity or interaction | `trip/Shared/System` |
| Reusable saved-data operation | `Packages/TripKit/Sources/TripDomain` |
| Window-local review and editing | `trip/Features/Trips` |
| Runtime Siri instructions | `trip/Resources/Skills.skillsbundle/Skills` |
| Translated metadata | `Packages/TripKit/Sources/TripLocalization` |
| Siri scenario expectations | `Performance/SiriEvaluations` |

Start with `python3 scripts/workspace.py context App --json` and follow the actual
contracts crossed by the change. Runtime app skills are compiled app resources;
they are distinct from repository/global engineering skills.

## Design an action

Identify a concrete user request and reuse its existing workflow. Decide whether
the action reads saved data, performs an explicit write, or opens a review. A review
handoff must not imply that the booking, export, alarm, or generated plan is saved.
Preserve shipped intent names, parameter identities, entity IDs, enum raw values,
and the ten automatic App Shortcut declarations.

Use background execution for suitable saved-data operations. Foreground actions
must open useful existing UI. Set authentication and execution targets explicitly
where required. Keep platform-specific actions scoped to their supported platform;
Review Saved Booking Alarm is iOS-only and cannot accept a saved place visit.
Configuration and snippet internals do not need to become public tools.

Descriptions should explain the actual travel task, parameters, result, and limits.
Adopt a system schema only when the saved data and operation satisfy its meaning.
Do not change travel semantics merely to silence a schema suggestion.

## Validate saved data

Resolve entities through the canonical AppRuntime library rather than their display
properties. Preserve requested identifier order and omit deleted IDs in queries.
Use trip-qualified identities for nested records and full bounded enumeration when
implementing EnumerableEntityQuery. Keep privacy-sensitive queries authenticated.

Before mutation, check edit protection, target identity, capacity, timing, and
repeat-call semantics. Keep validation and the synchronous library update together;
flush before reporting success. Revalidate deferred foreground requests on delivery.
New async work needs cancellation and stale-result protection.

| Workflow | Contract to preserve |
| --- | --- |
| Visit timing | Separate saved target from generated changes; preserve omitted fields and validate destination-local clocks/DST |
| Collections | Reuse one normalized-name match, reject ambiguity, preserve identity on rename, avoid duplicate saved places |
| Visit movement | Move within the saved trip; preserve visit identity/notes/timing and reject booking, duplicate, or full targets |
| Review handoff | Preserve existing edits and require the existing in-app confirmation |
| Day directions/stop order | Use feature-owned coordinate/capacity/tracking checks; show notices on the itinerary; apply only reviewed proposals |

Private notes stay out of entity properties, system projections, answers, and shared
detail text. Authenticated checklist/collection actions can expose their task data
without publishing it to Spotlight or widget snapshots. Optional projection fields
must preserve legacy decoding.

## Maintain runtime skills

The bundle contains day planning, departure preparation, booking review, navigation,
and collection organization. Extend the owning skill for the corresponding task.
Use exact shipped tool meanings and distinguish opening a review from completing it.
Describe ambiguity, canonical reads, recoverable errors, and requested mutations.
Skills must not invent bookings, authorize unrelated actions, or claim success after
a failed tool call. Every tool must remain useful without a skill orchestrating it.

## Metadata and localization

Keep titles, parameter descriptions, entity properties, and summaries in the shared
catalog with English, Hindi, and Kannada entries. Mark translations needing language
review honestly. Run the localization generator rather than editing generated host
catalogs/accessors. Follow [localization](Localization.md).

Preserve concrete KeyPath interpolation in parameter summaries and the static
AppShortcut builder. App compilation must complete metadata extraction; Swift
source parsing or type-checking alone does not establish exported metadata.

```sh
bash scripts/check.sh
bash scripts/build.sh app Debug
bash scripts/build.sh visionOS Debug
xcrun sirimetadataanalyzer .build/xcode/Build/Products/Debug-iphonesimulator/trip.app --format json --language en
xcrun sirimetadataanalyzer .build/visionos/Build/Products/Debug-xrsimulator/trip.app --format json --language en
```

Run builds and analyzer commands within the requested verification scope. Repeat
language analysis for supported metadata locales when relevant. Inspect tool/entity/
skill exports and every diagnostic; analyzer suggestions and exported counts do not
prove routing, conversation success, or language quality.

## Review native behavior

For requested runtime work, follow [Siri evaluations](../Performance/SiriEvaluations/README.md)
using dedicated fixtures. Check cold launch, exact and ambiguous targets, deleted
records, current edits, repeated requests, persistence failure/retry, onscreen
context, and the distinction between a review and a completed write. Review native
sharing, Maps handoff, permissions, and platform availability in their owning flows.

Check Apple's current [Siri AI Developer Preview requirements](https://developer.apple.com/documentation/appintents/siri-ai-developer-preview)
for device eligibility, signing, and distribution before evaluating. Simulator
compilation and metadata analysis do not establish runtime availability. Primary
API references are [custom actions and content](https://developer.apple.com/documentation/appintents/bringing-custom-actions-and-content-to-siri)
and [app skills](https://developer.apple.com/documentation/appintents/orchestrating-complex-actions-with-app-skills).
