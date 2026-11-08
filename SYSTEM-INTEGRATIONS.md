# System integrations

Trip exposes saved travel data through App Intents, Siri, Shortcuts, Spotlight,
widgets, controls, and Live Activities. Use this guide when changing those surfaces or adding an action over saved data.
Follow [Siri integration](docs/SiriPreview.md) for tool metadata and runtime skills.

## Entry points

| Task | Existing surface | Result or review |
| --- | --- | --- |
| Open a trip, section, day, or exact detail | Siri/Shortcuts and native links | Resolves saved IDs; active edits block incoming navigation |
| Read itinerary, a day, or the next item | Shortcuts, Siri, snippets, widgets | Saved facts and exact-detail links; no invented booking information |
| Find saved information | Ask my trip and saved-detail actions | Manual filters or an on-device interpretation of the question |
| Prepare for departure | Checklist, packing review, departure widget | Explicit completion; generated suggestions require selection and saving |
| Organize a shortlist | Collection tools | Create, rename, read, or copy a saved itinerary place into a collection |
| Adjust a visit | Timing and Move Saved Place to Day tools | Validates the canonical visit, day, limits, and saved timing rules |
| Open directions or suggest an order | Existing day tool | Existing route validation or a stop-order proposal requiring Apply |
| Import or export travel data | Trip/day menus and Shortcuts | Existing document, Calendar, Reminders, and booking-alarm reviews |
| Track visits | Trip editor, widgets, Live Activity, Shortcuts | Explicit visit progress; no background GPS tracking |

Ten automatic App Shortcuts retain their shipped phrases and identities. Examples
include “Create a trip in Trip”, “Read my itinerary in Trip”, and “What's next in
Trip”. Other actions can be composed in a custom Shortcut. Siri tool discovery does
not add another automatic phrase for every action.

## Saved data and mutations

`AppRuntime` shares the canonical `TripLibraryModel`; each window owns navigation,
drafts, and review state. Intent handlers resolve identifiers against that library,
never against cached entity display properties. Foreground requests validate again
when the receiving window consumes them. Direct writes protect active editing and
flush persistence before reporting success.

Trip, detail, checklist, and collection identities remain stable. Collection IDs
include their trip ID. Create Collection reuses one normalized-name match, rejects
ambiguous matches, and respects capacity. Saving a place to a collection copies the
canonical place without its visit timing or notes; retrying keeps one copy. Rename
preserves the collection and its places. Unscheduled collection places are readable
but do not yet have individual entities for direct scheduling.

Move Saved Place to Day preserves the original visit identity, notes, and timing;
it rejects bookings, duplicates, stale targets, and full destinations. Set Visit
Timing preserves omitted fields and validates destination-local clocks, including
DST. Mark Saved Place Visited checks the actual tracked trip/day/stop. End Tracking
retains itinerary data. Undo Last Trip Visit remains a Shortcuts recovery action;
it is not an exact-target Siri tool.

## Ask my trip and sharing

Manual day, category, and text filters work without Apple Intelligence. A multi-day
stay appears once in whole-trip results and remains discoverable on its spanned
days. On-device question interpretation selects supported filters over saved data;
it does not generate travel facts. Bounded requests have cancellation, a cooperative
30-second deadline, and stale-result protection. An unavailable model leaves manual
lookup available. Private Cloud Compute is disabled in the checked-in configuration.

Read My Trip Day uses the requested date, with an empty result outside the trip.
What's Next prefers active tracking or an unambiguous trip planned today. Snippets
refresh saved data without invoking the model again and retain exact day/item IDs.
Private notes are excluded from answers, entity metadata, and shared detail text.

Long-press a saved-detail result for its native preview and Share action. The user
chooses the recipient/application. Visible rows and snippets supply exact onscreen
entity context. Spotlight indexes a bounded set of saved trips/details; opening an
indexed result revalidates its IDs. Indexing and intent donation do not guarantee
Siri ranking, delivery, or suggestions.

## Handoffs from another app

**Find a Place for My Trip** accepts a place name/address, saved trip, and day. It
opens Add places with the query filled in; selecting a real result is still required.
It accepts bounded text, not arbitrary webpages or booking documents.

**Import a Booking into Trip** accepts a supported document and opens the existing
review. For either action, a user can create a Shortcut, enable **Show in Share
Sheet**, and connect Shortcut Input to the appropriate parameter. No native Share
extension or preinstalled custom Shortcut is provided. Required destination choices,
canonical validation, and edit protection still apply. See
[native travel services](docs/NativeTravelServices.md) for formats and permission rules.

## Packing and departure preparation

Checklist actions read, add, rename, and explicitly set completion. Built-in presets
preserve completed items and require capacity for every missing item. Packing
suggestions use a bounded, on-device context based on duration, activity categories,
and optional preferences; they exclude private notes, booking details, names, and
existing checklist text. Suggestions require review and Add selected. Cancellation,
backgrounding, changed inputs, and a cooperative deadline reject stale work.

The Departure checklist widget shows a departure countdown and completion counts.
Checklist text stays out of App Group snapshots and Spotlight; authenticated
checklist actions can still return it. Completion describes the checklist, not an
assessment that the traveler is ready or safe to depart.

## Widgets, controls, and Live Activities

Next on your trip supports configurable itinerary widgets and exact-item links.
Active tracking retains its day, including overnight travel. Completed, expired, or
ended tracking returns widgets to the saved agenda; a later booking remains useful.
Visit buttons act only on the displayed tracked place. Upcoming confirmed start/end
boundaries, midnight, and tracking expiry inform timelines; WidgetKit controls delivery.

On iPhone/iPad, timeline relevance uses the displayed confirmed item within an hour,
active tracking, or an unfinished checklist with departure today/tomorrow. It uses
saved dates, not new location collection or polling. Smart Rotate placement remains
system-controlled; never promise rotation or immediate refresh.

The iOS Open saved trip control offers Itinerary, Checklist, and Next item. Its
foreground host action validates the saved trip and protects edits. Live Activities
are iOS-only and show explicit visit progress on supported system surfaces, including
compact/minimal/expanded Island and supplemental small/medium families. Tracking
expires after 7.5 hours; stale or ended content hides active visit controls. Maps links
use saved coordinates. These surfaces do not provide live ETA or background navigation.

## Ownership and signing

- `trip/App/Intents` owns app-only actions, queries, and semantic handoffs.
- `trip/Shared/System` contains shared entities, activity/runtime contracts, and interactions.
- `TripDomain` owns immutable projections; `TripStorage` owns App Group publication.
- `TripWidgets` reads those projections, never the private SwiftData database.
- `trip/Resources/Skills.skillsbundle` contains five runtime Siri skills, distinct from
  the repository's engineering skills.

Durable publication coalesces newer revisions, rejects obsolete CPU work, and
serializes native effects. Shared projections omit private notes, photos, and sample
ratings. iOS files are protected until first unlock. Both host and widget use
`group.com.native.trip`; signing must provision it consistently. The host embeds the
widget extension and handles `trip://` links. Activity updates are local; no remote
push service is implemented. See [dependencies](docs/Dependencies.md).

## Signed run setup

Use this procedure for your own runnable development copy. The repository's bundle
IDs and development team are not signing credentials for contributors. Unsigned
compilation through `build.sh` remains separate from a signed Xcode Run.

1. Open `trip.xcodeproj` in Xcode and select the shared `trip` scheme. In **Signing
   & Capabilities**, choose your own team for both `trip` and `TripWidgets`, and use
   automatic signing. Check the configuration you intend to run; project and target
   settings are stored in [project.pbxproj](trip.xcodeproj/project.pbxproj).
2. Give the host a unique bundle ID that your team owns, replacing `com.native.trip`.
   Give the embedded widget its own ID with the host ID as its prefix, such as
   `<owned-prefix>.trip.widgets` for `<owned-prefix>.trip`. The checked-in extension
   ID is `com.native.trip.widgets`. Keep both targets on the same signing team.
3. Create/provision an App Group owned by that team and enable the same group in
   both targets' App Groups capability. Replace `group.com.native.trip` consistently
   in [host entitlements](trip/trip.entitlements),
   [widget entitlements](TripWidgets/TripWidgets.entitlements), and
   [TripSystemData.appGroup](trip/Shared/System/TripSystemData.swift). The signed
   provisioning profiles must grant that group to both targets. A matching string
   in source alone does not provision access.
4. Resolve Xcode's capability/profile errors before running. If your team cannot
   provision the required App Group, use compilation checks until an eligible team
   is available; do not remove shared-container access to bypass signing. Preserve
   the usage descriptions and Live Activity declaration in
   [host Info.plist](trip/App/Info.plist), and the WidgetKit extension point in
   [widget Info.plist](TripWidgets/Info.plist). Keep WeatherKit and Private Cloud
   Compute disabled unless their capabilities and profiles are explicitly configured;
   follow [native services](docs/NativeTravelServices.md#weather-configuration) and
   [Siri integration](docs/SiriPreview.md) for the affected feature requirements.
5. If running `TripAppTests` or `TripSiriEvaluations`, configure that test target's
   team and unique bundle ID too. Their checked-in IDs are
   `com.native.trip.model-tests` and `com.native.trip.siri-evaluations`. For Siri
   evaluations, make [TripSiriDefinitions](Performance/SiriEvaluations/TripSiriDefinitions.swift)
   reference your host bundle ID. Follow the [model-test guide](docs/Testing.md) or
   [Siri fixture procedure](Performance/SiriEvaluations/README.md) with its owning
   shared test scheme, rather than changing the ordinary app launch to run tests.
6. Select an explicit supported destination and run the Debug `trip` scheme in
   Xcode. Use dedicated fixture data for native-service work. Do not install unsigned
   build-script output over an installation whose App Group data you need to retain.

Keep personal team, bundle-ID, App Group, and provisioning adjustments in your local
development copy or separate checkout. Review the named files before opening a PR;
leave local signing changes out of unrelated contributions. `bash scripts/check.sh`
checks that the two entitlement files agree with `TripSystemData`; it does not
provision access. Verify shared data and the affected native flows in your signed build.

## Change a system integration

1. Identify the existing user task and owner. Use App Intents for host actions,
   Shared/System for extension-safe contracts, and TripWidgets for widget rendering.
2. Preserve shipped identifiers and phrases. Resolve canonical saved records,
   protect edits, and choose explicit read, write, or review semantics.
3. Keep projections bounded and private notes excluded. Publish after durable saves;
   preserve old snapshot decoding when adding fields.
4. Add metadata to the shared catalog and generate host resources. Follow
   [localization](docs/Localization.md) and [Siri integration](docs/SiriPreview.md).
5. Run relevant authorized checks and review the actual native surface separately.

```sh
python3 scripts/workspace.py context App --json
bash scripts/check.sh
bash scripts/build.sh app Debug
bash scripts/build.sh visionOS Debug
```

Run builds and executable checks only within the requested task scope. Metadata
extraction and compilation do not exercise Siri conversations or native presentation.
Use [Siri evaluations](Performance/SiriEvaluations/README.md) for conversation work
and [native travel services](docs/NativeTravelServices.md) for permission/export flows.
Review exact target selection, deleted records, current edits, repeated actions,
sharing, permission recovery, widget refresh, controls, Live Activities, accessibility,
and signing on the affected platforms.

## Apple references

- [Siri AI Developer Preview](https://developer.apple.com/documentation/appintents/siri-ai-developer-preview)
- [Custom actions and content](https://developer.apple.com/documentation/appintents/bringing-custom-actions-and-content-to-siri)
- [App skills](https://developer.apple.com/documentation/appintents/orchestrating-complex-actions-with-app-skills)
- [Interactive widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [Share-sheet Shortcuts](https://support.apple.com/guide/shortcuts/run-a-shortcut-from-another-app-apd163eb9f95/ios)
