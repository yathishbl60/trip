# Destination times and Today

Use this guide when changing departure dates, booking clocks, schedule arithmetic,
Today, or time values shared with system surfaces. A trip's civil date and saved
zone are distinct from the device clock and from a booking endpoint's zone.

## Find the owning code

| Responsibility | Start with |
| --- | --- |
| Civil calendar values and trip dates | `Packages/TripKit/Sources/TripDomain/Trips/TripLocalDate.swift`, `TripPlan+Calendar.swift` |
| Zoned clocks and repeated-time resolution | `TripDomain/Trips/TripZonedDateTime.swift` |
| Day schedule and visit timing | `TripDomain/Trips/TripDaySchedule`, `TripStopTiming`, `TripDayTimeline` |
| Editable clocks and zone selection | `trip/Features/Trips/Models/Scheduling`, `Models/Editing/TripEventDraft+ZonedTime.swift` |
| Today projection | `TripDomain/Trips/TripTodaySnapshot`, `TripTodayProjection`, `TripTodayItem` |
| Today presentation | `trip/Features/Trips/Models/Journey/TripTodayModel.swift`, `Views/Today` |

`TripDomain/...` entries are relative to `Packages/TripKit/Sources`.

## Preserve civil time semantics

Edit Trip → Time zone lets the traveler review the calendar zone and departure
date. Legacy trips without reviewed zone data remain marked for review. Opening
one must not guess and persist a zone. Saving the reviewed choice preserves prior
wall-clock booking times when converting to zoned values; unrelated legacy edits
can remain unmigrated.

TripPlan stores a civil start date and zone ID. Calendar-day arithmetic follows
that zone, including 23- and 25-hour days. `TripZonedDateTime` stores local date,
clock minute, zone ID and repeated-time occurrence; resolve the instant from those
values, not the device's current zone.

Booking departure and arrival have independent dates and zones. Itinerary day
placement remains separate, allowing overnight and date-line travel. Compare
instants for elapsed duration. Changing a trip date or zone does not move already
saved zoned bookings.

Reject nonexistent times skipped by a clock change. Repeated times require an
explicit first/second occurrence, labeled with UTC offset. Apply this to booking
endpoints, fixed arrivals and day start/finish targets. Invalid older targets show
Review schedule; they must not produce leave-by guidance.

Civil-component pickers use a neutral calendar so native date normalization cannot
silently turn a nonexistent time into a different one. Display and share saved
values in their saved zones. Keep backward-compatible decoding for system snapshots
and reject draft saves when another window changes the relevant date/zone context.

## Keep Today focused

The itinerary shows a Today entry when the active day has saved commitments or the
trip needs time-zone review. Today chooses the next saved commitment, one primary
action and the remaining agenda. Upcoming timed commitments precede flexible plans;
an ongoing stay must not hide the next place. Completion comes from explicit visit
progress for the same trip/day, never inferred location.

Place actions open the existing directions flow; saved events open their editor.
Saved location and notes remain readable offline. A host without directions offers
Show on map. Missing trip/day/content and unreviewed clocks retain recovery paths.

Leave-by guidance subtracts manual travel and buffer allowances from planned arrival.
The first place's incoming allowance is editable without changing the timeline's
first-arrival semantics. Events have optional manual travel allowances. Do not label
these as live traffic, automatic ETA or automatic completion.

Today refreshes its bounded local projection once per minute while presented. It
must not start search or routing itself. Native directions retain their own network
requirements. Saved event details and notes are available; ticket attachments are
not an implemented Today capability.

On a partially open Duo, Up Next and Rest of the Day can use independently scrollable
panes along the measured fold. Use one larger pane when either side is too small or
only one section has content. Returning to one list restores disclosure state. See
[Adaptive app](../UNIVERSAL-APP.md) for the shared layout contract.

## Change checklist

Check legacy decoding, skipped/repeated clocks, overnight and date-line bookings,
23/25-hour days, device-zone changes and concurrent edits. Confirm that library,
sharing, lookup and system surfaces display the saved zone consistently. Use
`TripClockPreview`, `TripSchedulePreview` and `TripTodayPreview` for focused local
states. [Testing](Testing.md) and [Contributing](../CONTRIBUTING.md) describe checks;
rendered behavior and real device clocks require separate verification.
