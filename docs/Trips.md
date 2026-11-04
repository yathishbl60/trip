# Trips

Start at `Views/Library/TripManagerView.swift` → `TripController` → `TripModel`.
The feature can be constructed without Explore or application navigation.
Production construction lives in `trip/App/Dependencies/AppTripServices.swift`;
local component composition uses `PreviewTripServices`. See [Dependencies](Dependencies.md).

| State or behavior | Owner |
| --- | --- |
| Saved plans, filtering, load/save errors, revisions | Models/Library/TripLibraryModel |
| Dialog targets, pending saves, selected trip | Models/Presentation/TripPresentationModel |
| Trip name, date, and notes draft, validation, field merge | TripEditDraft |
| Draft save/cancel, day/stop edits, collections | TripModel workflow extensions |
| Draft generation and cancellation | TripAssistantModel, TripModel+Assistant |
| Temporary success message | TripFeedbackModel |
| Packing and preparation checklist | TripModel+Checklist, TripChecklistDraft |
| Saved-place picker, moving stops and days | TripModel+DayPlanning, TripSavedPlacePickerModel |
| Day schedules, visit timings, editing sessions | TripModel+Scheduling, TripDayScheduleDraft, TripStopTimingDraft |
| Timeline calculation, timing limits, backward-compatible values | TripDomain/Trips schedule types |
| Typed events, multi-day spans, mixed row identity/order | TripDomain/Trips journey types |
| Event drafts, validation, stale-save protection, durable actions | TripEventDraft, TripModel+Events |
| Native map, day selection, stop focus | TripMapModel, TripMapController |
| Stop-order review and guarded application | TripStopOrderModel, TripModel+StopOrder |
| Return to map, focus a place, day directions | TripEnvironment callbacks supplied by the host |

The library's trips array is read-only outside its implementation. Use insert,
update, updateDay, updateCollection, and remove for durable edits. Update closures
operate on a copy: return true to commit and schedule persistence, false to discard
the copy. Do not call persist from a workflow or mutate a saved plan through a view.
Index-based list actions validate offsets; identity-based operations reject stale IDs.

TripLimits in TripDomain is the shared policy for counts and text limits. The
library guards readiness and trip capacity. Workflow models own duplicate checks,
validation, notices, and success feedback. Controllers expose bindings/actions;
they do not assemble plans or decide persistence policy.

Inject `TripLibraryModel(store: provider)` and the assistant, lookup, packing,
ordering, booking-import, system-action, weather and tracking models/providers
into TripModel. [Dependencies](Dependencies.md) defines their lifetimes. Workflow models use typed TripAIClient values; no model
constructs a live storage or intelligence service. Use one library per
revisioned store session. A 250 ms debounce coalesces writes; changed IDs support
partial updates. Failures retain pending edits, retry flushes them, and an older
completion cannot clear newer dirty state. AppModel flushes on inactivity.
TripStorage's schema/migrations remain behind TripStoring.

`loadedTrips` initializes a known snapshot for fixtures or an already-loaded host;
normal construction leaves it nil and loads the store. PreviewFixtures.tripPlanner
and emptyTripPlanner use an in-memory store. They return TripModel directly;
PreviewFixtures.app is reserved for cross-feature integration previews.

For a new trip settings field, add the value to TripDomain if durable, then to
TripEditDraft and its field merge. Expose the binding through TripController and
render it in TripEditView. Keep itinerary edits in their focused TripModel actions.
Drafts own a stable session ID; late save/cancel callbacks must match that ID.
A draft retains its original field values so untouched settings are not overwritten
when another window updates the same trip. Never replace a saved trip with a draft.
Trip settings, day schedules, visit timing, and day-order/placement reviews protect
changed drafts from interactive dismissal. Cancel asks whether to discard; cancelling
that confirmation keeps the form and its values. Unchanged forms close immediately.
Change detection compares the editable session with its initial values: opening a
new schedule or suggested placement alone does not trigger a discard warning.
Restoring the original order or placement removes the warning. Event drafts retain
their existing change-aware confirmation. These interactions require rendered checks
for swipe dismissal, toolbar Cancel, continued editing, and successful Save/Apply.
For a new host action, extend TripEnvironment and wire it in AppModel. Run source
checks. When runtime checks are requested, cover save/reload, duplicate/deletion,
failed writes/retry, assistant cancellation, and save sheets from both map entry points.

Failed-library loading keeps its explanation visible during a retry and replaces
Retry with an observable loading indicator until the attempt finishes. The existing
shared load task coalesces callers; failure restores Retry and success opens the library.

## Contents

- [Model folders](#model-folders)
- [Planning workflows](#planning-workflows)
- [Complete journey timeline](#complete-journey-timeline)
- [Timed itineraries](#timed-itineraries)
- [Visual itinerary](#visual-itinerary)
- [Map and local stop-order suggestions](#map-and-local-stop-order-suggestions)
- [Preview a day and save a place in context](#preview-a-day-and-save-a-place-in-context)

## Model folders

`Workspace` contains TripModel composition and cross-workflow actions. `Library`
owns persistence. `Assistant`, `Checklist`, `Lookup`, `Journey`, and `Tracking`
contain their respective state. `Editing` owns value drafts, `Scheduling` owns clock
and timing presentation, `Search` owns picker lifetimes, `Map` owns saved-place
framing, `Ordering` owns proposal review, and `Planning` owns day review/routes.
`Presentation` contains shared feature presentation state and display extensions.
`Dependencies` contains the small injected AI client contract. Add behavior to the
focused owner before adding another TripModel extension.

## Planning workflows

See [Search](Search.md) for matching across places, trips and saved details,
compatible result retention, combined filters and verification scope.

Each day has a direct Add places action and a separate calendar menu for events.
Its native search sheet keeps the trip and day
visible, searches both saved places and Apple Maps, and stays open for multiple
additions. The search field stays visible, and the destination picker switches days
without leaving the sheet. With a mapped place as context, empty search offers
food, coffee, sights, and parks through real Apple Maps queries. Search uses the
selected day's last valid coordinate, falling back to the trip's first mapped
place; the sheet names this search origin. Additions don't shift that origin or
restart an active search. Switching days cancels the old request and clears its
results before searching around the new destination.

A successful addition changes the result to a checkmark and shows the place and
destination with Undo. Undo removes only the exact newly created stop from its
original day; changed, moved, or removed stops are protected. The latest addition
is reversible while the sheet stays open, including after switching days. If the
destination day disappears, the sheet selects a surviving day and explains the
change. Trip deletion cancels search. Saved-place
copies keep notes and unpin fixed arrival times; live results retain their Maps identity.
Requests debounce, cancel on query changes/dismissal, time out, and reject stale results.
Destinations already containing a place or at capacity are disabled. Moving a stop
preserves its identity and notes; moving a day preserves its identity and renumbers
the itinerary so its date follows its new position. Native Edit controls still
reorder and remove individual stops.

Trip options contains Map, Checklist, Collections, saved-data lookup, and AI
planning. The former overview shortcut grid and repeated Find more places footer
are removed. Empty current days don't show a misleading caught-up Today card;
saved commitments and time-zone review still surface Today. From Explore,
Save to trip includes day dates and itinerary
counts and can add the place to a new day in a single library update. Existing
duplicate and capacity checks remain in place.

Source review cases for this flow include destination changes during debounce,
adding repeatedly without closing, Undo after switching days, external stop edits
or deletion, missing map coordinates, day capacity, and creating a day while
saving. Local preview definitions cover search results, long names, empty days,
feedback, narrow widths, dark appearance, and accessibility text.

Day directions are a host callback, with the route capacity supplied by the host.
A multi-place route starts at the first planned place and visits the rest in order.
A single place uses the existing starting-point chooser and authorized current
location behavior. Longer days show the supported limit instead of dropping stops.

Checklists store bounded items in TripPlan's JSON payload. Older payloads decode
with an empty checklist; the SwiftData schema is unchanged. Templates skip existing
titles. Duplicating a trip or saving an AI draft carries the checklist forward with
all items pending. Widget snapshots contain checklist counts only. Authenticated checklist actions
resolve requested text from the canonical saved library.

The AI planner offers saved-place selection, pace, interests, and freeform preferences.
Changing any planning input cancels the current request and invalidates the draft.
Source-place changes are reconciled before generation and saving. Guided generation
is bounded to 24 selected places and 1–5 days; assembly includes every selected place
once, repairs invalid/repeated indices, and groups omitted places into available days.
Only place metadata and explicit preferences go to Foundation Models. Original stop
notes are restored locally when saving the reviewed result. Geography is calculated
before prompting; the model receives nearby-place distances instead of doing coordinate
math. A bounded local route-order pass reduces backtracking within each generated day.
The review labels straight-line distance and warns about days that exceed the chosen pace.
Refine draft can reduce backtracking, distribute food stops, or spread stops over another day.
Drafts remain visible while refining; changed choices disable saving until regeneration.

Use this plan asks for confirmation and applies through TripItineraryRevision. It checks
the exact source days and start date, retains every planned place, preserves existing day
and stop identities and notes, and leaves collections and checklist state untouched.
Journey events, scheduled days, fixed arrivals, repeated visits, active tracking, and removed day notes
prevent replacement; Save as new trip remains available. A 60-second deadline bounds
AI generation, with cancellation and stale-result checks. Private notes never enter prompts.

The trip library searches trip names, collections, saved place names, categories,
addresses, and event titles, types, and locations. Saving a map result skips trip
selection when the library contains one trip.

## Complete journey timeline

Choose **Add to day** beneath any day or in its options menu. Flights, trains,
hotel stays, reservations, personal activities, and free time appear alongside
place visits. The menu opens the chosen type directly; free time starts with a
usable title. The compact native editor presents the title, optional location,
and notes. Date and time has a readable summary and opens a focused subpage with
independently optional start/end times. End-day choices follow the start day;
moving the start beyond the end also moves the end forward. Saving does not
require a place or enable day scheduling. Tap an event to edit it; cancelling
confirms before discarding changes, while an unchanged draft dismisses freely.
Save failures present an alert and preserve the draft. Delete in the editor
confirms removal from every day.

Each `TripEvent` is stored once in `TripPlan.events`, identified by UUID, with
stable start/end day IDs. A three-night stay spans check-in through check-out
across four days. Its intermediate rows say “Staying here”; all rows edit the
same record. Untimed walks and free time keep flexible timing in their editor
and shared summaries without an extra status line on every row. Rows preview
two lines of notes; the full notes remain available in the editor. Trip/day
counts, library search, duplication, and text sharing include events. Event notes
stay out of shared text and system projections.

Native Edit drag handles reorder events and visits together. `TripDay.itemOrder`
records the mixed sequence; place ordering still drives maps, routes, and place
schedules. Removed identities are ignored, new items append, and place-order
changes from other workflows retain event slots. Dragging changes display order,
not saved event times. Multi-day events can have different positions on each day.

Draft saves validate the original event, trip date, and day identities/order so
another window’s edits cannot be silently overwritten. Deleting a day removes
events confined to it and trims spanning events to their surviving days; a
removed endpoint’s time is cleared. Day moves that reverse or change a multi-day
event’s covered days are rejected with an explanation. AI replacement cannot
discard journey events; Save as new trip remains available.

Legacy JSON defaults to empty events and mixed-order arrays. Events use the
existing revisioned local persistence path without a SwiftData schema change.
Limits are 300 events per trip, 80 title characters, and 1,000 characters for
each detail field. No provider or network service is required.

Times use saved destination and booking endpoint zones, with reviewed migration
for older schedules; see [destination times and Today](TripTimeAndToday.md).
Event times are independent of place
timing estimates, with that limitation labeled in mixed scheduled days and
shared summaries. Routes, visit tracking, widgets, and AI planning remain based
on place visits. Automatic event conflict detection and routing integration are
separate roadmap work.

`TripJourneyPreview` covers a flight, a three-night stay, a place visit, an
untimed walk, and free time. Named previews include mixed ordering, editing,
continuing stays, save failure, discard confirmation, dark appearance, and accessibility text. Standalone journey
checks cover legacy decoding, persistence, duplication, stable span identities,
day removal, reordering, and invalid times; run them only when requested with
`bash scripts/performance.sh check`.

## Timed itineraries

Open a day's menu and choose **Plan times**. Set the first arrival and target finish;
tap a timed stop or choose **Edit visit time** to change its duration, incoming travel
allowance, buffer, or fixed arrival. Native forms keep edits local until Save;
Cancel discards them. Other-window changes to the same settings block a stale save.

Schedules are optional. Older trip JSON loads with scheduling off and default visit
settings; the SwiftData schema is unchanged. Disabling scheduling retains settings.
TripDomain builds an ordered timeline in one pass, with identity-based row lookup.
Travel and buffer apply before each stop except the first. Fixed arrivals introduce
free time when reachable and show lateness when preceding visits run too long.
Nothing silently reorders stops or changes a reservation. A target finish at or
before the start means the following day; fixed arrivals can use either day.

Times use the trip's saved destination zone. Repeated clock targets require an
occurrence choice; nonexistent targets require correction. Durations use elapsed
minutes across daylight-saving changes. Opening hours and live road estimates
remain separate roadmap items.
Day/trip sharing includes planned times and warnings, labeled with manual allowances.
Moving a stop retains its timing and identity. Adding a saved place to another day
or saving an AI arrangement preserves duration/allowances and clears fixed arrivals.
AI arrangements start with scheduling off; review and schedule the new days yourself.

Standalone correctness checks cover sequential and fixed arrivals, reordering,
overnight days, older payloads, bounds, and daylight-saving changes. Run them only
when requested with `bash scripts/performance.sh check`; previews cover normal,
conflicting, overnight, dark, and accessibility text states.

## Visual itinerary

Normal-mode itinerary rows use SwiftUI reorder containers to drag flexible places
within or between days. Bookings and fixed-arrival visits remain outside the
draggable groups; the group identity preserves the intended mixed-timeline gap.
`TripStopTransfer` applies the change atomically by saved identities, preserves
notes and timing values, and rejects stale days/calendar context, duplicate places,
full days and same-day moves across a fixed arrival. Active tracking disables this
drag workflow. Edit mode retains the established mixed-item reorder and delete
actions; the Move to day menu remains available for accessible destination choice.

Visit completion draws a checkmark in the existing numbered rail, and Undo restores
the number. Checklist completion uses the same drawing primitive. The existing
tracking progress and next-place text animate their own changes without moving the
map or starting playback. Reduce Motion retains the final state immediately.

Visit-time editing uses native five-minute sliders with hourly tick marks across
the existing duration/allowance bounds. The existing draft setter clamps values;
the planned time updates in place. Save, Cancel, fixed arrivals, destination zones
and stale-edit protection retain their existing contracts.

The day-by-day itinerary remains the main trip detail. Each day shows its date and
place/event count, followed by the mixed journey items. A category-colored rail
uses numbers for places and symbols for events beside the editable rows. It is decorative,
ignores hit testing, and does not determine row height. Its width scales with text.
Native swipe, reorder, place, timing, and menu actions remain on those same rows.
There is no duplicate stop preview or chart dashboard above the itinerary.

Each day has one native Add to day menu for places, flights, trains, stays,
reservations, personal activities, and free time. Choosing an event type opens its
focused editor directly. Plan times remains in Day options.
Scheduled days show a compact place time range and any place conflicts. The detailed time chart
appears only inside the schedule editor, where changing the start or finish time
updates the breakdown of visits, travel allowances, buffer/gaps, and open time.
The target line appears when the plan overruns, alongside the existing warning.
Values use TripDayTimeline, including overnight schedules and fixed-arrival gaps;
travel remains a manual allowance. No new routing or imagery requests are made.

Named previews cover empty and populated days, dark appearance, large text,
overnight schedules, and conflicts. Source audits and builds verify structure and
compilation; runtime visual verification is separate and requires authorization.

## Map and local stop-order suggestions

The itinerary opens with a compact date/count summary and optional notes, then
Today when relevant and the day-by-day plan. The prominent map-preview card,
Preview day action, and replay/player flow have been removed. No camera playback
or automatic stop-advancing task runs in the day map.

Open **Trip options → Map** to inspect the trip's saved places, or use a day's
**Show day on map** action to open that day directly. Trip options shows Map only
when at least one itinerary place has a valid coordinate. The map's native day
picker switches days; numbered pins, direct stop selection, Show all places,
and Directions remain available. Saved trips, events, visit progress, and
stop ordering are unchanged by removing the preview feature.

### Saved-place map and ordering

Trip map is a native MapKit view of one itinerary day at a time. Its numbered
markers and list use the same stable stop IDs. The list keeps every stop reachable
when map markers overlap; missing coordinates remain listed with an explanation.
The layout uses a native split arrangement on supported iOS versions and an
identity-preserving layout based on container aspect ratio on other platforms.
In vertical layouts the list requests a text-scaled preferred height, leaving the
remaining space for the map; the fallback caps the list at half the available height.
It retains native map controls and attribution in safe areas.
On iOS its navigation-bar background stays clear; the native map background extension
carries the canvas behind the header. The stop list keeps the soft top scroll edge.
Selecting a pin reveals and highlights its matching list row. Selecting a row
recenters the map while preserving the current zoom, heading, and pitch. Show in
Explore and Share are available in each mapped stop's visible actions menu. Day directions stays
in the pinned list header instead of scrolling after the last stop.
Day switching and explicit focus/fit animate unless Reduce Motion is enabled.
Shared-library changes reconcile selection; framing changes only when mapped stop
identities or coordinates change. Notes, names, and order edits preserve the camera.
An empty day shows one recovery message; a day with only missing locations shows
its list without an empty map pane. Directions continues through TripEnvironment.

Suggest stop order runs the bounded TripStopOrderService actor in TripIntelligence.
It uses geographic distances, fixed-start nearest-neighbor ordering and bounded
segment reversals, considering the original order too. It makes no network or AI
request and does not claim the shortest road route. The review labels straight-line
distance and excludes opening hours, reservations, and travel times from its claims.
An improvement must reach both 25 meters and 1% before it is offered for application.

TripStopOrderProposal in TripDomain checks the day, ordered stop IDs, coordinates,
and first-stop identity before applying. Applying preserves current stop objects and
notes. The workflow refuses application during active tracking of that day or a visit
update. Changed/deleted days disable Apply; dismissing the sheet cancels calculation.
Individual-day shares include the date, ordered place names, addresses and Maps
links, but do not include private day or stop notes.

## Preview a day and save a place in context

Day options → **Preview day** opens an isolated map and visit-order review. Native
reorder handles and accessibility actions move flexible visits; fixed-arrival
visits cannot move or be crossed. Restore original order and Cancel write nothing.
Apply changes only the reviewed day's visit ordering. Booking records, fixed
arrival values, travel allowances and other trip data stay intact. A changed day,
date, time zone or booking invalidates Apply; active tracking also blocks it.

**Save to Trip** offers a nearby-day suggestion and opens the same review sheet.
The insertion picker can choose any gap, including the end of an empty day.
Other days and Save for Later collections remain available in the existing flow.
Ranking uses extra geographic distance, excludes duplicate/full days, and only
calls a neighbor nearby within 5 km. It is not a road-route optimizer. No added
travel-time claim is inferred from coordinates.

The review shows the proposed schedule using saved travel and buffer allowances.
Walking, driving and cycling routes use current MapKit conditions and are labeled
estimates. A route that exceeds an allowance warns on that visit. Routing does not
silently overwrite manually planned times. Booking overlaps include transfer time;
hotel stays only reserve check-in/out instants, not the entire accommodation span.
Unschedulable/unreviewed clocks and missing locations remain explicit.

MapKit requests are cancellable, debounced and capped at twelve new legs per
refresh. Larger days can request another batch; unavailable legs remain dashed
connectors, with no fabricated duration. Route-cache ownership is local to the
review. Only the save sheet presents insertion drafts; only the itinerary presents
reorder drafts, preventing competing presentations across retained tabs.

Same-file previews use local place/booking fixtures and an offline routing provider;
the native map basemap still depends on system map availability. Source audits
cover structure and localization. Builds, live routing, gestures and rendered
accessibility layouts require separately requested verification.

Native booking capture, explicit exports and alarms, and planned-visit weather follow
[the native travel service contract](NativeTravelServices.md). Reusable adapters stay
in TripIntegrations; feature models receive TripDomain protocols from AppTripServices.
