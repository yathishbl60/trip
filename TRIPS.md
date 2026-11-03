# Local trip planning

Trips are stored locally with SwiftData. `TripLibraryModel`, composed by
`TripModel`, owns editable `TripPlan` snapshots on the main actor. All durable
edits use the library’s mutation methods and schedule persistence automatically.
`TripStore` and `TripDatabase` create and use
a local-only model container on a storage actor. Cloud-backed collaboration is
intentionally not part of this version.

## Planning flow

Open **Trips** from the app tab bar, create a named trip, choose a departure
date, and add days. Creating a trip opens its itinerary. From Explore, select
a place and choose **Save to trip**; creating a trip there saves the first stop
and returns to the map.

The itinerary shows each day's places and notes. **Edit** enables reordering,
deleting, and day/stop note fields. **Edit Trip** in the options menu opens a
cancellable draft for the name, departure date, and trip notes. Saving changes
only edited fields, preserving other windows' itinerary edits. **Collections**
opens saved places for later; each place can be added to a day or shown on the map.
Day menus offer visit tracking when supported. The trip list offers duplication
and sharing; the itinerary also has a native Share action.

**Trip map** shows numbered stops for each day with a native day picker, camera fit,
and a selectable place list. Wide windows show the map and list side by side.
Use **Map this day** from a day menu to open it directly, or continue to directions
for the day's places in their saved order.

For days with at least three places, **Suggest stop order** offers a local, reviewable
way to reduce geographic backtracking while keeping the first stop fixed. Compare
the current and suggested order, then apply it explicitly. Distances are straight
line estimates, not road routes or travel times. Reservations and opening hours are
not considered. Suggestions preserve notes and refuse to overwrite changed days.
**Share this day** sends a readable itinerary with addresses and Apple Maps links
through the native share sheet; private day and stop notes are excluded.

The local store migrates the earlier `trips.json` snapshot from Application
Support the first time it opens. The import is marked complete in SwiftData so
deleting every trip does not resurrect old data. Preview fixtures use an
in-memory store and never touch the user's database.

## On-device itinerary assistant

**Draft an itinerary** in the editor's options menu opens the optional Apple Intelligence assistant.
It receives only the selected trip's saved-place names, categories, and
coordinates. It returns a reviewable draft with no invented opening hours,
prices, travel times, or places. Saving creates a new trip, preserving the
original plan. Availability messaging explains when Apple Intelligence is
disabled, downloading, or unsupported; manual planning always remains usable.

## Persistence behavior

Edits are coalesced for 250 milliseconds so typing notes does not write on every
keystroke. Only changed trip payloads are encoded when possible; list position
updates remain cheap. A revision guard prevents an older async write from
overwriting a newer one. Pending edits flush when the scene leaves the active
state, and a retry banner appears if a save fails.

## Shortcuts and sharing

Siri and App Shortcuts open saved trips, create named and dated trips, read itineraries,
draft plans with Apple Intelligence, and track visits. Create Trip saves only after
Siri or Shortcuts supplies the name and departure date. Widgets and Live Activities
show the next place and progress; [SYSTEM-INTEGRATIONS.md](SYSTEM-INTEGRATIONS.md)
describes configuration, App Groups, and verification. Trip `ShareLink` actions share
readable itinerary text; they do not publish private database records.

Trip plans are local to this device for now. A future sync layer can sit behind
`TripStore` without changing the SwiftUI views or the `TripPlan` value model.

For state ownership, injection, and editor change recipes, read the
[Trips developer guide](docs/Trips.md). AppModel owns map/trip integration through
ExploreEnvironment and TripEnvironment; neither feature owns the other.
