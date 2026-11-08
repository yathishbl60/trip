# Local trip planning

Trips keeps saved places, bookings, day plans, collections and checklists in a local
library. Manual planning works without Apple Intelligence. Cloud sync and shared
editing between people are not implemented.

Use this guide to preserve the traveler-facing flow when changing Trips. Start
with the [Trips developer guide](docs/Trips.md) for source paths and editing
contracts, then review the affected entry points below.

## Create and organize a trip

Open **Trips**, create a named trip, choose its departure date and destination time
zone, and add days. Creating a trip opens the itinerary. From Explore, **Save to
trip** can add a place to a day or a Save for Later collection; creating a trip
there saves the place and returns to the map.

The itinerary is the main detail view. Each day shows its places and bookings.
**Add to day** offers places, flights, trains, stays, reservations, activities and
free time. Tap a booking to edit its details; multi-day stays remain one saved
record. **Edit Trip** opens a cancellable draft for the trip's settings and notes.

Use native Edit controls for reordering and deleting. Flexible places also support
dragging between days; fixed arrivals and bookings retain their timing constraints.
**Collections** holds places for later, with actions to add a place to a day or show
it on the map. **Checklist** keeps preparation items, reusable templates and optional
packing suggestions. Duplicating a trip resets checklist completion.

## Plan a day

| Task | Entry point | What it does |
| --- | --- | --- |
| Add several places | Add to day → Places | Searches saved places and Apple Maps; keeps the sheet open and offers Undo for the latest addition |
| Review order and travel | Day options → Preview day | Reviews visit order, route estimates and the proposed schedule before Apply |
| Set a schedule | Day options → Plan times | Edits first arrival and target finish; visit editors hold duration, travel and buffer allowances |
| Inspect saved locations | Trip options → Map, or Show day on map | Shows numbered saved stops and a reachable list for each day |
| Get directions | Day options or Trip map → Directions | Opens the route flow for the day's places in saved order |
| Reduce backtracking | Day options → Suggest stop order | Offers a local geographic proposal for eligible days with at least three places |

Preview day keeps changes local until Apply. Save to Trip can open the same review
with a suggested insertion position. Route estimates use MapKit conditions and do
not overwrite manual allowances. Missing routes remain explicit.

Suggest stop order keeps the first stop fixed and requires explicit application.
Its distances are straight-line estimates, not road routes or travel times; it does
not consider opening hours or reservations. Changed days invalidate the proposal.

Schedules use saved destination time zones. Booking departure and arrival can have
different dates and zones. Clock changes requiring review are shown explicitly;
changing devices' time zones does not redefine saved zoned bookings. See
[Destination times and Today](docs/TripTimeAndToday.md).

## Use the plan while traveling

Today surfaces the next saved commitment and the rest of the active day. It opens
the existing directions or booking editor. Leave-by guidance uses manually entered
travel and buffer allowances; it is not live traffic or automatic ETA.

Day menus offer visit tracking where supported. Completion is explicit, not inferred
from location. Widgets and Live Activities show saved trip context and progress.
Siri and Shortcuts can read and act on saved trips, collections, checklists and
visits, or open existing review workflows. See [System integrations](SYSTEM-INTEGRATIONS.md)
for the exact action coverage and platform requirements.

Trip and day Share actions send readable itinerary text through the native share
sheet, not private database records. Day shares exclude private day and stop notes;
booking notes also remain private.

## On-device itinerary assistant

**Draft an itinerary** offers optional Apple Intelligence planning for up to 24
saved places and 1–5 days, with pace, interests and preferences. The model receives
place metadata and calculated nearby distances, not private notes or checklist
contents. Suggestions use supplied places and do not invent opening hours, prices
or travel times.

Review or refine the proposal before applying it. Replacing the current itinerary
requires an unchanged compatible source and preserves stable identities and notes;
scheduled visits, bookings and other protected states can require saving a new trip
instead. A new trip preserves the original and resets checklist completion.
Changing inputs invalidates old drafts, and cancellation rejects late results.

Availability messages explain unsupported hardware, disabled Intelligence or model
downloads. Private Cloud Compute is disabled in the checked-in configuration;
manual planning remains available.

## Saving and recovery

Trips uses local SwiftData storage. Edits are coalesced for 250 milliseconds, writes
are revision guarded, and pending changes flush when a scene becomes inactive.
Failed writes retain pending edits and offer retry. The earlier `trips.json` format
is imported once; deleting the library does not resurrect that legacy data.

When changing these flows, use local fixtures and check save/cancel, stale edits,
failed-write recovery and the surrounding navigation. Fixtures never touch the
user's database. See [Dependencies](docs/Dependencies.md) for provider lifetimes and
[Contributing](CONTRIBUTING.md) for contribution setup and scoped checks.
