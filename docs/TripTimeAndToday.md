# Destination times and Today

## Destination time zones

Edit trip → Time zone lets the traveler choose the calendar zone and review the
departure date. Existing trips without this data stay marked for review; opening
them never guesses and permanently saves a zone. Saving the reviewed choice
preserves existing wall-clock booking times and converts them into zoned values.
An unchanged legacy trip can still be opened and edited without migration.

TripPlan stores a civil start date and zone identifier. Its calendar-day arithmetic
uses that zone, including 23- and 25-hour days. TripZonedDateTime stores a local
date, clock minute, zone identifier, and repeated-time occurrence. Instants are
resolved from those values rather than the device's current time zone.

Event → Date and time edits departure and arrival independently, including their
local dates and zones. Itinerary day placement stays separate from those local
dates, allowing overnight and date-line travel. Elapsed time compares instants.
Changing the trip date or destination zone does not move saved zoned bookings.

Times skipped by a clock change cannot be saved. Repeated times require an
explicit first/second occurrence, labeled with its UTC offset. The same rules
apply to fixed place arrivals and day start/finish targets. Invalid older targets
show Review schedule; Today does not derive leave-by guidance from them.

Native date pickers use a neutral calendar for editing civil components so they
cannot silently normalize a nonexistent wall-clock time. Presentation uses the
saved zone. Library date badges, itinerary rows, sharing, lookup, Siri briefings,
widgets, and Live Activities use these values. Older system snapshots still decode.
Date and zone changes in another window reject stale schedule or event saves.

## Today inside Trips

An active itinerary day exposes a Today row inside the existing trip editor.
Today chooses the next saved commitment, provides one main action, and reveals
the remaining day in a disclosure group. Upcoming timed commitments precede
flexible plans; ongoing hotel stays do not hide the next place. Visit completion
uses explicit progress for the same trip and day, never inferred location.

Directions opens the existing route flow for exactly the selected place. Saved
events open their existing detail editor. Their saved location and notes also
appear directly in Today, including without a connection. A standalone host
without a directions callback offers Show on map. Missing trip/day/content and
unreviewed time states have native recovery paths.

Leave-by guidance subtracts the user's manual travel and buffer allowances from
the planned arrival. The first place's incoming allowance is editable without
changing the day timeline's first-arrival semantics. Events have an optional
manual travel allowance in Date and time. These values are clearly labeled;
there is no live traffic, automatic ETA, or automatic completion claim.

Today updates its time-based presentation once per minute while presented. It
reads bounded local snapshots and makes no search or routing requests itself.
Routing remains subject to the existing route flow's connection requirements.

Ticket/document attachments depend on roadmap #4 and are not implemented here.
Today currently provides saved event details and notes; it has no placeholder
ticket button. The ticket portion of roadmap #3's ship bar remains dependent on #4.

## Verification

Use the source gate in [Contributing](../CONTRIBUTING.md). Request compilation and runtime checks separately; source checks do not verify rendered behavior.
