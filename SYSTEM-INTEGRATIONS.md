# Siri, Apple Intelligence, widgets, and trip day tracking

The app exposes actions over the real local trip library. Siri and Shortcuts can
open a saved trip, create a named trip with dates and days, read its itinerary,
draft a plan with Apple Intelligence, track a day, mark the next place visited,
and end tracking. Explore remains available. Open Trip once to publish your saved
trips to the system.

**Read My Trip Day** returns the exact requested date (today by default), with
places, flights, stays, reservations, and explicit times. Siri speaks the first
three items and presents a compact result card; Shortcuts receives the full day's
text. A date outside the itinerary stays empty instead of substituting another day.
Try “What's planned today in Trip”. **Read Trip Itinerary** also includes journey
events. **Undo Last Trip Visit** is available in the Shortcuts editor for recovery.

## Contents

- [Siri AI preview and contextual sharing](#siri-ai-preview-and-contextual-sharing)
- [Native travel services](#native-travel-services)
- [Collections and itinerary changes](#collections-and-itinerary-changes)
- [Next item and direct actions](#next-item-and-direct-actions)
- [Find a place from another app](#find-a-place-from-another-app)
- [Ask my trip](#ask-my-trip)
- [Widgets and Live Activities](#widgets-and-live-activities)
- [Packing and departure preparation](#packing-and-departure-preparation)
- [Ownership and signing](#ownership-and-signing)
- [Verification](#verification)
- [Apple references](#apple-references)

## Siri AI preview and contextual sharing

Trip targets 27.3 and exposes custom Siri tools, including exact saved-place
timing edits, collection organization, visit movement, and Apple Maps directions.
Runtime app skills coordinate day planning, departure preparation, booking review,
navigation, and collection organization. Existing
Shortcuts identities and phrases are preserved; configuration, snippet internals,
and redundant saved-record search actions do not become additional tools.

Long-press a result in **Ask my trip** for a native preview and Share action.
The share sheet can hand saved detail text to Messages or another chosen app;
Trip never sends it automatically. Visible result rows and next-step snippets
provide exact entity context to Siri. Private notes remain excluded.

[Siri preview adoption](docs/SiriPreview.md) records the tool inventory, canonical
mutation rules, metadata results, preview distribution limits, and remaining
device/evaluation verification. Successful compilation does not prove Siri routing.

## Native travel services

A saved trip's options menu now offers **Import booking** and **Export to Calendar**.
Each day's Add menu can import directly into that day. Import accepts a selected
PDF, image, or UTF-8 text document; Photos uses the system photo picker. Embedded
PDF text or on-device Vision OCR supplies suggestions and visible source evidence.
Dates are conservative suggestions, never preselected. Selected clocks require an
explicit time-zone review before opening the existing editable booking draft.
Nothing is saved until the traveler saves that draft. Unsupported or unreadable
files retain manual entry. File size, page count, image dimensions, source text,
and date suggestions have named limits; cancellation rejects late results.

**Import a Booking into Trip** is available in Shortcuts. For another app's document,
create a Shortcut with this action, enable **Show in Share Sheet**, accept PDFs,
images or text files, and connect Shortcut Input to **Booking document**. Choose a
trip and day, or use Ask Each Time. This is a user-configured Shortcut; the existing
place-name action remains separate. Handoffs revalidate the saved destination and
protect active editing sessions, including the transition into booking review.

Calendar export reviews selected bookings with confirmed start and end instants.
It requests write-only Calendar access and preserves the booking's start time zone,
absolute endpoint instants, location and exact-detail link. Checklist options offer
**Export to Reminders** for selected incomplete tasks and an optional due date.
Exports are copies with no ongoing synchronization. A local ledger avoids duplicate
exports; partial errors explain that successful items remain and retry skips them.
Reinstalling Trip or deleting a copied item in the other app does not synchronize
that ledger. Private trip notes are not exported.

A saved booking's editor offers **Travel alarm** after changes are saved. The traveler
confirms a future date/time in the booking's time zone. AlarmKit handles native
presentation and a foreground Open Trip action. Existing alarms can be cancelled.
Durable trip saves and foreground activation reconcile changed/deleted bookings;
stale scheduling work cannot remove a newer replacement alarm. Calendar/Reminders
are gated to supported platforms and AlarmKit to iOS; unsupported entries are hidden.

Each day's options menu offers **Weather for day**. Forecasts use saved place
coordinates and resolvable planned visit hours, with no guessed dates or substituted
future days. Rain, heat and wind prompts link into the existing schedule/planning
review; they never reorder a trip automatically. Requests and cache size are bounded,
background/dismissal cancellation reaches the provider, and failed refreshes offer
retry. Apple Weather attribution accompanies forecasts. **Read My Trip Day** adds an
optional Include weather parameter, off by default, for the first timed saved visit.
A forecast failure still returns the saved itinerary.

WeatherKit is disabled in the checked-in signing configuration. The
weather sheet and opted-in briefing explain the limitation without making service
requests; enabling live weather requires an eligible profile and the explicit
host configuration flag. Other integrations remain available.

Native adapters live in TripIntegrations behind injected TripDomain contracts.
[Native travel services](docs/NativeTravelServices.md) records acceptance and
verification; [dependency lifetimes](docs/Dependencies.md) describes composition.

## Collections and itinerary changes

**Create Trip Collection**, **Rename Trip Collection**, **Read Trip Collection**,
and **Save Trip Place to Collection** work with authenticated canonical data.
Collection entities expose the trip, title, place count, and saved names, including
places not scheduled on a day. Discovery enumerates the bounded library without
publishing collection content to Spotlight or App Group snapshots. Private notes
are excluded. Read returns all names to Shortcuts and speaks the first three.

Create reuses one normalized-name match; multiple matching names require a choice.
Rename preserves collection identity. Saving an exact itinerary place to a collection
keeps its original visit, avoids duplicate places, and copies neither timing nor notes.
Edits share the UI's domain operations, protect active drafts, and flush before success.
These actions do not accept invented places or turn a booking into a saved place.

**Move Saved Place to Day** moves an exact visit to the end of another day in the
same trip. It preserves its identifier, private notes, duration, allowances, and
local arrival clock on the destination day. Repeating the same destination is a
no-op. Bookings, duplicate places, missing days, and full days are rejected before
mutation. Returned entities resolve the current saved visit after persistence.
Saved-detail entities now expose optional visit, travel, and buffer minutes so Siri
can inspect an existing value before a relative timing change. Travel is a personal
allowance, not a route estimate; bookings and older snapshots expose no visit minutes.

**Open Trip Day Tool** now includes Directions and Suggest Stop Order, reusing the
existing route and ordering-review flows. Invalid requests return to the itinerary
where the recovery message is visible. Nothing is reordered until the review is applied.
On iPhone and iPad, **Review Saved Booking Alarm** opens the existing alarm review
for an exact saved booking. It never schedules an alarm by itself. Native permission,
time review, and confirmation stay in the existing flow. **End Trip Day Tracking**
is also exposed as a Siri tool; repeated execution keeps tracking ended and preserves visits.

## Next item and direct actions

**Get What's Next in My Trip** returns zero or one typed saved detail for Shortcuts,
plus a reusable result card with Open details and, for a mapped place, Directions.
Choose a trip explicitly, or leave it empty to use active tracking or the only trip
planned for today. Multiple current trips require an explicit choice. It never
silently chooses a future day. While tracking, the next unvisited place takes
priority; otherwise the trip's local day supplies upcoming saved commitments.
Private notes are excluded, authentication is required, and uncertain times remain
labeled for review. Use the ready-made “What's next in Trip” phrase or configure this action in a
custom Shortcut.

Items in the existing Siri day briefing and the itinerary widget now link to their
specific saved detail. Additional medium-widget items have individual links.
Deleted targets return to their trip with a notice, and unsaved editing sessions
block incoming detail navigation. The **Open saved trip** control adds **Next item**
alongside Itinerary and Checklist. An empty next-item result opens the itinerary.

The widget timeline considers both start and end boundaries, including departure
before arrival. Visited items are excluded from its additional upcoming rows, and
untimed ties retain itinerary order. Unconfirmed clocks do not schedule transitions.
WidgetKit still controls actual refresh delivery.

After tracking ends, expires, or all visits are completed, widgets return to the
saved agenda. A later flight or reservation remains visible, with its exact-item
link, and visited places remain excluded for that day. Ended sessions cannot pin
yesterday's itinerary. Active overnight tracking retains the selected day. Visit
buttons and progress gauges appear only while tracking is active; the circular
widget otherwise shows the next item's symbol. Live Activities continue to show
their ended/completed state; removing every place says **No places planned**.

Live Activities opt into small and medium supplemental families. Small layouts
provide the next place, planned time when known, and visit progress for Apple Watch
and CarPlay. Expanded Dynamic Island content shares its controls but omits the
duplicate progress bar and repeated count. Active activity taps open the exact next
place; stale and ended activity taps open the itinerary. Maps and Mark visited remain
available on the Lock Screen and expanded Island.

## Find a place from another app

**Find a Place for My Trip** accepts one place name or address, a saved trip, and
an explicit day number. It opens the existing **Add places** sheet with the search
filled in. The sheet identifies the trip and day, supports changing the destination,
shows Apple Maps results and saved places, and requires a tap to add a result.
Duplicate protection and Undo use the existing save flow. No place is saved by
running the action alone. Search uses Apple Maps; network failures retain its
existing retry behavior.

For selected text in another app, create a Shortcut with this action, turn on
**Show in Share Sheet**, accept **Text**, and connect **Shortcut Input** to
**Place or address**. Configure the trip/day or use **Ask Each Time**. Name it
“Find a trip place” if you also want to invoke that custom Shortcut with Siri.
Apple documents [share-sheet Shortcuts](https://support.apple.com/guide/shortcuts/run-a-shortcut-from-another-app-apd163eb9f95/ios)
and [supported input types](https://support.apple.com/guide/shortcuts/input-types-apd7644168e1/ios).

This is a user-configured Shortcut, not a native Share extension or an installed
Shortcut template. It accepts up to 200 characters of place text; links, booking
documents, and arbitrary webpages are not imported. Common URL inputs return a
message asking for a name or address. Required parameters are prompted by the
system. The action requires authentication and resolves current saved data; a
deleted day or an editing session prevents the handoff instead of replacing a draft.
The scene validates those conditions again when it consumes the request.

## Ask my trip

### Direct answers, discovery, and directions

**Ask My Saved Trip** is a background action in the Shortcuts editor. Choose a saved
trip and a question such as “Where am I staying on day two?” It interprets the question
with on-device Apple Intelligence, returns typed saved-detail entities for subsequent
Shortcut actions, and speaks up to three saved matches. A reusable result card shows
the interpreted scope, saved times and locations, source days, and exact-detail links.
The card also supplies onscreen entity identifiers. It does not generate booking facts.
Save a custom Shortcut with this action to invoke its name using Siri.

Questions are bounded; unsupported/oversized requests return no unrelated records.
The model may select only a supplied day, a supported category, and an explicitly
quoted name. Requests use separate sessions with cancellation and a 30-second
cooperative deadline. A changed or deleted itinerary is revalidated before returning
the answer. Intelligence unavailability produces an actionable message; manual
filters and **Get Saved Trip Details** remain available without inference.

Snippet refreshes read saved data without invoking the model again. Day-specific
answers retain the original day UUID, so reordering cannot redirect them to another
day; a deleted day is rejected. Editing saved records reloads the snippet. Private
notes and checklist text are excluded from the answer, model context, and search index.

**What's next in Trip** is one of the ten ready-made Siri phrases. Its existing action
resolves active tracking or one unambiguous trip planned today; it requires a choice
when multiple trips qualify. Declaration-size rules are maintained in [AGENTS.md](AGENTS.md).

Spotlight indexes up to 300 details from today and future trip days, including
multi-day stays, with trip names to distinguish similar records. Updates use the
existing serialized durable-publication path; removed details and evicted entries
are deleted from the index. Opening a result validates its canonical trip/item IDs.
Index publication enables discovery but does not guarantee Siri ranking or suggestions.

Medium itinerary widgets add a native Maps directions link for the displayed saved
place, alongside visit completion while tracking. Bookings without saved coordinates
do not show directions. Actions derive from the displayed item, not a different stop.

Open a saved trip's options menu and choose **Ask my trip**, or use **Find Saved
Trip Details** in Shortcuts with a trip and optional question. Browse the whole
trip or a specific day, or use quick filters for stays, flights/trains,
reservations, places, free time, and missing start times. These filters work
without Apple Intelligence. A multi-day stay appears once in whole-trip results
and remains discoverable on every day it spans.

With Apple Intelligence available, questions such as “Where am I staying?” or
“What's planned tomorrow?” become typed filters through Foundation Models. The
model receives the bounded question and trip-day calendar, not private notes.
Only saved records supply result titles, locations, and times; no generated
factual answer is displayed. Each result identifies its source day/date, and the
heading shows the interpreted category, day scope, and optional name filter.
Question interpretation can be wrong; the visible scope and manual filters let
the user correct it. Unsupported questions have an explicit empty state.
This lookup does not provide live status, booking-document retrieval, or advice
about whether a schedule is feasible.

New questions, navigation, and itinerary edits cancel pending work; generation
tokens reject late answers. A 30-second deadline offers recovery without clearing
the last useful results. Existing itinerary drafting and review remain available.
Times use saved trip and booking zones. Older schedules show a time-zone review
message, and unresolved clock changes do not supply a planned Live Activity time.
See [destination times and Today](docs/TripTimeAndToday.md).

Private Cloud Compute remains disabled in the current signing configuration.
The optional processing path is gated off until Apple grants the managed PCC
entitlement and an eligible signed build explicitly enables it. Manual planning
and available on-device Intelligence remain usable.

Try “Create a trip in Trip”, “Open Weekend in Bangkok in Trip”, “Read my itinerary
in Trip”, or “Track my trip day in Trip”. Siri asks for missing parameters. The
same actions are available in the Shortcuts editor for automations, such as opening
your itinerary each morning or marking a visit from the Action button.

Itinerary drafting and its privacy/review contract are described in
[Trip planning](TRIPS.md#on-device-itinerary-assistant). Saved trips are indexed as
App Entities, and the editor supplies onscreen entity context. The app does not
claim an unsupported travel assistant schema.

## Widgets and Live Activities

Add **Next on your trip** from the widget gallery. Small and medium Home Screen
widgets show the next place and day; Lock Screen inline, rectangular, and circular
widgets provide compact summaries. Edit the widget to select a saved trip, or
leave the choice empty to follow active tracking and then the next upcoming trip.
Tap to open that exact itinerary. During tracking, the Home Screen checkmark marks
the displayed place visited, without advancing another trip from a stale button.

When not tracking visits, widgets now include journey events and explicit saved
times. Upcoming timed items take priority; an ongoing hotel stay does not hide a
same-day flight or an untimed place. Widget timelines request updates at saved
time boundaries, tracking expiry, and midnight, subject to WidgetKit's scheduling.
The gallery uses clearly labeled local sample content. Older projections without
journey items still decode and show their places until the app republishes them.

On iPhone and iPad, timeline relevance informs Smart Rotate when the displayed,
confirmed saved item starts or ends within an hour, while a day is actively tracked,
or when an unfinished checklist is due for departure today or tomorrow. Tracking
relevance expires with its session; uncertain clocks and completed checklists do
not receive those boosts. This uses existing saved dates without collecting location.
WidgetKit decides placement and refresh delivery; Trip does not guarantee rotation.

In a trip editor, choose **Track a day**. A Live Activity shows the next place and
visited progress on the Lock Screen and supported Dynamic Island hardware, including
compact, minimal, and expanded layouts. The checkmark records a visit; the app also
provides Undo and End. Completion ends the activity. Tracking resumes an unfinished
day, reconciles deleted/reordered stops, and becomes stale after 7.5 hours.
Expired UI asks you to reopen Trip rather than offering an outdated action.
Progress reflects explicit visits; it is not background GPS navigation or a live ETA.
The Lock Screen and expanded Island show the next place's saved arrival time when
present, otherwise the following place. Compact/minimal symbols reflect the place
category, completion, or staleness. Completion says **All places visited** because
flights and reservations are not visit checkmarks. Activity content also refreshes
trip titles and day numbers after edits. Optional new fields preserve decoding of
previous activity states.

## Packing and departure preparation

In **Checklist → options → Suggest a packing list**, Foundation Models generates
an on-device draft from trip duration, activity/journey categories, and an optional
preference. Select useful suggestions, then choose **Add selected**. Existing items
and completion states remain intact. Notes, trip/place names, booking details, and
checklist text are excluded from the model context. This assistant does not infer
weather, baggage rules, visas, or medical requirements. Travel essentials still works
without Apple Intelligence. Requests stop on dismissal, backgrounding, preference
changes, or duration/activity changes, with a 45-second deadline and stale-result rejection.

Checklist actions: **Read Trip Checklist**, **Get Trip Checklist Items**,
**Add Trip Checklist Item**, **Set Trip Checklist Item Completion**,
**Open Trip Checklist**, and **Suggest Packing with Apple Intelligence**.
The read action returns remaining items and an interactive card for the first three.
Get returns typed entities so an automation can filter items and set completion
explicitly; setting an already completed item again does not toggle it back.
Add avoids normalized duplicates. Mutations resolve canonical IDs, require
authentication, and flush persistence before returning success. To invoke the new
read action through Siri, save it in a custom Shortcut named, for example,
“What's left to pack”. Existing automatic Siri phrases are preserved.

Add the **Departure checklist** widget for small/medium Home Screen or rectangular
Lock Screen presentation. It shows a calendar-based departure countdown and
checklist completion counts; tapping opens that trip's checklist. Widget projections
contain counts only. Checklist text stays out of App Group snapshots and Spotlight.
Old snapshots remain readable and request an app refresh for missing counts.
Completed checklist status describes only the checklist, not overall travel readiness.

On iOS, add **Open saved trip** in Control Center, Lock Screen controls, or the
Action button picker. Configure a required saved trip and choose Itinerary, Checklist, or Next item. A foreground intent runs in the host and validates the current trip;
an editing session blocks the handoff so unsaved drafts are preserved. Its handler
is installed at app initialization. URL-representable intents require universal
links, so this control uses a host action rather than Trip's custom URL scheme.

Active Lock Screen and expanded Dynamic Island activities offer a Maps directions
link to the next saved place alongside Mark visited. This uses saved coordinates;
stale, ended, and completed presentations hide directions. It adds no live ETA or
background navigation. Optional coordinate fields preserve old activity decoding.

## Ownership and signing

`AppRuntime` shares one revisioned app library between foreground UI and app intents.
`Shared/System` contains the identical entity, activity attributes, and interaction
intents compiled into both targets. `TripSurfaceStore` publishes a bounded index and
per-trip JSON projections only after durable library saves. Widgets never open the
private SwiftData database. Shared projections omit notes, ratings, and photographs;
the iOS files are protected until the first unlock after boot. Widget content is
privacy-sensitive and uses native rendering, including accented appearance.

Both targets use App Group
`group.com.native.trip`. Automatic signing must provision
that group for both bundle identifiers. Keep the identifiers and entitlements aligned
when reusing this integration in another app. The host embeds `TripWidgets.appex`,
declares `NSSupportsLiveActivities`, and handles the `trip://` URL scheme.
Activity updates are local; remote push updates require a separately implemented backend.

## Verification

`bash scripts/check.sh` audits both targets' source, physical line limits, previews,
ownership, App Groups, shared source membership, embedding, and Live Activity metadata.
When a build is requested, `bash scripts/build.sh app Debug` compiles the host and
embedded extension with the installed SDK and existing strict concurrency settings.
Compilation does not establish Siri discovery or correct device presentation.

On a signed device, verify first launch and an empty library, duplicate trip names,
deleted trips/days/stops, selecting another tracked trip before tapping an old widget,
double taps, Undo after completion, disabled Live Activities, expired tracking, dark
and accented widgets, long names, device restart before first unlock, and Intelligence
unavailability. Confirm widget deep links, Siri's parameter prompts, Spotlight opening,
and all Dynamic Island presentations on supported hardware.

## Apple references

- [App Intent execution modes](https://developer.apple.com/documentation/appintents/configuring-the-runtime-behavior-of-your-app-intents)
- [Smart Stack relevance](https://developer.apple.com/documentation/widgetkit/widget-suggestions-in-smart-stacks)
- [Onscreen entity context](https://developer.apple.com/documentation/swiftui/view/appentityidentifier(_:))
- [Interactive widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [ActivityKit presentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Foundation Models guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
