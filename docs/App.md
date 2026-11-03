# App composition

Start at `ContentView` → `AppShellView` → `AppController` → `AppModel`.
ContentView retains one AppModel for its view lifetime. AppModel owns Explore,
Trips, and tab navigation.

| Responsibility | Owner |
| --- | --- |
| Feature construction and host callbacks | Models/AppModel.swift |
| Loading trips, background flush, launch delivery | Models/AppModel+Lifecycle.swift |
| Tabs | Models/AppNavigationModel.swift, Views/AppShellView.swift |
| Save sheets from the map or place details | Views/AppExploreView.swift |
| Siri/Shortcuts and keyboard commands | Intents, Commands |

ExploreEnvironment.savePlace calls TripModel.chooseDestination. Trips owns the
pending Place; AppExploreView presents TripSaveView. A context-menu save presents
over the map; a save from details presents above the existing detail sheet.
Selecting another place or opening directions dismisses pending saving through
ExploreEnvironment.dismissSave. Keep both presentation paths when changing this flow.

TripEnvironment.showPlace switches to Explore and focuses its camera. Neither
feature knows the host's tab enum or the other feature's model. Retain weak
captures in host callbacks so features do not keep AppModel alive.

New Trip launch intents wait for successful library loading. Scene inactivity
flushes edits and cancels generation; the map host stops its own work.
Do not move feature tasks into AppController.

Use `PreviewFixtures.app()` for local integration previews. Use a feature's own
fixture when editing that feature. After wiring changes, run `bash scripts/check.sh`.
When runtime verification is requested, exercise save from both entry points,
return-to-map, new-trip intents, backgrounding, and restoring the selected tab.

External requests and URL handoffs check for an active editing session before
changing navigation, and check again after asynchronous library loading. A blocked
handoff preserves the draft and reports recovery in its form when supported.
Missing-trip links preserve the current selection and explain that the trip is gone.
App-owned alerts make unavailable links visible from Explore and an empty library too.
New Trip keyboard commands are disabled while a draft or modal workflow is active;
the model also rejects a second creation request without replacing the current draft.
New navigation requests and tab selections cancel an older pending link resolution.

## Service composition

`Dependencies/AppTripServices.swift` constructs production Trips models with
TripStoring and domain planning/lookup/ordering protocols. AppRuntime shares only
the durable library; each scene gets its own assistant, lookup, packing, and
tracking state. App intents use the same service factory. AppModel requires its
Trips model explicitly. See [Dependencies](Dependencies.md) for lifetime details.

Native booking capture, explicit exports and alarms, and planned-visit weather follow
[the native travel service contract](NativeTravelServices.md). Reusable adapters stay
in TripIntegrations; feature models receive TripDomain protocols from AppTripServices.
