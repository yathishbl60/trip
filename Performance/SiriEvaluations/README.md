# Siri evaluations

`TripSiriEvaluations` is the existing hosted Swift Testing target for Siri scenarios
and related local-model contracts. It has a shared Xcode scheme and a physical
iOS 27.3+ evaluation destination. It is separate from the deterministic general
`TripAppTests` / `TripModels` host described in [Testing](../../docs/Testing.md).

## Choose the check

Run only the verification requested for the task:

```sh
# Type-check public SiriEvaluations APIs/macros; no app linking or execution.
bash scripts/check_siri_evaluations.sh

# Compile/link host, widget, and hosted test bundle; no execution.
bash scripts/build_siri_evaluations.sh Debug
```

Both scripts honor `DEVELOPER_DIR` and write to `.build/siri-evaluations`. The
build script uses generic iPhoneOS, signing disabled, and `build-for-testing`.
The API-only check excludes Debug app-owned cases guarded by `canImport(trip)`;
it cannot prove their dependencies compile. Hosted local-model cases require the
Debug app module. The linked bundle is inside `trip.app/PlugIns`.

Use compilation to check API/target integration and execution to evaluate behavior.
Do not treat a compiled target or exported intent inventory as a scenario result.
Follow [Siri integration](../../docs/SiriPreview.md) when changing tools or skills.

## Conversation scenarios

| Group | Prepared expectation |
| --- | --- |
| Navigation: two | Open Trips or Explore as requested |
| Saved navigation: two | Resolve the exact saved trip, section, and day-two map without starting Maps directions |
| Saved reads: two | Read itinerary/checklist for the staged trip UUID and find that entity |
| Onscreen context: one | Resolve “this trip” to the visible staged UUID |
| Skills: three | Load day-planning, departure-preparation, or booking-review skill for the corresponding task |

Match scenario coverage to the changed workflow. The skill scenarios assert the
three listed skills; navigation and collection instructions require their own
expectations when those workflows are evaluated. Forbidden
intent expectations observe unexpected mutations; they cannot prevent an incorrectly
chosen tool from running. Dedicated, nonprivate fixtures are required for evaluation.
Only configured metrics are graded; an absent/ignored metric is not a pass.

## Local-model coverage

These suites use local providers and do not call Siri. Extend the owning suite for
authorized behavior changes; keep fixtures deterministic and assertions about the
contract rather than implementation details.

| Suite | Cases | Prepared scope |
| --- | ---: | --- |
| Wayfinding | 5 | Back-binding identity, day map, drafts, missing trip, exact booking |
| Sections | 11 | Sections, retained search, stale targets, export review context |
| Preparation | 11 | Presets, atomic capacity, rename identity, invalid titles, shared UI policy |
| Booking drafts | 10 | Event kinds, cancellation, changed day/capacity, wrong trip, edit protection |
| Day tools | 6 | Original five choices and timezone-review recovery |
| Saved data | 4 | Privacy, filters, detail identity, repeat-safe timing edits |
| Persistence | 3 | Failure/retry, publication, obsolete load, repeated flush |

Choose relevant cases explicitly. Do not infer coverage for directions, stop order,
collections, visit movement, alarms, or widget relevance from a generic suite name.
Native presentation, accessibility, and multi-window delivery need runtime review.

## Device preparation

For an explicitly requested Siri run, use an eligible physical Apple Intelligence
device on 27.3+, a development-signed build, Developer Mode, enabled Siri/Apple
Intelligence, and downloaded models. Check Apple's current
[preview requirements](https://developer.apple.com/documentation/appintents/siri-ai-developer-preview).
Launch Trip before evaluating and keep the device unlocked and undisturbed.
Signing, installation, device settings, and execution are separate from compilation.

Create a dedicated **Siri Review** trip with two days, a saved place, and an incomplete
sample checklist item. Do not use valued travel data. Save it and allow publication.
Run `TripSiriFixtureTests.fixtureIdentifier` first and use its `TRIP_SIRI_TRIP_ID`
attachment as the scheme's environment variable. Saved-data scenarios validate that
exact fixture before invoking Siri; setup does not create or mutate the fixture.

The onscreen scenario opens the trip through its public intent. A missing editor
or failed onscreen expectation is a setup/behavior issue, not a reason to remove
the assertion. Use the English Siri locale for the authored utterances; other
languages need reviewed utterances and their own execution evidence.

## Evaluate and report

Use the `TripSiriEvaluations` scheme with parallel testing disabled and one physical
destination. Run the fixture check, then individual scenario groups. Inspect the
Xcode report or export `.xcevalresult` attachments using
`xcrun xcresulttool export attachments`.

Record revision/source state, toolchain, locale, device, fixture, selected tools and
arguments, entity IDs, loaded skills, completed turns, and graded results. A run
that stops before grading is incomplete, not a passing evaluation. Retain diagnostics
and describe any unavailable metric. Do not infer device behavior from the app's
metadata counts or the standalone algorithm harness.
