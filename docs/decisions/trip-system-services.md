# Native travel services

TripIntegrations owns adapters for booking documents, Calendar, Reminders, alarms,
and weather. These capabilities have different native permission and lifecycle
requirements from private trip persistence or generated planning. They share only
TripDomain values/contracts and TripLocalization text. Package code never depends
on the app, feature models, or a host bundle identifier.

AppTripServices creates live providers. Trips receives the providers through small
workflow models; previews use local implementations. The app retains system-action
and forecast services across scenes. Booking extraction produces a proposal; the
existing event draft and durable library remain the only booking-save path.

Calendar and Reminders export selected data through explicit review. They do not
silently synchronize external edits. Booking alarms use persistent identifiers and
are reconciled after durable saves. Permission prompts occur at the requested
action. Forecasts expose availability, timestamps, and Apple attribution; an absent
forecast never becomes a generated weather claim.

All new interfaces retain Swift 6 concurrency, existing platform minimums, native
SwiftUI presentation, and the project's physical source limits. SDK declarations,
source audits, a single iPhone Simulator build, and signed-device service checks
are separate verification scopes.
