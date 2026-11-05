# Trip Siri behavior evaluations

The `TripSiriEvaluations` Swift Testing target supports a physical iOS 27.3+
destination and has its own shared scheme. The user authorized the target, then
restricted verification to compilation on 2026-11-05. Do not run its scenarios
until execution is explicitly requested again.

`bash scripts/build_siri_evaluations.sh Debug` compiles and links the app, widgets,
and test bundle with `build-for-testing`, an explicit iPhoneOS SDK, and signing
disabled. It does not install an app, select a physical device, or execute tests.
This Debug build passed with Xcode 27.3 beta 1 on 2026-11-05. Xcode places the
hosted bundle at `trip.app/PlugIns/TripSiriEvaluations.xctest` in the build products.
This is compilation/link evidence only; the ten Siri scenario results are unverified.

The target also compiles 50 local-model cases across seven suites, including
parameterized sections, day tools, event kinds, presets, and invalid inputs.
These checks use local services, do not call Siri, and need no device fixture.
They have not been executed.
They compile only with the Debug app module available; the standalone API
type-check command below does not check their app-owned dependencies.

`bash scripts/check_siri_evaluations.sh` type-checks the public APIs and macros
against the installed iPhoneOS SDK. It neither links a test bundle nor runs Siri.
The script honors `DEVELOPER_DIR` and keeps its compiler cache under `.build`.

## Ten Siri scenarios

| Group | Observable requirement |
| --- | --- |
| Navigation, two scenarios | Open the requested Trips or Explore surface |
| Saved navigation, two scenarios | Open Today or the day-two map using the exact saved trip, enum value, and day; do not start Maps directions |
| Saved reads, two scenarios | Read itinerary/checklist for the exact staged UUID and find that entity |
| On-screen context, one scenario | Resolve “this trip” to the visible staged UUID |
| App skills, three scenarios | Load each shipped skill for its intended planning, preparation, or booking-review task |

Each scenario checks for twelve forbidden mutation/tracking/draft intents. These checks
observe behavior; they do not prevent an incorrectly selected action from running.
Use dedicated fixture data for actual evaluation. Skill loading and
intent correctness have separate metrics. Only facets with expectations are gated;
an ignored or missing metric is never treated as a passing result. These scenarios
do not prove timing-write correctness, exact visit advancement, Maps handoff, or
native sharing. The deterministic harness covers timing values and privacy.

## Local-model coverage (compiled, not executed)

| Suite | Cases | Scope |
| --- | ---: | --- |
| Wayfinding | 5 | Native Back state, day identity, drafts, missing trips, exact booking selection |
| Sections | 11 | All sections, retained search filters, deleted targets, export review context |
| Preparation | 11 | Every preset, atomic capacity checks, rename identity/completion, invalid titles, shared UI behavior |
| Booking drafts | 10 | Every event kind, cancellation, stale day/capacity checks, wrong trip, invalid title, draft protection |
| Day tools | 6 | Every day tool and timezone-review recovery |
| Saved data | 4 | Private-note exclusion, combined filters, entity identity, idempotent timing edits |
| Persistence | 3 | Save failure/retry, publication timing, obsolete loads, repeated flushes |

These checks do not replace accessibility, animation, gesture, or navigation
presentation review on a running app. The Siri conversation tests and local-model
tests are distinct suites in the existing target; no additional target is needed.

## Device preparation and fixture

Use a development-signed, installed Trip build and launch it before evaluating.
The physical device must support Apple Intelligence, run 27.3+, have Developer Mode
and Siri/Apple Intelligence enabled, and finish downloading its models. Keep it
unlocked and untouched during the run. Automation Mode may request the passcode.
Do not change these settings or install a device build without execution authority.

Create one dedicated trip named **Siri Review** with two days, a saved place,
and an incomplete checklist item such as **Sample umbrella**. Use test content,
not private notes or bookings. Save and let Trip publish its system projections.
Run `TripSiriFixtureTests.fixtureIdentifier` alone and read its
`TRIP_SIRI_TRIP_ID` attachment. Set that exact UUID as the evaluation test scheme's
`TRIP_SIRI_TRIP_ID` environment variable. The fixture is validated before every
saved-data scenario; missing or wrong fixtures fail before Siri runs.

The on-screen evaluation opens that trip through its public intent before starting
Siri. Failure to observe the editor is a real setup/UI issue, not grounds to remove
the `OnScreen` expectation. The test setup does not create, edit, or delete fixtures.

## Execution, only when requested again

Select the `TripSiriEvaluations` scheme, which hosts the tests in `com.native.trip`.
Use Xcode's standard test runner with parallel testing disabled and one physical
destination. The schemes keep ordinary app builds separate. The suites are
serialized. Run only the fixture inspection first, then one evaluation test at a
time. Select English Siri for the authored utterances; other languages need their
own reviewed utterances and execution evidence.

Open the Xcode evaluation report or export its `.xcevalresult` attachments with
`xcrun xcresulttool export attachments`. Inspect diagnostics, completed turns,
selected tools and arguments, found/on-screen IDs, loaded skills, and failed rows.
Record app revision, toolchain, locale, destination, fixture, and results. A run
that stops before grading is an environment failure; retain the expectations.
