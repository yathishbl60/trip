# Feature roadmap

This is a proposal catalog, not a list of missing features or a release promise.
Numbers are stable discussion references. Read the current-scope table before
selecting work; existing implementations may satisfy only part of a proposal.

## Contents

- [Current scope](#current-scope)
- [Product direction](#product-direction)
- [What already exists](#what-already-exists)
- [1–10: make the trip trustworthy and useful every day](#110-make-the-trip-trustworthy-and-useful-every-day)
- [11–20: make planning realistic and effortless](#1120-make-planning-realistic-and-effortless)
- [21–30: coordinate companions and handle real travel](#2130-coordinate-companions-and-handle-real-travel)
- [31–40: tailor the trip to how people actually travel](#3140-tailor-the-trip-to-how-people-actually-travel)
- [41–50: deepen continuity, power use, and long-term value](#4150-deepen-continuity-power-use-and-long-term-value)
- [One coherent interface for all 50](#one-coherent-interface-for-all-50)
- [Engineering foundations and scope gates](#engineering-foundations-and-scope-gates)
- [Recommended delivery sequence](#recommended-delivery-sequence)
- [Quality and business bars](#quality-and-business-bars)
- [How to judge progress](#how-to-judge-progress)

## Current scope

| Proposals | Implemented scope | Remaining scope |
| --- | --- | --- |
| #1–3 | Journey events, destination/endpoint zones, reviewed DST handling, Today and manual leave-by guidance | Ticket access and live travel-derived guidance |
| #5–6 | Place-text Shortcut handoff and reviewed PDF/image/text booking extraction | Native share extension, persistent originals, broad link capture and duplicate reconciliation |
| #10, #12, #31 | Route-backed day review, stop-order suggestions and save-placement review | Broader automatic feasibility and disruption planning |
| #14 | Planned-visit forecast contracts and UI | Eligible WeatherKit signing, live-service validation, saved alternatives |
| #18, #41 | Explicit travel alarms, Calendar export and Reminders export | Ongoing synchronization and wider deadline automation |
| #20, #30, #48 | Saved-detail search, grounded question interpretation and native system surfaces | Document retrieval, live facts and further surface capabilities |

Current contracts are in [Trips](Trips.md), [Today](TripTimeAndToday.md),
[Native travel services](NativeTravelServices.md), and
[System integrations](../SYSTEM-INTEGRATIONS.md). The proposals below describe
full outcomes, including parts beyond the existing implementation.

## Product direction

**Turn scattered travel ideas into a realistic journey, then help people make the
next decision confidently while they travel.**

The opportunity is the combination of easy capture, realistic plans, offline
essentials, calm guidance, and fast recovery when circumstances change. A beautiful
map gets attention; dependable travel earns repeated use.

Design first for independent travelers, couples, and small groups planning city
breaks and multi-city trips. Include families and people with access needs in
the primary flows. Expand specialist use cases after this foundation works well.

Rank by frequency, consequence of failure, effort saved, repeat use, and
dependencies. This is product priority, not a promise to build in strict numeric
order. The current-scope table distinguishes implemented slices from future work.
**Gated** proposals require a capability/provider decision before commitment.

## What already exists

Do not re-add these as missing features:

- Local trips, saved places, collections, notes, duplication, and checklists.
- Optional timed days, fixed arrivals, visit durations, manual travel allowances,
  buffers, overnight schedules, and conflict warnings.
- Day maps, editable stop order, and geographic stop-order suggestions.
- MapKit search, nearby discovery, directions, route alternatives, map styles,
  traffic, Look Around, and Apple Maps handoff.
- Reviewed on-device itinerary drafts and refinements from saved places.
- Text sharing, Siri/Shortcuts, Spotlight, widgets, Live Activities, and explicit
  visit tracking with visit Undo.
- Adaptive iPad/visionOS layouts, multiple windows, and accessibility support.

See [Trips](Trips.md), [Explore](Explore.md), [Directions](Directions.md), and
[system integrations](../SYSTEM-INTEGRATIONS.md). Use those guides for behavior and verification requirements.

## 1–10: make the trip trustworthy and useful every day

### 1. Complete journey timeline

See visits, flights, trains, hotel stays, reservations, personal activities, and
intentional free time in one itinerary. Extend the place-stop model with typed
events, stable identities, and multi-day spans.
**Ship bar:** A flight, a three-night stay, and an untimed walk coexist without
fake places, duplicate bookings, or forced scheduling.

### 2. Destination time zones and correct travel dates

Display departure and arrival in their own local times and dates, with home time
only when helpful. Model local dates, zones, instants, and elapsed durations;
migrate existing device-local schedules through a reviewed choice.
**Ship bar:** Device-zone changes never move a booking; daylight-saving ambiguity,
overnight travel, and date-line crossings remain correct.

### 3. A contextual Today experience

Open the active trip to the next commitment, when to leave, its ticket, and one
clear next action. Make Today an active-trip destination inside Trips, using
#1, #2, and #4. Start with labeled manual travel allowances; route-derived
leave-by guidance follows #10/#18. Reveal the rest of the day on demand.
**Ship bar:** Answer “What next?” and open its route or ticket in at most two
actions from the active trip, including with saved offline content.

### 4. Booking and document wallet

Keep flights, hotels, rail, rental cars, restaurants, and activity tickets beside
their itinerary events. Preserve original confirmations, reference numbers,
contacts, and important dates in typed reservations and protected attachments.
**Ship bar:** Using #1–2, every booking's saved details and every attached original
remain available after an offline relaunch; manual entries need no source file.

### 5. Save to Trip from other apps

Share a Maps place, Safari link, image, PDF, or selected text into Trip; save
directly to an inbox or choose a trip/day. Retain the source and detect duplicate
captures through a focused share extension.
**Ship bar:** A valid share saves with one confirmation and appears once in the
chosen destination, including while offline.

### 6. Reviewed booking import from screenshots, PDFs, and text

Import a confirmation and review dates, airports, names, prices, and uncertain
fields before it becomes a booking. Preserve the original; use extraction tools
with deterministic validation for dates and amounts.
**Ship bar:** Build on #4–5; reconcile duplicates and prevent unconfirmed critical
fields from silently becoming travel commitments.

### 7. An offline essentials pack with a readiness check

Prepare tickets, itinerary items, addresses, contacts, and instructions for
travel. Include an offline help card with chosen emergency contacts, insurer
assistance, and sourced destination help/consular information. Show download
progress, refresh dates, storage use, and failures.
**Ship bar:** Everything marked Ready opens after airplane mode and a cold
relaunch. Base-map downloads belong to the separate gated feature #50.

### 8. Reliable iCloud sync across personal devices

Continue planning on another device, see pending changes, and keep editing during
poor connectivity. Define merge units, deletions, account transitions, migration,
and durable pending changes; use the recovery work in #9.
**Ship bar:** Concurrent edits to unrelated stops both survive, removed content
does not reappear, and unsynced changes remain recoverable.

### 9. Broad Undo, recently deleted, and version recovery

Recover a removed day, mistaken bulk edit, or unwanted plan replacement with a
preview of what will return. Extend visit Undo to durable edits, preserve
attachment references, and define retention.
**Ship bar:** Restore meaningful trip contents without undoing unrelated later
work; add collaborator attribution when #15 ships.

### 10. Real travel times inside the itinerary

Show mode, distance, estimated duration, and schedule impact for every leg.
Connect TripRouting to itinerary timing with bounded requests, freshness labels,
and editable manual fallbacks; remove the current five-stop UX bottleneck.
**Ship bar:** Longer days retain every stop, failed estimates remain explicit,
and stale responses never overwrite newer route choices.

## 11–20: make planning realistic and effortless

### 11. Opening-hours and reservation feasibility checks

Flag closed venues, missed entry windows, overlapping bookings, and impossible
transfers where they occur, with useful corrections. Combine #1–2 and #10 with
verified, dated opening windows, exceptions, and explicit unknown values.
**Ship bar:** Missing information never becomes “open,” and fixed commitments
are never moved without the traveler's choice.

### 12. Constraint-aware day optimization

Improve a day around must-dos, bookings, opening windows, lodging, walking
tolerance, and breaks. Extend current straight-line order suggestions using
#10–11; show time saved and compromises before applying.
**Ship bar:** Deterministic planning preserves locked events and identities,
explains remaining conflicts, and supports Undo without claiming a global optimum.

### 13. Replan the rest of my day

“We are running late” or “Make this afternoon easier” produces a small revision
from actual progress. Extend reviewed drafting to scheduled days using #11–12;
protect visited events, bookings, must-dos, and intentional free time.
**Ship bar:** Show every change before explicit application; preserve the previous
plan and reject stale proposals after concurrent edits.

### 14. Weather-aware plans and saved alternatives

Attach rainy-day alternatives to outdoor activities and swap them without
rebuilding the day. Use forecasts for the actual place/time, with attribution,
freshness, coverage, and forecast-horizon limits.
**Ship bar:** Feed replacements through #11–13 so they fit; distant dates never
display invented forecasts as if they were known.

### 15. Shared trips with clear ownership and permissions

Invite companions as viewers or editors, see who changed the plan, keep personal
notes private, and revoke access. Build on #8–9 with shared/private fields and
explicit conflict rules; separate personal-device sync from multi-person sharing.
**Ship bar:** Concurrent edits survive and future access follows permissions;
private attachments are excluded from shared content by default.

### 16. A global wishlist and travel research inbox

Save “someday” places without creating a trip. Organize by destination, interest,
or personal collection, then add ideas to an itinerary. Reuse place identities
and #5 while preserving links, notes, and an unscheduled state.
**Ship bar:** Adding an idea to a trip retains its context without forcing removal
of the original or producing duplicate places.

### 17. Multi-city journeys with lodging anchors

Plan destination chapters, nights, and travel-only days. Show check-in/out,
luggage gaps, and the day's starting/ending accommodation. Compose #1–2 and #4
into stay spans instead of treating every hotel night as an attraction.
**Ship bar:** Moving a chapter identifies affected dates/bookings for review
while preserving original reservation details.

### 18. Useful departure, check-in, and deadline reminders

Receive a concise leave-by action, check-in prompt, or cancellation deadline with
a direct booking/route link. Use #2, #4, and #10; start with reliable local
deadlines, then add provider-backed changes through #26.
**Ship bar:** Plan edits cancel obsolete reminders, times remain correct, and
notification preferences and Focus are respected.

### 19. Private-by-default guest sharing and printable plans

Preview exactly what others will receive, choose days and fields, then share an
accessible guest view or useful PDF without requiring the app. Extend text
sharing; hosted links require access controls, expiry, and revocation.
**Ship bar:** Private notes/references never appear unexpectedly. Explain that
revocation controls future link access, not copies already downloaded.

### 20. One search across everything in the trip

Find a hotel confirmation, place, private note, ticket, or shared decision in one
search field with typed results and direct actions. Extend existing library
search with permitted local document indexing and shared/private visibility.
**Ship bar:** Saved essentials remain searchable offline; deleted content leaves
the index; every result opens the correct event or file.

## 21–30: coordinate companions and handle real travel

### 21. Group decisions, availability, and lightweight polls

Choose dates, destinations, places, and spend ranges together. Keep proposals,
votes, comments, the decision, and its owner attached to the relevant choice;
support abstention and partial participation through #15.
**Ship bar:** A chosen option becomes a reviewed itinerary change without
duplicates or disclosure of private preferences.

### 22. Shared preparation tasks and responsibilities

Assign “book the train,” “bring the stroller,” or “confirm the hotel” with due
dates and compact progress. Extend checklists with ownership, comments, and
history using #15 and #18; retain personal tasks alongside shared ones.
**Ship bar:** People can identify their responsibilities, and offline completion
reconciles without duplicate tasks or repeated reminders.

### 23. Subgroup plans and reliable meeting points

Let some companions visit a museum while others rest, then show each subgroup
the agreed reunion time and place. Add participant scope and regroup events;
start with manual check-in and separately opt-in, time-limited location sharing.
**Ship bar:** Each person has a coherent day and shared reunion without requiring
continuous background location.

### 24. A useful trip budget before booking

Estimate accommodation, travel, food, and activities; distinguish known prices
from estimates and compare the cost of alternatives. Use exact decimal amounts,
per-person/group costs, source currencies, and dated exchange rates.
**Ship bar:** Totals remain explainable offline; changing reporting currency
never changes original amounts or presents an estimate as a quote.

### 25. Expenses, receipts, refunds, and fair splitting

Capture receipts, record who paid and participated, and see balances with custom
splits and partial repayments. Add a ledger alongside #24; review extracted
amounts and preserve historical rates and refund relationships.
**Ship bar:** Balances reconcile exactly after rounding and refunds across
currencies. Recording settlement does not imply moving money.

### 26. Live flight and transport status

Show verified delays, gate/platform changes, cancellation, and baggage information
beside the booking with an update timestamp. Start with one mode/provider and
plan coverage, backend refresh, push delivery, and operating cost.
**Ship bar:** Missing or stale status falls back to the original booking and
operator link; add rail/ferry coverage only after separate validation.

### 27. Realistic airport and station connections

Explain connection comfort using immigration, terminal changes, baggage reclaim,
access needs, and ground transfers. Combine #2, #10, and #26 with verified hub
information and explicit traveler inputs.
**Ship bar:** Show assumptions and uncertainty, distinguish facts from estimates,
and offer the next useful action without guaranteeing a connection.

### 28. A disruption recovery assistant

When transport is cancelled or delayed, reveal the affected pickup, hotel, and
activities and compare practical alternatives. Connect #1–2 and #26–27 with
original booking terms, provider links, and reviewed plan revisions.
**Ship bar:** Help update the plan/contact the operator; cancellation, purchases,
and rebooking always require explicit confirmation.

### 29. An arrival kit for unfamiliar places

Open one card with the hotel address in local script, pickup instructions,
meeting point, check-in time, host contact, next transfer, and access to the
offline help card. Assemble #4, #7, and #17 with a large address card for a driver.
**Ship bar:** The card works offline and with large text; distinguish saved,
translated, user-entered, and operator-verified information.

### 30. Ask my trip, with answers grounded in sources

Answer “What is my check-in time?” or “Can we leave later?” with a concise response
linked to the supporting booking/plan. Extend drafting with typed retrieval;
deterministic code owns time, money, and permission decisions.
**Ship bar:** Unknown facts remain unknown, sources open correctly, manual access
remains available, and answers never silently change the trip.

## 31–40: tailor the trip to how people actually travel

### 31. “Can I fit this in?” discovery

With 90 minutes before a reservation, find a worthwhile stop that fits the detour,
visit, and return journey, or evaluate a specific place. Use #10–12 and explicit
constraints; preview added travel and remaining buffer.
**Ship bar:** Respect the next locked event and expose unknown hours or routing
before a person commits to insertion.

### 32. Trustworthy, richer place details

Show useful photographs, hours, admission needs, price information, and reviews
with sources alongside current directions/contact actions. Evaluate licensed
providers, regional coverage, attribution, and cache rights.
**Ship bar:** Facts show provenance and freshness; coverage gaps stay honest;
private notes never become public reviews automatically.

### 33. Compare places and plan alternatives side by side

Compare restaurants, attractions, or areas by detour, available windows, expected
cost, and chosen group priorities. Use a small comparison sheet with consistent
criteria drawing on #10–11, #24, and #32.
**Ship bar:** Make tradeoffs understandable, keep unknown values visible, and
retain unchosen alternatives when adding the winner to the plan.

### 34. Discovery that explains why a place suits the trip

Suggest places based on saved interests, the day's area, available time, and
existing stops, with a short reason for each. Extend category/nearby search;
allow preference changes, hiding suggestions, and disabling personalization.
**Ship bar:** Avoid duplicates and known-unusable options, preserve map clarity,
and clearly label paid placement if introduced.

### 35. Mobility, comfort, and walking-budget preferences

Plan around step-free needs, maximum walking, rest frequency, transport choice,
and per-trip pace. Feed explicit preferences into #11–13; separate verified
accessibility attributes, personal notes, and unknown conditions.
**Ship bar:** A preference never becomes a claim of verified accessibility;
every map task also has an accessible list path.

### 36. Family and care-aware itineraries

Account for naps, meal windows, shorter visits, stroller needs, quiet breaks,
and companions joining part of a day. Add optional per-trip constraints and
recurring windows to #12 and #23 without unnecessary sensitive profiles.
**Ship bar:** Preserve care commitments, explain conflicts, and treat free time
as a valid choice rather than an incomplete plan.

### 37. Food preferences and deliberate meal planning

Keep meal windows in the itinerary and find suitable food along the route by
price, cuisine, dietary preferences, and reservations. Use #11 and #32 with
source/confidence labels and manually confirmed requirements.
**Ship bar:** Meals fit the plan; dietary filtering never implies an unverified
allergen-safety guarantee.

### 38. Find practical essentials along the way

Find toilets, pharmacies, groceries, laundry, luggage storage, rest areas, and
drinking water near the route. Extend nearby discovery with a compact Essentials
entry point, detour estimates, and known hours/access conditions.
**Ship bar:** Add a useful short detour and resume the original journey easily;
unknown availability stays visible.

### 39. Road-trip planning with realistic stops

Plan driving days around rest, fuel or compatible charging, overnight stays,
and a driving-time budget. Start with manual stops and driving limits using
#10 and #17; validate providers for live chargers and vehicle-specific range.
**Ship bar:** Required stops survive replanning; estimated range or charging
availability never appears guaranteed.

### 40. Adaptive packing and travel-readiness checklists

Prepare for trip length, activities, baggage, children, and weather while keeping
reusable essentials. Include reviewed passport/visa expiry, transit, and entry
preparation tasks linked to current official sources, without promising eligibility.
Extend templates with quantities, due dates, and #22 assignments.
**Ship bar:** Templates do not duplicate items, user-entered requirements persist,
and itinerary changes do not erase completed preparations.

## 41–50: deepen continuity, power use, and long-term value

### 41. Calendar and Reminders integration

Add selected commitments and tasks with a preview of creates/updates. Use #2
and stable external identifiers; start with explicit export and tracked updates
before attempting full two-way reconciliation.
**Ship bar:** Repeated exports create no duplicates, edits/deletions have clear
ownership, and denied permission leaves Trip usable.

### 42. Opt-in email booking updates

Forward confirmations to a dedicated import address or explicitly connect an
account; review new bookings and changes in one inbox. Build on #6 with secure
ingestion, deduplication, retention controls, revocation, and narrow permissions.
**Ship bar:** Changes target the correct draft, uncertainty requires review, and
disconnecting stops future ingestion. Start with forwarding if feasible.

### 43. A protected travel-document vault

Keep identity documents, visas, insurance, and selected private records behind
an optional extra unlock, with expiry reminders. Extend #4 with explicit
sensitivity/sharing rules, device-backed protection, deletion, and recovery.
**Ship bar:** Sensitive fields stay out of guest links, previews, widgets, and AI
input unless expressly enabled; make only verified encryption claims.

### 44. Portable backup and editable trip import/export

Move or restore a complete editable trip, including attachments and timing.
Define a versioned portable format, import preview, duplicate policy, integrity
checks, and explicit reporting for unsupported fields.
**Ship bar:** Export/import preserves meaningful trip data; people retain access
to their own plans without a continuing paid subscription.

### 45. Reusable trip templates and planning shortcuts

Reuse a successful weekend, work trip, or recurring journey, choosing which
places, timing patterns, tasks, and preferences carry forward. Extend duplication
and App Intents with date shifting and reviewed bulk actions.
**Ship bar:** Do not accidentally copy obsolete confirmations, visited states,
financial entries, or private group permissions.

### 46. A serious iPad and Mac planning workspace

Coordinate a map and timeline with multi-selection, keyboard commands, drag/drop,
and multiple trip windows. Extend existing iPad support; a native Mac target
is additional platform work. Preserve compact iPhone and existing visionOS flows.
**Ship bar:** Bulk/drag actions have keyboard/menu alternatives and Undo;
resizing preserves selection, drafts, and map context.

### 47. An Apple Watch travel companion

Glance at the next stop, meeting time, or departure; mark a visit, open directions,
or acknowledge a task from the wrist. Use bounded projections of #3, #4, and #18
with useful local essentials and phone-disconnection handling.
**Ship bar:** Actions target stable IDs, stale data is labeled, and the experience
works as a short glance rather than a miniature planning workspace.

### 48. Richer widgets, Live Activities, and system actions

Show leave-by times, boarding changes, bookings, and meeting points with direct
actions. Extend current system surfaces using #18 and #26, plus focused Siri,
Shortcuts, Spotlight, and supported control actions.
**Ship bar:** Expired surfaces cannot act on the wrong event, private fields are
redacted, and network-backed status has trustworthy freshness information.

### 49. A private travel journal and meaningful recap

Attach selected photos, notes, and favorite moments to visits; finish with a
private recap that can be selectively shared or reused. Use explicit photo
selection and optional visit history with editing, deletion, and share preview.
**Ship bar:** Include only chosen material, avoid requiring background tracking,
and preserve memories without interrupting travel.

### 50. Downloadable maps and offline navigation — Gated

Choose an area, understand size/coverage, and navigate after connectivity disappears.
First verify current SDK capabilities, map/routing licensing, storage, updates,
and compatibility with this project's SwiftUI/MapKit-only constraints.
**Ship bar:** A real offline route works after relaunch within declared coverage.
Until the gate passes, deliver #7 and clear Apple Maps handoff guidance.

## One coherent interface for all 50

Keep **Explore** and **Trips** as primary navigation. Explore owns discovery,
filters, and saved ideas. Trips owns journeys. Within a trip, show the itinerary
first, with contextual access to bookings, people, money, and preparation.
Today is the active-trip view; the journal becomes relevant after travel.
Advanced tools appear at the point of use.

- On a small screen, show one primary next action and reveal detail progressively.
- On iPad/Mac, use space for comparison and map/timeline coordination.
- Keep flexible days, “maybe” places, and free time first-class.
- Preserve native map gestures, stable selection, and annotation hierarchy.
- Put AI into useful actions and grounded answers, with preview and Undo.
- Explain absence, uncertainty, stale data, and offline state where decisions happen.

This follows Apple's emphasis on clarity, familiar interactions, recovery, and
user control in its [design principles](https://developer.apple.com/design/human-interface-guidelines/design-principles)
and [generative AI guidance](https://developer.apple.com/design/human-interface-guidelines/generative-ai).

## Engineering foundations and scope gates

| Foundation | Current evidence and required decision | Unlocks |
| --- | --- | --- |
| Events, time, and source evidence | Journey events and explicit civil dates/zones exist. Extend provenance and attachments while preserving compatible migration and stable identity. | #1–4, #10–14, #17–18, #26–31, #41 |
| Protected attachments | Add immutable originals, metadata, integrity checks, download state, and explicit sharing scope. Private access is required from the first wallet version. | #4–7, #19–20, #29, #42–44 |
| Change-aware persistence | TripStore disables CloudKit; StoredTrip uses unique IDs and whole-trip JSON. Decide merge units, deletions, pending-change delivery, and recovery before cloud features. | #8–9, #15, #21–23 |
| Reliable provider adapters | Route estimates, hours, weather, media, status, and prices need source/freshness/coverage models, cancellation, quotas, rights, and fallbacks. | #10–14, #18, #24, #26–28, #31–39 |
| Deterministic planning and money | Domain/services own arithmetic, feasibility, permissions, and revision checks; AI retrieves, explains, and proposes. | #6, #12–13, #24–25, #30–31 |
| Stable system projections | Extend existing bounded widget/Live Activity projections as booking/live-data models mature. | #18, #47–48 |

Preserve the [module graph](../ARCHITECTURE.md), struct controllers, composed models,
cancellation, stale-result protection, strict concurrency, and source-size limits.
Package services remain independent of app types; views do not own business logic.

Important external constraints:

- Sync is not a settings-only change. Apple documents that CloudKit cannot enforce
  unique constraints; resolve identity and migration explicitly.
  [SwiftData sync guidance](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices).
- Apple's documented MapKit behavior does not expose Apple Maps offline downloads
  to other apps or guarantee tile preloading/cache retention. Recheck the installed
  SDK before choosing an approach for #50.
  [Apple DTS explanation](https://developer.apple.com/forums/thread/772258).
- A feature in Apple Maps does not establish a public MapKit API; regional coverage
  also varies. [Apple feature availability](https://www.apple.com/ios/feature-availability/).
- Transport status, prices, opening hours, reviews, and accessibility claims need
  verified coverage and display/cache rights. Evaluate ongoing cost and operating
  reliability before committing to a provider-backed launch.
- Weather needs required attribution and coverage handling.
  [WeatherKit](https://developer.apple.com/weatherkit/).
- Request calendar, location, notification, photo, and email permissions at the
  point of use, and honor denial/revocation.
  [Apple privacy guidance](https://developer.apple.com/design/human-interface-guidelines/privacy/).

## Recommended delivery sequence

These are coherent release themes, not calendar estimates. Dependencies and risk
determine shipping order; develop the underlying model contracts early.

| Release theme | First useful slice | Exit condition |
| --- | --- | --- |
| A. A trip worth trusting | #1–2, manual #4, #5–7, #9, basic #19/#44, then #3. Protect attachments immediately; sensitive identity-document storage waits for #43. | Build a trip, import a booking, recover an edit, and open every Ready item offline. |
| B. A day that actually works | #10–12, #16–18, then #13–14 and #31. Start with a clearly supported destination/provider set. | Preserve bookings, expose uncertainty, and survive a changed day without losing work. |
| C. Travel together | #8, then #15 and #19–25. Design merge foundations early even if shared UI ships later. | Two people edit offline, reconnect, make a decision, and reconcile an expense without loss or leakage. |
| D. A companion in motion | Provider-backed #26–30, then selected #32–40 based on research. | Relevant reminders, visible freshness, and useful disruption recovery. |
| E. Power use and retention | #41–49; investigate #50 independently before promising availability. | Better cross-device and repeat-trip workflows without friction in the core experience. |

Ship a few complete journeys per release. A feature is not done when its screen
renders: handle empty data, corrections, permission denial, cancellation, poor
connectivity, and recovery.

## Quality and business bars

These apply to every feature; they are not extra backlog entries:

- **Accessible by default:** VoiceOver, Dynamic Type, contrast, Reduce Motion,
  keyboard/focus behavior, and equivalent non-map workflows. Validate with disabled
  travelers; a checklist of modifiers is insufficient.
- **International by design:** Localized strings, right-to-left layouts, local
  addresses, formats, currencies, units, calendars, and long names. #2 handles
  the distinct problem of travel-time correctness.
- **Responsive and economical:** Saved content should not wait for a network.
  Budget provider work, image memory, background activity, and battery use;
  measure on supported hardware with large realistic trips.
- **Dependable data:** Verify migrations, conflict recovery, reminders, deletion,
  and portable backups against adverse scenarios before release.
- **Sharing clarity:** Preview recipients and fields. Whole-trip text sharing
  currently includes day notes, unlike individual-day sharing; review this early
  in #19 and keep private documents separate from public itineraries.
- **Earn notifications:** Interrupt for actionable travel changes and chosen
  deadlines, respecting Focus and avoiding repetition.
  [Apple notification guidance](https://developer.apple.com/design/human-interface-guidelines/managing-notifications).
- **Fair monetization:** Keep saved essentials, basic planning, recovery, and
  personal export dependable. Consider charging for advanced automation and costly
  data services after validating willingness to pay and operating margins.
- **Focus:** Choose releases from observed traveler needs. Avoid turning every
  possible tool into a permanent destination or filling travel screens with ads.

## How to judge progress

These are proposed evaluation targets, not measured results:

| Outcome | Measure |
| --- | --- |
| Fast first value | Time/completion rate from launch to a useful saved trip; abandonment caused by required setup. |
| Less planning effort | Time to capture a booking, arrange a feasible day, and revise it; corrections needed after import. |
| Useful during travel | Active-trip use of the next useful action; actions/time needed to find a ticket, address, or route. |
| Trust | Lost/recoverable edits, sync conflicts, incorrect reminders, import errors, and correctly labeled stale data. |
| Offline confidence | Items marked Ready that open after airplane-mode relaunch; target 100% in validation. |
| Better decisions | Proposal acceptance and Undo rates, paired with feedback about usefulness; acceptance alone is insufficient. |
| Sustainable repeat use | Next-trip reuse and between-trip wishlist use, segmented by travel frequency; provider cost per active trip. |

Observe solo travelers, couples, groups, families, people with access needs, and
international travelers completing real scenarios. Start with booking import,
offline arrival, a delayed afternoon, concurrent edits, and a missed connection.
Resolve confusion before adding surfaces. Collect minimal analytics without raw
itineraries or private documents.
