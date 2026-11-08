# Native travel services

Trip adds native service workflows to existing trip/day menus, the booking editor,
checklist, and Shortcuts. Opening a review does not save a booking, export data, or
schedule an alarm. The traveler confirms those operations in the existing UI.

## Service boundaries

| Owner | Responsibility |
| --- | --- |
| TripDomain | Immutable requests, validation, and provider contracts |
| TripIntegrations | Vision/PDF reading, EventKit, AlarmKit, and WeatherKit adapters |
| Trips models/controllers | Window-local drafts, cancellation, review, and recovery |
| App dependencies/runtime | Live provider selection, intent handoff, and post-save reconciliation |
| PreviewSupport | Deterministic local providers; no automatic live-service fallback |

Native permission requests occur when performing the chosen action, not during
provider initialization. App composition retains the system-action provider and its
ledger. See [dependencies](Dependencies.md) and the
[boundary decision](decisions/trip-system-services.md).

## Booking import

Import accepts selected PDF, image, or UTF-8 text documents; Photos uses the system
picker. PDF text or on-device Vision OCR produces bounded suggestions with visible
source evidence. File size, pages, image dimensions, text, and date candidates have
limits in the domain/reader contracts. Cancellation and request identity reject late
results. Unsupported or unreadable inputs retain manual booking entry.

Dates are suggestions and are not preselected. Selected clock values require explicit
time-zone review before opening the ordinary event draft. The draft remains editable
and nothing is saved until Save. A deleted destination, capacity change, or existing
edit prevents a stale handoff from replacing current work.

Import a Booking into Trip accepts a document, trip, and day in Shortcuts. A user can
connect it to Shortcut Input in a share-sheet Shortcut; the repository does not ship
a native Share extension. Place-name search is a separate action and does not parse
booking files. See [system integrations](../SYSTEM-INTEGRATIONS.md#handoffs-from-another-app).

## Calendar and Reminders

Calendar export reviews selected saved bookings with confirmed start/end instants.
It requests write-only Calendar access and copies the title, location, time zone,
absolute endpoints, and exact-detail link. Scheduled place visits are not included.
Reminders export reviews selected incomplete checklist items and an optional due
date, requests Reminders access, and copies the title and trip link. Private trip and
booking notes are excluded.

Both operations create copies. A local ledger records successfully exported source
IDs so retry skips those items after a partial failure. External edits/deletions and
Trip reinstallation are not reconciled with that ledger; later changes do not keep
copies synchronized. The current adapters support these operations on iOS/iPadOS;
visionOS reports them unavailable. The package also contains macOS adapters, but Trip
has no macOS app target.

## Booking alarms

Travel alarm is available for a saved booking after editor changes are saved. On
iOS/iPadOS, Review Saved Booking Alarm also resolves an exact saved booking and
opens the same alarm review. It requires authentication, foreground host execution,
and canonical/edit validation. A saved place visit cannot be used as a booking.
The tool does not schedule an alarm itself.

The review requires a valid future instant and supports cancellation of a scheduled
alarm. AlarmKit owns native delivery and the foreground Open Trip action. Scheduling
revalidates the saved booking after permission and asynchronous work. Durable saves
and foreground activation reconcile changed/deleted bookings; stale cancellation
cannot delete a newer replacement. Alarm availability is iOS-only. Permission denial,
changed data, and invalid clocks remain recoverable errors in the existing review.

## Weather configuration

`TripWeatherEnabled` in `trip/App/Info.plist` is false, and the checked-in entitlements
omit WeatherKit. App composition injects an unavailable provider, so day weather and
briefing requests explain the limitation without a live forecast call. Preview
forecasts are local samples. The native implementation remains available for a
separately configured, signed build.

Enabling live weather requires an eligible developer team, the WeatherKit capability
and provisioning entitlement, then the configuration flag. The flag cannot grant
access. Follow [Apple's WeatherKit setup](https://developer.apple.com/weatherkit/)
and [entitlement documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.weatherkit),
then verify a real signed service response. Weather-informed changes must still use
the existing reviewed planner.

## Change or verify a service flow

1. Start from the provider contract in TripDomain and the existing Trips review.
   Keep native service construction in App dependencies.
2. Pass immutable inputs to native workers. Bound input/work, honor cancellation,
   and reject stale results before changing presentation or saved data.
3. Resolve current records again before permission-dependent work completes. Keep
   partial-success recovery and repeat-call behavior explicit.
4. Use local preview providers for denied, unavailable, changed-data, and failure
   states. Do not add a live fallback to feature previews.
5. Run the smallest authorized check, then review the native permission and result
   flow separately when runtime verification is requested.

```sh
python3 scripts/workspace.py context TripIntegrations --json
bash scripts/check.sh
bash scripts/build.sh TripIntegrations Debug
bash scripts/build.sh app Debug
bash scripts/build.sh visionOS Debug
bash scripts/performance.sh system-check
```

The standalone system checks cover parser and saved-data rules; compilation covers
module and platform availability. Neither verifies OCR quality, native permissions,
external Calendar/Reminders copies, alarm delivery, or a live forecast. For those
changes, use supported signed devices and explicit fixtures covering cancellation,
changed/deleted records, timezone/DST changes, denied access, partial export/retry,
repeat requests, and alarm replacement. See [the harness](../Performance/README.md)
and [test ownership](Testing.md) before extending checks.
