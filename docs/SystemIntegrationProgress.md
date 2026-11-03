# System integration improvement goal

Objective: improve extensions, widgets, Siri, Shortcuts, and Dynamic Island through
useful planning and travel actions. Preserve the existing native UI and working
actions; avoid decorative playback, redundant controls, and invented live data.

## Current implementation · October 20

| User task | Implementation | Evidence and remaining verification |
| --- | --- | --- |
| Open the item shown outside Trip | Exact trip/item links in itinerary widgets, Siri day cards, next-step cards, and active Live Activities | Source validation of stale/deleted targets and editing guards; cold launch and actual taps unverified |
| Ask what comes next | Authenticated Get What's Next in My Trip action, typed results, reusable card, active visit progress, current local day | Registered deterministic regression definitions; metadata export and Siri execution unverified; custom named Shortcut required for the new phrase |
| Reach the next item with one system control | Next item destination in existing configurable Trip control | Source wiring reviewed; device/control configuration unverified |
| Read the next place on a smaller surface | Small supplemental Live Activity layout for Apple Watch/CarPlay; dedicated expanded Island content | Local preview definitions for active, stale, completed, and long text; rendering and device delivery unverified |
| Keep widgets timely and calm | Stable agenda priority, visited exclusions, start/end transitions, expired-session refresh guard | Source reviewed; focused executable checks defined but not run |
| See later bookings after finishing visits | Ended/expired widgets return to the agenda; active overnight sessions retain their day | Shared selector and regression definitions; Home Screen/Lock Screen preview definitions; execution and rendering unverified |
| Bring a place name from another app into a trip | Find a Place for My Trip foreground action opens the existing Add places sheet with exact trip/day IDs and bounded search text | Source guards reviewed; share-sheet Shortcut setup documented; invocation, metadata and actual search/add unverified |

## Remaining work

- Verify the selected-text Shortcut handoff, including cold launch, deleted day,
  active edits, search failure/retry, switching destination, duplicates and Undo.
  Native Share extensions remain outside this implementation: the SDK inspection
  found no SwiftUI Share extension entry point, and the project prohibits UIKit.
  Map links and booking documents are not imported by the text action.
- Verify the widget transition from active visits to saved agenda, including a later
  flight, expiration, overnight tracking, midnight after ending, and deleted stops.
- Compilation, App Intents metadata export, executable system checks, Simulator
  rendering, and signed-device Siri/widget/Live Activity behavior remain unverified.
  The user explicitly selected source and preview-definition checks only for this work.

Source/architecture/line-limit audits are separate evidence from compilation and
runtime validation. The overall goal is awaiting authorization for verification.

## Source review · October 20

- Exact day UUID is resolved before queueing and checked again on scene consumption.
- Both stages preserve existing editing sessions; no automatic persistence occurs.
- Search delegates to existing cancellation, generation and timeout protection.
- Required day-number parameter exists in the installed App Intents interface.
- Picker previews now register their session in the model and disable network search.
- Completed tracked visits say “All places visited”; they do not claim events finished.
- `bash scripts/check.sh` passed for 651 Swift files and 2,578 members. This is
  source/architecture/preview-definition evidence, not compilation or runtime evidence.

## Completion audit

The previous continuation made implementation progress; this pass corrected widget
session recovery. Current source evidence covers host/extension boundaries, exact
item navigation, editing guards, saved-data priorities, visit identity, supported
SDK declarations and local preview wiring. The agreed changes are implemented in
source; further feature expansion is not a substitute for validating them.

Completion is unproven: executable system regression checks and rendered or
signed-device interactions remain unverified. The subsequent reported compiler
error authorized repair and compilation; the build result below supersedes the
earlier source-only compilation status. Runtime verification still requires a
change to the user's instruction.

The final source pass checked the actual system-check compiler manifest and runner,
canonical visit mutation guards, host control callback installation, intent parameters,
snippet reload routing and preview fixtures. It made the preview's reference to its
base plan explicit to avoid a local declaration shadowing that property. No build
or executable checks were run. The same outstanding verification restriction has
persisted through the capture, widget recovery and final review continuations;
further progress now requires permission for compilation and runtime verification.

## Build repair · October 20

Marked the pure TripSurfaceAgenda priority extension explicitly nonisolated,
resolving the main-actor inference error reported from TripNextStep. No concurrency
checks or deployment requirements changed. `bash scripts/build.sh app Debug`
passed with Xcode-beta, iOS Simulator 27.2, arm64/x86_64, signing disabled, including
the app, widget extension and App Intents metadata processing. The build log
contains no warnings or errors: `.build/build-errors-fix.log`. Source audits also
passed. No Simulator launch, visual review, benchmark or executable test was run.
