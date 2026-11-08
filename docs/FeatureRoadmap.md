# Select and scope a feature

Use this proposal catalog to turn a traveler need into a focused contribution.
The numbered ideas are discussion references, not an ordered backlog, missing-feature
list, authorization, or release promise. An existing implementation may already
satisfy part of an idea; establish the remaining user task before proposing work.

## Start from the current owner

Read [Trips](Trips.md), [Explore](Explore.md), [Directions](Directions.md),
[Today and time](TripTimeAndToday.md), [native travel services](NativeTravelServices.md),
and [system integrations](../SYSTEM-INTEGRATIONS.md) for current behavior. Resolve
contracts and consumers with `python3 scripts/workspace.py context <Owner> --json`.
Use [Development](Development.md) to prepare the task and any required decision.

1. Describe the concrete friction in an existing planning or travel flow. Explain
   the benefit and the evidence for it; do not infer demand from novelty.
2. Inspect the existing entry point, model, persistence, and system actions. Reuse
   working behavior and identify the smallest useful extension.
3. Choose one complete scenario. Name its owner, dependencies, saved-data changes,
   cancellation/recovery behavior, and cases that remain outside the proposal.
4. Resolve provider, licensing, account, privacy, and platform decisions before
   committing to behavior that depends on them. The table below identifies common
   gates; it does not make those decisions for maintainers.
5. Define acceptance around a traveler completing the task, including missing data,
   denied permissions, stale responses, offline use, and correction where relevant.
   Separate proposed acceptance from observed evidence.
6. Agree scope before adding navigation or a new surface. Prefer contextual actions
   in Explore and Trips; preserve native map interaction, selection, and drafts.

Rank alternatives by frequency, consequence of failure, effort saved, and dependency
cost. The product direction is to turn scattered ideas into a realistic journey,
then help people make the next decision while traveling. A few complete scenarios
are more useful than many disconnected controls.

## Resolve shared design decisions

| Area | Decision needed before extending it | Related proposals |
| --- | --- | --- |
| Events and time | Stable identity, local date/zone versus instant, source evidence, and reviewed migration | #1–4, #10–14, #17–18, #26–31, #41 |
| Attachments | Originals, integrity, offline state, retention, private access, sharing scope, and deletion | #4–7, #19–20, #29, #42–44 |
| Sync and collaboration | Merge units, deletions, account transitions, durable pending changes, recovery, and access revocation | #8–9, #15, #21–23 |
| Provider data | Coverage, freshness, attribution, display/cache rights, quotas, costs, cancellation, and fallback | #10–14, #18, #24, #26–28, #31–39 |
| AI and arithmetic | Saved-source retrieval and reviewed proposals; deterministic time, money, permission, and revision validation | #6, #12–13, #24–25, #30–31 |
| System surfaces | Bounded saved-data projections, privacy, stable action targets, and expiry | #18, #47–48 |
| New platforms/offline maps | Public SDK support, native UI constraints, distribution, storage, and independent verification | #46–47, #50 |

Recheck the installed SDK and current primary documentation when choosing a new
capability. A feature in an Apple app does not establish a public framework API.
Do not promise cloud synchronization, live status, offline routing, or a new
platform target from a UI prototype.

## Proposal catalog

Each acceptance case describes a possible completed slice. Adapt it to the agreed
scope and current contracts; do not treat the wording as proof that it is delivered.
Preserve the numbered references when discussing or revising an idea.

## 1–10: make the trip trustworthy and useful every day

### 1. Complete journey timeline

See visits, flights, trains, hotel stays, reservations, personal activities, and
intentional free time in one itinerary. Extend the place-stop model with typed
events, stable identities, and multi-day spans.
**Acceptance case:** A flight, a three-night stay, and an untimed walk coexist without
fake places, duplicate bookings, or forced scheduling.

### 2. Destination time zones and correct travel dates

Display departure and arrival in their own local times and dates, with home time
only when helpful. Model local dates, zones, instants, and elapsed durations;
migrate existing device-local schedules through a reviewed choice.
**Acceptance case:** Device-zone changes never move a booking; daylight-saving ambiguity,
overnight travel, and date-line crossings remain correct.

### 3. A contextual Today experience

Open the active trip to the next commitment, when to leave, its ticket, and one
clear next action. Make Today an active-trip destination inside Trips, using
#1, #2, and #4. Start with labeled manual travel allowances; route-derived
leave-by guidance follows #10/#18. Reveal the rest of the day on demand.
**Acceptance case:** Answer “What next?” and open its route or ticket in at most two
actions from the active trip, including with saved offline content.

### 4. Booking and document wallet

Keep flights, hotels, rail, rental cars, restaurants, and activity tickets beside
their itinerary events. Preserve original confirmations, reference numbers,
contacts, and important dates in typed reservations and protected attachments.
**Acceptance case:** Using #1–2, every booking's saved details and every attached original
remain available after an offline relaunch; manual entries need no source file.

### 5. Save to Trip from other apps

Share a Maps place, Safari link, image, PDF, or selected text into Trip; save
directly to an inbox or choose a trip/day. Retain the source and detect duplicate
captures through a focused share extension.
**Acceptance case:** A valid share saves with one confirmation and appears once in the
chosen destination, including while offline.

### 6. Reviewed booking import from screenshots, PDFs, and text

Import a confirmation and review dates, airports, names, prices, and uncertain
fields before it becomes a booking. Preserve the original; use extraction tools
with deterministic validation for dates and amounts.
**Acceptance case:** Build on #4–5; reconcile duplicates and prevent unconfirmed critical
fields from silently becoming travel commitments.

### 7. An offline essentials pack with a readiness check

Prepare tickets, itinerary items, addresses, contacts, and instructions for
travel. Include an offline help card with chosen emergency contacts, insurer
assistance, and sourced destination help/consular information. Show download
progress, refresh dates, storage use, and failures.
**Acceptance case:** Everything marked Ready opens after airplane mode and a cold
relaunch. Base-map downloads belong to the separate gated feature #50.

### 8. Reliable iCloud sync across personal devices

Continue planning on another device, see pending changes, and keep editing during
poor connectivity. Define merge units, deletions, account transitions, migration,
and durable pending changes; use the recovery work in #9.
**Acceptance case:** Concurrent edits to unrelated stops both survive, removed content
does not reappear, and unsynced changes remain recoverable.

### 9. Broad Undo, recently deleted, and version recovery

Recover a removed day, mistaken bulk edit, or unwanted plan replacement with a
preview of what will return. Extend visit Undo to durable edits, preserve
attachment references, and define retention.
**Acceptance case:** Restore meaningful trip contents without undoing unrelated later
work; include collaborator attribution when combined with #15.

### 10. Real travel times inside the itinerary

Show mode, distance, estimated duration, and schedule impact for every leg.
Connect TripRouting to itinerary timing with bounded requests, freshness labels,
and editable manual fallbacks. Preserve every stop when a day exceeds one request.
**Acceptance case:** Longer days retain every stop, failed estimates remain explicit,
and stale responses never overwrite newer route choices.

## 11–20: make planning realistic and effortless

### 11. Opening-hours and reservation feasibility checks

Flag closed venues, missed entry windows, overlapping bookings, and impossible
transfers where they occur, with useful corrections. Combine #1–2 and #10 with
verified, dated opening windows, exceptions, and explicit unknown values.
**Acceptance case:** Missing information never becomes “open,” and fixed commitments
are never moved without the traveler's choice.

### 12. Constraint-aware day optimization

Improve a day around must-dos, bookings, opening windows, lodging, walking
tolerance, and breaks. Compose geographic suggestions and route-backed review
with #10–11; show time saved and compromises before applying.
**Acceptance case:** Deterministic planning preserves locked events and identities,
explains remaining conflicts, and supports Undo without claiming a global optimum.

### 13. Replan the rest of my day

“We are running late” or “Make this afternoon easier” produces a small revision
from actual progress. Extend reviewed drafting to scheduled days using #11–12;
protect visited events, bookings, must-dos, and intentional free time.
**Acceptance case:** Show every change before explicit application; preserve the previous
plan and reject stale proposals after concurrent edits.

### 14. Weather-aware plans and saved alternatives

Attach rainy-day alternatives to outdoor activities and swap them without
rebuilding the day. Use forecasts for the actual place/time, with attribution,
freshness, coverage, and forecast-horizon limits.
**Acceptance case:** Feed replacements through #11–13 so they fit; distant dates never
display invented forecasts as if they were known.

### 15. Shared trips with clear ownership and permissions

Invite companions as viewers or editors, see who changed the plan, keep personal
notes private, and revoke access. Build on #8–9 with shared/private fields and
explicit conflict rules; separate personal-device sync from multi-person sharing.
**Acceptance case:** Concurrent edits survive and future access follows permissions;
private attachments are excluded from shared content by default.

### 16. A global wishlist and travel research inbox

Save “someday” places without creating a trip. Organize by destination, interest,
or personal collection, then add ideas to an itinerary. Reuse place identities
and #5 while preserving links, notes, and an unscheduled state.
**Acceptance case:** Adding an idea to a trip retains its context without forcing removal
of the original or producing duplicate places.

### 17. Multi-city journeys with lodging anchors

Plan destination chapters, nights, and travel-only days. Show check-in/out,
luggage gaps, and the day's starting/ending accommodation. Compose #1–2 and #4
into stay spans instead of treating every hotel night as an attraction.
**Acceptance case:** Moving a chapter identifies affected dates/bookings for review
while preserving original reservation details.

### 18. Useful departure, check-in, and deadline reminders

Receive a concise leave-by action, check-in prompt, or cancellation deadline with
a direct booking/route link. Use #2, #4, and #10; start with reliable local
deadlines, then add provider-backed changes through #26.
**Acceptance case:** Plan edits cancel obsolete reminders, times remain correct, and
notification preferences and Focus are respected.

### 19. Private-by-default guest sharing and printable plans

Preview exactly what others will receive, choose days and fields, then share an
accessible guest view or useful PDF without requiring the app. Extend text
sharing; hosted links require access controls, expiry, and revocation.
**Acceptance case:** Private notes/references never appear unexpectedly. Explain that
revocation controls future link access, not copies already downloaded.

### 20. One search across everything in the trip

Find a hotel confirmation, place, private note, ticket, or shared decision in one
search field with typed results and direct actions. Extend saved-data
search with permitted local document indexing and shared/private visibility.
**Acceptance case:** Saved essentials remain searchable offline; deleted content leaves
the index; every result opens the correct event or file.

## 21–30: coordinate companions and handle real travel

### 21. Group decisions, availability, and lightweight polls

Choose dates, destinations, places, and spend ranges together. Keep proposals,
votes, comments, the decision, and its owner attached to the relevant choice;
support abstention and partial participation through #15.
**Acceptance case:** A chosen option becomes a reviewed itinerary change without
duplicates or disclosure of private preferences.

### 22. Shared preparation tasks and responsibilities

Assign “book the train,” “bring the stroller,” or “confirm the hotel” with due
dates and compact progress. Extend checklists with ownership, comments, and
history using #15 and #18; retain personal tasks alongside shared ones.
**Acceptance case:** People can identify their responsibilities, and offline completion
reconciles without duplicate tasks or repeated reminders.

### 23. Subgroup plans and reliable meeting points

Let some companions visit a museum while others rest, then show each subgroup
the agreed reunion time and place. Add participant scope and regroup events;
start with manual check-in and separately opt-in, time-limited location sharing.
**Acceptance case:** Each person has a coherent day and shared reunion without requiring
continuous background location.

### 24. A useful trip budget before booking

Estimate accommodation, travel, food, and activities; distinguish known prices
from estimates and compare the cost of alternatives. Use exact decimal amounts,
per-person/group costs, source currencies, and dated exchange rates.
**Acceptance case:** Totals remain explainable offline; changing reporting currency
never changes original amounts or presents an estimate as a quote.

### 25. Expenses, receipts, refunds, and fair splitting

Capture receipts, record who paid and participated, and see balances with custom
splits and partial repayments. Add a ledger alongside #24; review extracted
amounts and preserve historical rates and refund relationships.
**Acceptance case:** Balances reconcile exactly after rounding and refunds across
currencies. Recording settlement does not imply moving money.

### 26. Live flight and transport status

Show verified delays, gate/platform changes, cancellation, and baggage information
beside the booking with an update timestamp. Start with one mode/provider and
plan coverage, backend refresh, push delivery, and operating cost.
**Acceptance case:** Missing or stale status falls back to the original booking and
operator link; add rail/ferry coverage only after separate validation.

### 27. Realistic airport and station connections

Explain connection comfort using immigration, terminal changes, baggage reclaim,
access needs, and ground transfers. Combine #2, #10, and #26 with verified hub
information and explicit traveler inputs.
**Acceptance case:** Show assumptions and uncertainty, distinguish facts from estimates,
and offer the next useful action without guaranteeing a connection.

### 28. A disruption recovery assistant

When transport is cancelled or delayed, reveal the affected pickup, hotel, and
activities and compare practical alternatives. Connect #1–2 and #26–27 with
original booking terms, provider links, and reviewed plan revisions.
**Acceptance case:** Help update the plan/contact the operator; cancellation, purchases,
and rebooking always require explicit confirmation.

### 29. An arrival kit for unfamiliar places

Open one card with the hotel address in local script, pickup instructions,
meeting point, check-in time, host contact, next transfer, and access to the
offline help card. Assemble #4, #7, and #17 with a large address card for a driver.
**Acceptance case:** The card works offline and with large text; distinguish saved,
translated, user-entered, and operator-verified information.

### 30. Ask my trip, with answers grounded in sources

Answer “What is my check-in time?” or “Can we leave later?” with a concise response
linked to the supporting booking/plan. Extend drafting with typed retrieval;
deterministic code owns time, money, and permission decisions.
**Acceptance case:** Unknown facts remain unknown, sources open correctly, manual access
remains available, and answers never silently change the trip.

## 31–40: tailor the trip to how people actually travel

### 31. “Can I fit this in?” discovery

With 90 minutes before a reservation, find a worthwhile stop that fits the detour,
visit, and return journey, or evaluate a specific place. Use #10–12 and explicit
constraints; preview added travel and remaining buffer.
**Acceptance case:** Respect the next locked event and expose unknown hours or routing
before a person commits to insertion.

### 32. Trustworthy, richer place details

Show useful photographs, hours, admission needs, price information, and reviews
with sources alongside current directions/contact actions. Evaluate licensed
providers, regional coverage, attribution, and cache rights.
**Acceptance case:** Facts show provenance and freshness; coverage gaps stay honest;
private notes never become public reviews automatically.

### 33. Compare places and plan alternatives side by side

Compare restaurants, attractions, or areas by detour, available windows, expected
cost, and chosen group priorities. Use a small comparison sheet with consistent
criteria drawing on #10–11, #24, and #32.
**Acceptance case:** Make tradeoffs understandable, keep unknown values visible, and
retain unchosen alternatives when adding the winner to the plan.

### 34. Discovery that explains why a place suits the trip

Suggest places based on saved interests, the day's area, available time, and
existing stops, with a short reason for each. Extend category/nearby search;
allow preference changes, hiding suggestions, and disabling personalization.
**Acceptance case:** Avoid duplicates and known-unusable options, preserve map clarity,
and clearly label paid placement if introduced.

### 35. Mobility, comfort, and walking-budget preferences

Plan around step-free needs, maximum walking, rest frequency, transport choice,
and per-trip pace. Feed explicit preferences into #11–13; separate verified
accessibility attributes, personal notes, and unknown conditions.
**Acceptance case:** A preference never becomes a claim of verified accessibility;
every map task also has an accessible list path.

### 36. Family and care-aware itineraries

Account for naps, meal windows, shorter visits, stroller needs, quiet breaks,
and companions joining part of a day. Add optional per-trip constraints and
recurring windows to #12 and #23 without unnecessary sensitive profiles.
**Acceptance case:** Preserve care commitments, explain conflicts, and treat free time
as a valid choice rather than an incomplete plan.

### 37. Food preferences and deliberate meal planning

Keep meal windows in the itinerary and find suitable food along the route by
price, cuisine, dietary preferences, and reservations. Use #11 and #32 with
source/confidence labels and manually confirmed requirements.
**Acceptance case:** Meals fit the plan; dietary filtering never implies an unverified
allergen-safety guarantee.

### 38. Find practical essentials along the way

Find toilets, pharmacies, groceries, laundry, luggage storage, rest areas, and
drinking water near the route. Extend nearby discovery with a compact Essentials
entry point, detour estimates, and known hours/access conditions.
**Acceptance case:** Add a useful short detour and resume the original journey easily;
unknown availability stays visible.

### 39. Road-trip planning with realistic stops

Plan driving days around rest, fuel or compatible charging, overnight stays,
and a driving-time budget. Start with manual stops and driving limits using
#10 and #17; validate providers for live chargers and vehicle-specific range.
**Acceptance case:** Required stops survive replanning; estimated range or charging
availability never appears guaranteed.

### 40. Adaptive packing and travel-readiness checklists

Prepare for trip length, activities, baggage, children, and weather while keeping
reusable essentials. Include reviewed passport/visa expiry, transit, and entry
preparation tasks linked to current official sources, without promising eligibility.
Extend templates with quantities, due dates, and #22 assignments.
**Acceptance case:** Templates do not duplicate items, user-entered requirements persist,
and itinerary changes do not erase completed preparations.

## 41–50: deepen continuity, power use, and long-term value

### 41. Calendar and Reminders integration

Add selected commitments and tasks with a preview of creates/updates. Use #2
and stable external identifiers; start with explicit export and tracked updates
before attempting full two-way reconciliation.
**Acceptance case:** Repeated exports create no duplicates, edits/deletions have clear
ownership, and denied permission leaves Trip usable.

### 42. Opt-in email booking updates

Forward confirmations to a dedicated import address or explicitly connect an
account; review new bookings and changes in one inbox. Build on #6 with secure
ingestion, deduplication, retention controls, revocation, and narrow permissions.
**Acceptance case:** Changes target the correct draft, uncertainty requires review, and
disconnecting stops future ingestion. Start with forwarding if feasible.

### 43. A protected travel-document vault

Keep identity documents, visas, insurance, and selected private records behind
an optional extra unlock, with expiry reminders. Extend #4 with explicit
sensitivity/sharing rules, device-backed protection, deletion, and recovery.
**Acceptance case:** Sensitive fields stay out of guest links, previews, widgets, and AI
input unless expressly enabled; make only verified encryption claims.

### 44. Portable backup and editable trip import/export

Move or restore a complete editable trip, including attachments and timing.
Define a versioned portable format, import preview, duplicate policy, integrity
checks, and explicit reporting for unsupported fields.
**Acceptance case:** Export/import preserves meaningful trip data; people retain access
to their own plans without a continuing paid subscription.

### 45. Reusable trip templates and planning shortcuts

Reuse a successful weekend, work trip, or recurring journey, choosing which
places, timing patterns, tasks, and preferences carry forward. Extend duplication
and App Intents with date shifting and reviewed bulk actions.
**Acceptance case:** Do not accidentally copy obsolete confirmations, visited states,
financial entries, or private group permissions.

### 46. A serious iPad and Mac planning workspace

Coordinate a map and timeline with multi-selection, keyboard commands, drag/drop,
and multiple trip windows. Extend existing iPad support; a native Mac target
is additional platform work. Preserve compact iPhone and existing visionOS flows.
**Acceptance case:** Bulk/drag actions have keyboard/menu alternatives and Undo;
resizing preserves selection, drafts, and map context.

### 47. An Apple Watch travel companion

Glance at the next stop, meeting time, or departure; mark a visit, open directions,
or acknowledge a task from the wrist. Use bounded projections of #3, #4, and #18
with useful local essentials and phone-disconnection handling.
**Acceptance case:** Actions target stable IDs, stale data is labeled, and the experience
works as a short glance rather than a miniature planning workspace.

### 48. Richer widgets, Live Activities, and system actions

Show leave-by times, boarding changes, bookings, and meeting points with direct
actions. Extend current system surfaces using #18 and #26, plus focused Siri,
Shortcuts, Spotlight, and supported control actions.
**Acceptance case:** Expired surfaces cannot act on the wrong event, private fields are
redacted, and network-backed status has trustworthy freshness information.

### 49. A private travel journal and meaningful recap

Attach selected photos, notes, and favorite moments to visits; finish with a
private recap that can be selectively shared or reused. Use explicit photo
selection and optional visit history with editing, deletion, and share preview.
**Acceptance case:** Include only chosen material, avoid requiring background tracking,
and preserve memories without interrupting travel.

### 50. Downloadable maps and offline navigation — Gated

Choose an area, understand size/coverage, and navigate after connectivity disappears.
First verify current SDK capabilities, map/routing licensing, storage, updates,
and compatibility with this project's SwiftUI/MapKit-only constraints.
**Acceptance case:** A real offline route works after relaunch within declared coverage.
Until the gate passes, deliver #7 and clear Apple Maps handoff guidance.

## Turn an agreed proposal into a contribution

Use the [task and review workflow](Development.md) to record the user scenario,
ownership, data/permission changes, and focused acceptance cases. Reuse the
[design system](DesignSystem.md), [module graph](../ARCHITECTURE.md), and production
[dependency contracts](Dependencies.md). Keep native navigation and progressive
disclosure; a new capability need not become a new permanent destination.

Use `bash scripts/check.sh` for source changes. Choose requested builds, algorithm
checks, and runtime scenarios from [Contributing](../CONTRIBUTING.md) and the owning
guide. For an offline claim, include cold relaunch with connectivity unavailable;
for sync, include independent edits and reconnection; for AI, include unknown facts,
correction, cancellation, and stale proposals. Record the actual scope in the change
review rather than maintaining delivery status in this catalog.
