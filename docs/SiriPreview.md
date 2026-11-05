# Siri preview adoption

Work started 2026-11-04 after committing the existing UI changes as `abf1779`.
The installed toolchain is Xcode 27.3 beta 1 (27C5020n). The user explicitly raised
Trip's deployment baseline and aligned TripKit platforms to 27.3. This is an implementation
and verification record; unchecked work is not a claim of delivered behavior.

## Requirements and evidence

- [x] Commit the existing changes before Siri work; working tree was clean afterward.
- [x] Read Apple's Siri AI Developer Preview and the referenced Xcode-skills commit.
- [x] Inspect installed Siri integration/evaluation guidance and public SDK declarations.
- [x] Update the unified global app-development skill with reusable Siri guidance.
- [x] Update Trip's system-integration skill with local adoption and verification paths.
- [x] Review the intent inventory and exposed tools' metadata, execution, errors, and queries.
- [x] Expose useful actions as 27.3 tools without changing existing Shortcuts identifiers.
- [x] Make entities discoverable, distinguishable, and authenticated where required.
- [x] Add useful generable input for a real existing planning task, with canonical validation.
- [x] Ship app skills for multi-step Trip tasks through a compiled Skills.skillsbundle.
- [x] Keep snippets and onscreen entities connected to durable records and exact actions.
- [x] Run source checks, authorized builds, and Siri metadata analysis for en/hi/kn.
- [x] Add focused deterministic regression checks for new mutation behavior.
- [x] Prepare, type-check, compile, and link SiriEvaluations scenarios grounded in actual metadata.
- [x] Honor the latest build-only instruction; leave physical evaluations and
  per-scenario runtime reports deferred until execution is requested again.
- [x] Record remaining preview/device limitations separately from compiled behavior.

The [prepared evaluation sources](../Performance/SiriEvaluations/README.md) cover
eight scenarios and type-check against iPhoneOS 27.3. The user authorized the
dedicated `TripSiriEvaluations` target, then explicitly requested compilation
without execution. The global skill documents scenario authoring, device
prerequisites, standard metrics, and per-turn report analysis.

## Delivered behavior

The built app exposes 25 tools: opening Explore, Trips, a new-trip form, a saved
trip, an exact detail, or a checklist; reading an itinerary, day, next step, or
checklist; adding and setting checklist items; opening packing, itinerary-draft,
booking-review, and place-search flows; starting day tracking; setting visit
timing; marking an exact saved place visited; directions to a saved place; creating
a trip; opening a trip section, day tool, or trip review tool; and editing an exact
saved detail. Existing intent identities and the ten automatic shortcuts are preserved.

The new navigation tools cover itinerary, Today, map, checklist, collections,
detail search, day schedules, planning previews, day weather, adding places,
trip editing, and Calendar/Reminders export reviews. Day-map requests retain the
requested saved day. Editor/export handoffs require the existing in-app review;
they do not automatically save a draft or send data to another app.

Set Visit Timing uses a generable value separate from the saved target entity.
It preserves unspecified fields, validates minute ranges, checks destination-local
clocks including DST, protects unsaved editing, and flushes before success.
Mark Saved Place Visited verifies the actual tracked trip/day and recorded stop
after the idempotent operation. Directions opens Apple Maps using saved coordinates.
Neither tool silently advances another place or treats a booking as a visit.

Saved detail rows expose native context-menu previews and Share actions. Shared
text contains the saved title, source day, saved times, and location, excluding
private notes. Lookup rows and next-step snippets provide exact on-screen entity
identifiers through the app's existing composition boundary. Opening a trip from
the library donates its matching intent; deletion removes matching donations.

The four runtime skills cover day planning, departure preparation, booking review,
and navigation. Stored-trip/detail entities have described properties, authentication,
and safe transferable text. Checklist discovery enumerates the bounded canonical
library without publishing checklist text to Spotlight or App Group snapshots.

## Navigation update verification on 2026-11-05

- Generic iOS Simulator Debug app/widget compilation passes with Xcode 27.3 beta 1.
- Generic iPhoneOS Debug `build-for-testing` passes, including the existing eight
  Siri scenarios and five new local-model wayfinding checks. No tests were executed.
- English metadata analysis reports 42 actions, 25 tools, four entities, and four
  compiled app skills, with zero errors/warnings. Six SMA701 suggestions compare
  travel tools to unrelated schemas; the tool descriptions retain their travel meaning.
- Source checks cover architecture, previews, localization, and file/member limits.
  New Hindi/Kannada translations are present and marked `needs_review`.
- The new title menus, native transitions, row editing, voice routing, and keyboard
  behavior have not been exercised in a simulator or on a device. This update's
  visionOS configuration is unchanged and has not been compiled.

## Earlier baseline verification on 2026-11-05

- `bash scripts/check.sh`: ownership, localization, previews, Swift/member limits,
  project skills, and platform contracts pass.
- `bash scripts/build.sh app Debug`: generic iOS Simulator build passes with
  Xcode 27.3 beta 1, including TripWidgets and App Intents metadata extraction.
- `bash scripts/build_siri_evaluations.sh Debug`: generic iPhoneOS 27.3
  `build-for-testing` passes. The app, widgets, and hosted test bundle compile and
  link with strict Swift 6 concurrency; the log reports `TEST BUILD SUCCEEDED`
  without compiler errors or warnings. Tests were not executed.
- The app contains `Metadata.appintents/Skills.skillsc`; all three skills appear
  in the public metadata analyzer output.
- Analyzer en/hi/kn: 38 actions, 20 tools, four entities, zero errors/warnings.
  Four SMA701 suggestions match unrelated Find My, books, presentation, and photos
  schemas. Trip keeps its actual travel semantics instead of adopting those schemas.
- Hindi/Kannada metadata is present; those translations retain `needs_review`.
  The analyzer skips or limits some language-dependent rules outside English.
- Saved-data regression checks pass, including timing validation, preservation,
  repeated edits, next-day arrivals, missing/repeated DST clocks, and privacy.
- The app installs and launches on the iOS 27.3 iPhone 18 Pro simulator. Visual
  review was not completed because Device Hub computer-use access was not approved.
- Physical Siri conversations/evaluations, donation delivery, sharing presentation,
  actual Maps handoff, and this revision's visionOS compilation remain unverified.
  The latest user instruction is build-only; no additional runtime checks run.

Logs and analyzer reports are local ignored artifacts under `.build/siri-preview`.
Global skill edits live outside this Git repository; only Trip adoption guidance
is committed here. The global quick validator passes using an isolated, SHA-256
verified PyYAML dependency from PyPI; no system Python installation was changed.
The skill installer also checked links, hashes, and project file limits.

## Adoption decisions

Existing intents keep their types, parameters, and automatic phrases. The user
approved a 27.3 minimum, so tools and entity property descriptions use the APIs
directly without redundant 27.3 availability gates. Private notes remain excluded
from system metadata. Engineering guidance retains availability rules for other apps.

Siri finds stored records through Spotlight or supported entity enumeration.
Existing Shortcuts search actions remain available without becoming duplicate Siri
search tools. UI-only snippet/control intents remain internal. Every exposed tool
must work from a cold launch or return an actionable error, independently of skills.

The app's Siri skills are runtime resources, distinct from Codex engineering skills.
They explain Trip-specific travel semantics and multi-step tasks; they do not add
screens or map controls. Siri-generated data must pass the same saved-data rules
as manual editing, and success requires durable persistence.

## Referenced update coverage

The pinned upstream commit changes 30 files. Its new Siri integration entrypoint
and five references cover tools, generable values, entity metadata, runtime skill
bundles, and metadata analysis. The new evaluation entrypoint and four references
cover scenario authoring, public APIs, device execution, and report analysis.
Both App Intents entrypoint changes revise discovery descriptions rather than API
contracts. Device interaction adds foldable hinge input. Swift Testing guidance
is reorganized and clarified. The macOS touch entrypoint and twelve task references
concern AppKit direct-touch handling; Trip has no macOS/AppKit target, so those
cannot justify adding AppKit or UIKit to this app. Review reusable guidance in its
global owner. Repository/plugin metadata files describe packaging, not app features.

## Sources and preview limits

- [Apple overview](https://developer.apple.com/documentation/appintents/siri-ai-developer-preview)
- [Custom actions and content](https://developer.apple.com/documentation/appintents/bringing-custom-actions-and-content-to-siri)
- [App skills](https://developer.apple.com/documentation/appintents/orchestrating-complex-actions-with-app-skills)
- [Pinned upstream update](https://github.com/artemnovichkov/xcode-skills/commit/6fa4005b8836f2c7eae4f45ab418cfc9ec5dec1e)

Apple restricts preview execution to development-signed builds and internal
TestFlight on supported Apple Intelligence devices. External TestFlight and App
Store distribution do not enable this preview. SiriEvaluations requires a physical
27.3+ device; simulator compilation and metadata analysis do not prove Siri behavior.
