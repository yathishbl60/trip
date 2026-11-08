# App composition and navigation

App owns scene composition, navigation and system entry points. Explore and Trips
own their feature behavior. Start at `trip/App/ContentView.swift` → `AppShellView`
→ `AppController` → `AppModel`; ContentView retains one model per view lifetime.

## Find the owning code

Paths below are relative to `trip/App`.

| Change | Start with |
| --- | --- |
| Feature construction and cross-feature callbacks | `Models/AppModel.swift`, `Dependencies/AppTripServices.swift` |
| Shared library and intent access | `Models/AppRuntime.swift` and its workflow extensions |
| Activation, restoration and background flush | `Models/AppModel+Lifecycle.swift`, `Models/AppModel+Restoration.swift` |
| Typed external requests and canonical delivery | `Models/AppRequest.swift`, `Models/AppModel+Requests.swift` |
| Tabs, scene generations and launch mailbox | `Models/AppNavigationModel.swift`, `Views/AppShellView.swift` |
| Save-to-trip presentation over Explore | `Views/AppExploreView.swift` |
| Durable system publication | `Models/AppSystemModel.swift`, `Models/AppSystemProjection.swift` |
| Siri, Shortcuts and keyboard commands | `Intents`, `Commands` |

## Scene and service lifetimes

`AppRuntime` shares one revisioned library and system publisher. Each scene gets
its own AppModel, map, TripModel, drafts and navigation. Production providers come
from AppTripServices; intents use the same composition policy. See
[Dependencies](Dependencies.md) for service lifetimes.

Activation restores navigation, loads the library, refreshes system services, then
consumes eligible launch work. Generation checks follow suspension points. AppModel
captures the completed publication revision before restoration so a load that
already publishes does not immediately repeat reconciliation. Failed loading
never reconciles against an invented empty library.

Leaving the active state flushes pending edits and suspends Trips workers; the map
host owns its own cancellation. Feature tasks belong in models, not AppController.

## Cross-feature presentation

App wires weak `ExploreEnvironment` and `TripEnvironment` callbacks. Saving a place
from the map opens TripSaveView over Explore; saving from a place detail opens it
above that existing sheet. Selecting another place or opening directions dismisses
the pending save. Preserve both entry paths.

`TripPlaceSaveSession` has a UUID independent of the place ID. Sheet bindings capture
that session so a late dismissal cannot close a new save for the same place. The
zoom source still uses place identity. Return-to-map and directions callbacks let
Trips request host behavior without knowing the tab enum or ExploreModel.

App uses `TripModel+HostNavigation` and `TripModel+HostWorkflows` for semantic
operations such as opening a detail, search, import, checklist or booking-alarm
review. Trips owns internal route changes and child-model setup. App injects native
entity identifiers; feature models do not construct app-owned entity types.

## Requests and restoration

`AppRequest` separates screen destinations from workflow commands. Intents,
keyboard commands and URLs enter the same delivery path. Resolve canonical
trip/day/detail identities before changing visible selection, and check editing
protection both before and after library loading.

Each scene owns a request generation. New requests and tab choices invalidate old
resolutions, including restoration. Protected drafts remain visible with recovery
feedback. Missing trips preserve selection and show an app-owned notice, including
from Explore or an empty library. A shipped detail URL whose item was removed can
still open its surviving trip and explain that the item is unavailable.

`AppLaunchModel` is a mailbox, not a window navigation owner. Pending requests
coalesce to the latest value. An active scene with a ready library consumes the
request once; the current active scene is preferred. A failed load retains it for
a later successful activation. Scene-level identity and editing checks still apply
after consumption.

Saved-trip sections share typed routes across title menus, Siri and keyboard
commands. Day-map routes retain the exact day UUID. Each route also has a visit
identity: an old Back binding cannot dismiss a reopened destination. Repeated
section requests preserve lookup state; Open My Trips selects the library, and
opening a saved trip selects its itinerary. Export and alarm entry points open
review only; they do not perform the native action on navigation.

## Durable system publication

Successful library loads/saves feed AppSystemModel. Pure snapshot and bounded
Spotlight-detail preparation run in `AppSystemProjection` with `@concurrent`;
native entities and UI state remain on MainActor.

Publication has its own retained task lifetime, independent of the edit debounce.
Only a newer durable snapshot supersedes active publication. A single drain
coalesces pending snapshots and awaits previous work before the next publication's
native side effects. Generation checks prevent old results from marking a newer
snapshot complete. Widgets read bounded projections, never the private database.
See [System integrations](../SYSTEM-INTEGRATIONS.md) for data and signing contracts.

## Working on this area

Use `PreviewFixtures.app()` for local cross-feature presentation; prefer a focused
feature fixture otherwise. For request or lifecycle changes, review slow loading,
new requests during restoration, active drafts, stale sheet dismissal, failed load
recovery and multiple eligible scenes. Existing model checks and verification
commands are documented in [Testing](Testing.md) and [Contributing](../CONTRIBUTING.md).
Compilation does not establish native presentation or launch responsiveness.
