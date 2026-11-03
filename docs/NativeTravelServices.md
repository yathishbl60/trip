# Native travel services

## Task and acceptance

Booking capture, Calendar export, departure alarms, Reminders export, and
weather-aware planning extend the trip menus, booking editor, checklist, day
actions, and Shortcuts. Each workflow must finish with a useful saved result or an explicit,
recoverable unavailable/error state.

Import accepts selected documents/images and opens a reviewed event draft. Export
uses selected canonical saved records. Alarm scheduling requires a future instant
confirmed by the traveler. Weather describes the selected destination and planned
hour; schedule changes use the existing reviewed planner. Cancellation, deleted
records, changed time zones, denied authorization, offline service failures, and
repeated export requests must retain predictable behavior.

## Ownership

TripDomain owns immutable inputs and provider contracts. TripIntegrations owns
native service adapters. Trips owns window-local workflow state, controllers, and
SwiftUI presentations. App owns live dependencies, system permissions, Shortcuts
handoff, and post-save reconciliation. PreviewSupport supplies local fixtures.
See [the boundary decision](decisions/trip-system-services.md).

## WeatherKit signing policy

The checked-in app entitlement file and Xcode capability list omit WeatherKit.
`TripWeatherEnabled` in `trip/App/Info.plist` is false. AppTripServices injects an unavailable provider;
the day sheet and an explicitly requested briefing explain that forecasts are not
available in this build without attempting a service request. Local previews retain
deterministic sample forecasts. The native provider and reusable contracts remain.

To enable live weather for an eligible Apple Developer Program team, enable
WeatherKit for the app's identifier and in Xcode Signing & Capabilities, regenerate
a provisioning profile granting `com.apple.developer.weatherkit`, then set
`TripWeatherEnabled` to true. The flag alone never grants entitlement access.
Verify a signed build and real service response before release. See
[Apple's WeatherKit setup](https://developer.apple.com/weatherkit/) and
[the entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.weatherkit).

## Verification

Run `bash scripts/check.sh` for ownership, localization, source limits and project
wiring. Booking parser cases live in the standalone `system-check` harness.
Request executable checks and app builds separately. A simulator build does not
verify permissions, OCR quality, alarm delivery, signed entitlements, live weather,
or behavior in Calendar and Reminders. Exercise those workflows with real data
and supported signed devices before enabling them for release.
