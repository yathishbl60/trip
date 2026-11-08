# Trips development guide

Use this guide when changing saved trips, editing, planning or travel workflows.
Start at `trip/Features/Trips/Views/Library/TripManagerView.swift` → `TripController`
→ `TripModel`. App constructs production models; the feature does not depend on
Explore or choose application navigation. [Local trip planning](../TRIPS.md)
describes the user-facing entry points.

## Choose the owner

Paths below are relative to `trip/Features/Trips` unless a package is named.

| Change | Owning models or contracts |
| --- | --- |
| Saved snapshots, filtering and persistence | `Models/Library/TripLibraryModel` and its extensions |
| Workflow composition and cross-workflow actions | `Models/Workspace/TripModel` and its extensions |
| Selection, routes and shared presentation | `Models/Presentation/TripPresentationModel`, `TripDetailRoute`, `TripPlaceSaveSession` |
| Trip settings and event drafts | `Models/Editing/TripEditDraft`, `TripEventDraft` |
| Checklist and packing | `Models/Checklist/TripChecklistModel`, `TripPackingModel` |
| Collections | `Models/Collections/TripCollectionsModel`, `TripCollectionDraft` |
| Itinerary generation | `Models/Assistant/TripAssistantModel` |
| Saved-detail lookup | `Models/Lookup/TripLookupModel` |
| Place search and destination selection | `Models/Search`, `TripModel+DayPlanning` |
| Schedule and visit timing drafts | `Models/Scheduling`, TripDomain timeline values |
| Mixed bookings/places and Today | `Models/Journey`, TripDomain journey and Today values |
| Saved-place map | `Models/Map/TripMapModel`, `TripMapController` |
| Local stop-order proposal | `Models/Ordering/TripStopOrderModel`, `TripStopOrderProposal` |
| Day/insertion review and route estimates | `Models/Planning`, `TripModel+Planning` |
| Import, native actions and weather review | `Models/BookingImport`, `Models/SystemActions`, `Models/Weather` |
| Visit tracking | `Models/Tracking`, shared journey runtime |

Find exact paths and consumers with `workspace.py context Trips --json`. Add
behavior to the focused owner before adding another root-model extension. Views
render state and call struct controllers; controllers do not assemble plans or
choose persistence policy. [Dependencies](Dependencies.md) defines injection and
[App](App.md) defines semantic host entry points.

## Durable edits and recovery

`TripLibraryModel.trips` is read-only outside the library. Use `insert`, `update`,
`updateDay`, `updateCollection` and `remove`. Update closures edit a copy: return
true to commit and schedule persistence, false to discard it. A workflow does not
call `persist` directly. Index actions resolve stable identities before editing;
identity-based actions reject missing records.

TripDomain's `TripLimits` is the shared source for counts and text bounds. The
library guards readiness and trip capacity; workflows own validation, duplicate
policy, notices and feedback. Do not duplicate limits in a view.

One library owns one store-session revision sequence. A 250 ms debounce coalesces
writes; changed IDs allow partial payload updates. Failed writes retain dirty
state for retry, and old completions cannot clear newer edits. App flushes on
inactivity. Concurrent loads share one task; retry keeps the failure explanation
visible while replacing Retry with loading state.

`loadedTrips` supplies an already-known snapshot for fixtures or a loaded host;
normal construction leaves it nil. TripStorage owns its lazy, local-only SwiftData
container, private schema and rollback. Legacy `trips.json` imports once, with a
durable marker preventing later empty libraries from reimporting old data.

## Draft and presentation identity

Edit local drafts, then validate current saved data before committing. A trip
settings draft merges only edited fields so it cannot replace other windows'
itinerary changes. Day, event, visit and ordering drafts retain the source context
needed to reject stale saves. Never replace a complete saved plan with a form draft.

Every presentation has a session identity. Late Save, Cancel, dismissal or deletion
callbacks must match the active session, including when the same entity is reopened.
`TripPlaceSaveSession` is independent of Place.id. Navigation routes also carry a
visit identity; repeated destinations preserve their current visit and lookup state.

Trip settings, events, schedules, visit timing and placement/order reviews protect
changed drafts from interactive dismissal. Unchanged drafts close immediately;
Cancel on changed drafts offers discard confirmation and lets the user continue
editing. Opening a suggested placement alone is not a change, and restoring the
original values removes the warning.

For a new settings field, add a durable domain value if needed, extend TripEditDraft's
validation and field merge, expose its controller binding, then render it in
TripEditView. For host behavior, extend the narrow environment or host operation
and wire App composition; do not retain the other feature's model.

## Checklist and Collections

Checklist and packing views receive `TripChecklistController`. TripChecklistModel
owns naming and packing sessions, the shared library, and its injected packing
worker. Its environment supplies feedback, Reminders review and entity identifiers;
TripEditorView supplies section navigation. Suspension cancels generation without
discarding the visible review. TripModel includes this workflow in editing protection
and resets presentation when selecting another trip.

Checklist items live in the plan payload; older payloads decode an empty checklist.
Templates skip existing titles. Duplication and saving an AI draft reset completion.
UI and intent completion use `TripChecklistEditing.setComplete`. Shared system
snapshots contain counts, not checklist text; authenticated actions resolve text
from the canonical library.

Collection views receive `TripCollectionsController`. TripCollectionsModel owns
naming/deletion sessions, notices and saved-place edits. Its environment delegates
map navigation, feedback and day scheduling; TripModel keeps day-insertion policy
and save-sheet dismissal. Session IDs protect naming, deletion and stale bindings.

`TripCollectionEditing` shares title validation, creation, rename and place-append
rules with intents. Titles are trimmed, bounded and single-line; legitimate Unicode
joiners remain valid. Saved places use duplicate-place and capacity checks. Intent
creation additionally resolves normalized names for repeatability and rejects
ambiguous matches; do not silently choose among duplicate saved names. Collection
IDs remain stable when renamed. See [System integrations](../SYSTEM-INTEGRATIONS.md)
for authenticated discovery and mutation behavior.

## Adding and moving places

Add to day opens native search for saved places and Apple Maps. The sheet keeps
trip/day context and supports multiple additions. Search is anchored to the selected
day's last valid coordinate, falling back to the trip's first mapped place. Adding
results does not move that origin. Changing days cancels the old search and replaces
its results. Without a query, contextual categories use real MapKit searches.

A successful addition marks the result and offers Undo for the exact new stop on
its original day. Changed, moved or removed stops are protected; switching days does
not lose the latest undo while the sheet remains open. A deleted destination selects
a surviving day with an explanation; trip deletion cancels search. Copies of saved
places keep notes and duration/allowances but clear fixed arrivals. Live results
retain Maps identity. See [Search](Search.md) for debounce, timeouts and matching.

Duplicate/full destinations are unavailable. Save to Trip can add a day and its
first place in one library mutation. Moving a stop preserves its identity and notes;
moving a day retains its ID and renumbers its calendar position.

Normal-mode drag groups contain flexible visits. `TripStopTransfer` applies moves
atomically by identity and rejects stale calendar/day context, duplicate/full days,
and crossing a fixed arrival. Active tracking blocks this workflow. Native Edit
mode still reorders mixed items, and Move to day provides an accessible alternative.

## Bookings and mixed timelines

Add to day opens the selected event type directly: flight, train, stay, reservation,
activity or free time. Event editors keep title, optional location, notes and
independent start/end times in a draft. They do not require a place or enable day
scheduling. Save failures preserve the draft; Delete confirms removal from every day.

A `TripEvent` is stored once in `TripPlan.events`, with stable start/end day IDs.
Multi-day rows edit that same record; intermediate stay rows represent ongoing
accommodation. `TripDay.itemOrder` stores mixed visit/event display order. Missing
IDs are ignored, new items append, and changes to place order preserve event slots.
Dragging display order does not change saved times.

Event saves validate the original record, trip date and day identities/order.
Deleting a day removes events confined to it and trims spanning events; removing
an endpoint clears its time. Day moves cannot reverse or change a multi-day event's
covered days. Older payloads default to empty events and mixed-order arrays.
Use TripLimits for event counts and field lengths.

Library search, duplication, sharing and system agenda projections include events.
Private event notes stay out of shared text and system projections. Routes and
visit tracking operate on place visits; do not treat a booking as a routed stop.
Event times and place timing estimates remain distinct, with their relationship
reviewed in the planning workflow.

## Schedules, Today and visual presentation

Day options → Plan times edits the first arrival and target finish. Visit timing
holds duration, incoming travel, buffer and optional fixed arrival. Schedules are
optional; disabling them retains settings. The linear timeline applies travel and
buffer before each stop except the first, shows reachable free gaps and lateness,
and never silently reorders visits or changes reservations. A finish at/before the
start means the following day; fixed arrivals can use either day.

Saved zones, repeated/skipped clocks, elapsed durations and Today follow
[Destination times and Today](TripTimeAndToday.md). Sharing labels manual allowances.
AI-created days start with scheduling off; review their times separately.

Keep the itinerary as the main detail: compact summary, relevant Today entry and
day-by-day mixed rows. The numbered/symbol rail is decorative, scales with text and
ignores hit testing. Completion changes that existing rail; it does not move the
map or start playback. Respect Reduce Motion. Detailed time charts belong in the
schedule editor, using TripDayTimeline, not a duplicate dashboard on the itinerary.

## Day review and saved-place map

Day options → Preview day opens a local order and schedule review. Reorder actions
move flexible visits without crossing fixed arrivals. Restore and Cancel write
nothing; Apply changes only reviewed visit order. Changes to the day, date, zone
or bookings invalidate Apply, as does active tracking.

Save to Trip can open the same review with an insertion position. Ranking uses
extra geographic distance, excludes duplicate/full days and labels nearby only
within 5 km. Any insertion gap, including an empty day's end, can be selected.
Other days and collections remain available in the save flow.

The review compares saved travel/buffer allowances with MapKit walking, driving
or cycling estimates. Routing does not overwrite allowances. Booking overlaps
include transfer time; stays reserve check-in/out instants rather than the entire
stay. Unreviewed clocks, missing locations and unavailable routes remain explicit.
Requests debounce, cancel and use a local cache, with at most twelve new legs per
refresh and a further batch on demand. Failed legs use connectors without invented
durations. Only save sheets present insertion drafts; itinerary sheets present
reorder drafts, preventing duplicate presentations across retained tabs.

Trip options → Map or Show day on map opens the saved-place map. Stable stop IDs
connect numbered markers to list rows, including places without coordinates. Pin
selection reveals the row; row selection preserves zoom, heading and pitch while
recentering. Camera fitting changes only when mapped identities/coordinates change,
not for notes, names or order. Day switching and explicit fit/focus respect Reduce
Motion. Keep native map controls, attribution and reachable list actions.

The map/list layout follows a usable measured fold or ordinary container aspect
ratio. A day with only missing locations shows its list without an empty map pane.
See [Adaptive app](../UNIVERSAL-APP.md) for pane and safe-area behavior. Day directions
use the host callback and declared route capacity: longer days explain the limit
rather than dropping stops. Single-place routes use the normal starting-point chooser.

## Stop-order proposals and AI planning

`TripStopOrderService` uses local geographic distances, a fixed first stop and
bounded ordering passes; it makes no network or AI request. Offer an improvement
only when it reaches both 25 metres and 1%. Label straight-line distance and do not
claim road-route, opening-hour, reservation or travel-time optimization.
`TripStopOrderProposal` revalidates day/stop identities and coordinates, preserves
current stop objects and notes, and rejects active tracking or a visit update.
Dismissing the review cancels calculation.

The itinerary assistant accepts up to 24 selected places and 1–5 days. Input changes
cancel work and invalidate the draft; source-place changes are reconciled before
generation and saving. Assembly includes each selected place once, repairs invalid
indices and fills omitted places. Only place metadata and explicit preferences go
to Foundation Models. Geography is calculated locally; private notes are restored
locally when saving, never sent in prompts.

Refinement keeps the draft visible while recalculating. A 60-second deadline,
cancellation and generation checks bound the request. Applying through
`TripItineraryRevision` checks the exact source days and start date, retains planned
places, identities and notes, and leaves collections/checklist untouched. Events,
scheduling, fixed arrivals, repeated visits, active tracking or loss of day notes
can block replacement; Save as new trip remains the alternative.

## Making and checking a change

1. Choose the owning workflow and inspect its existing entry point and draft policy.
2. Reuse domain mutation rules and inject new service contracts through App.
3. Keep canonical-ID, session, cancellation and persistence guards at mutation boundaries.
4. Add or update the smallest local preview in [Preview support](PreviewSupport.md).
5. Follow [Contributing](../CONTRIBUTING.md) and [Testing](Testing.md) for scoped checks.

Review adjacent save/reload, multi-window edits, failure/retry, cancellation, stale
sheet dismissal and accessibility behavior. For service work use
[Native travel services](NativeTravelServices.md); for text use [Localization](Localization.md).
Report source, compilation, executable and visual verification separately.
