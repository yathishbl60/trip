# Native travel services

## Task and acceptance

The user approved booking capture, Calendar export, departure alarms, Reminders
export, and weather-aware planning. These extend the existing trip menus, booking
editor, checklist, day actions, and Shortcuts without adding a primary navigation
destination. Each workflow must finish with a useful saved result or an explicit,
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

The current Personal Team cannot provision WeatherKit. The app's entitlement file
and Xcode capability list therefore omit WeatherKit, and `TripWeatherEnabled` in
`trip/App/Info.plist` is false. AppTripServices injects an unavailable provider;
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

Source, architecture, ownership, localization, and source-limit audits pass.
A Debug arm64 build passed on the single iPhone 18 Pro Max iOS 27.2 simulator
with Xcode 27.2 and signing disabled, including the final Personal Team weather
configuration. The build reported no warnings or errors. App and widget extension
compilation and App Intents metadata processing are included.

The focused booking parser regression cases are registered in the standalone
system-check harness but were not executed. No other simulator or package builds,
benchmarks, permission dialogs, signed-device behavior, rendered-preview review,
OCR fixture runs, or live service responses were verified. Hindi and Kannada
translations are present and marked for language review.
