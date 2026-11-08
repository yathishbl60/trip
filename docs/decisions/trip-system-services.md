# Native travel service boundaries

Use this decision when adding booking capture, Calendar/Reminders exports, booking
alarms or weather. These native capabilities have permission and lifecycle rules
separate from private trip storage and generated planning.

## Ownership

TripIntegrations owns native adapters and depends only on TripDomain,
TripLocalization and Apple frameworks. It must not depend on app models, feature
state or host bundle identifiers. AppTripServices creates live providers; focused
Trips models receive domain contracts. The host retains shared system-action and
forecast services across scenes; previews inject local implementations.

See [Native travel services](../NativeTravelServices.md) for source entry points and
[Dependencies](../Dependencies.md) for lifetimes and configuration.

## Contracts to preserve

- Booking extraction produces a proposal. The existing event draft and revisioned
  library remain the booking-save path; parsing does not silently persist results.
- Calendar and Reminders export selected data after explicit review. They do not
  synchronize later external edits back into Trip.
- Booking alarms use durable native identities and reconcile after successful
  library saves. Resolve current bookings before requesting native effects.
- Request permissions when the user performs the relevant action, not during scene
  construction or preview setup.
- Forecasts expose availability, timestamps and Apple attribution. Missing data
  never becomes a generated forecast or an unlabelled fallback.
- Keep cancellation, stale-result checks, Swift 6 isolation, configured platform
  minimums and native SwiftUI presentation intact.

## Apply the boundary

Define the small domain contract and explicit availability/failure policy, implement
its native adapter, then inject it from App. Reuse existing review screens where
possible. Provide local fixtures that never prompt for permissions. Follow
[Contributing](../../CONTRIBUTING.md) and [Testing](../Testing.md) for checks; native
permissions, signing and service behavior require separate runtime verification.
