# App composition

Start at `ContentView` → `AppShellView` → `AppController` → `AppModel`.
ContentView retains one AppModel for its view lifetime. AppModel owns Explore,
Trips, and tab navigation.

| Responsibility | Owner |
| --- | --- |
| Feature construction and host callbacks | Models/AppModel.swift |
| Loading trips, background flush, launch delivery | Models/AppModel+Lifecycle.swift |
| Typed requests, canonical resolution, delivery lifetime | Models/AppRequest.swift, Models/AppModel+Requests.swift |
| Tabs | Models/AppNavigationModel.swift, Views/AppShellView.swift |
| Save sheets from the map or place details | Views/AppExploreView.swift |
| Siri/Shortcuts and keyboard commands | Intents, Commands |

ExploreEnvironment.savePlace calls TripModel.chooseDestination. Trips owns the
pending TripPlaceSaveSession; AppExploreView presents TripSaveView. A context-menu save presents
over the map; a save from details presents above the existing detail sheet.
Selecting another place or opening directions dismisses pending saving through
ExploreEnvironment.dismissSave. Keep both presentation paths when changing this flow.

Each save presentation has its own UUID, independent of Place.id. Native sheet
bindings capture that session so a delayed dismissal cannot close a newly reopened
save sheet for the same place. The zoom source continues to use the place identity.

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
New navigation requests and tab selections invalidate older asynchronous resolutions,
including scene restoration. A late restored tab cannot replace a newer user choice.

`AppRequest` distinguishes screen destinations from transient workflow commands.
Its factory methods preserve existing intent and keyboard entry points; the two
delivery switches are exhaustive. Custom URLs decode into these same requests.
Resolution loads the canonical library when required, checks the scene's request
generation and editing policy, and then applies the destination or delegates the
workflow. Invalid trip/day/detail identities are checked before changing visible
selection. An invalid detail item in a shipped URL retains the existing fallback:
open its surviving trip and explain that the item is unavailable.

`AppLaunchModel` is a foreground-request mailbox, not a window navigation owner.
Requests coalesce to the latest value while no eligible scene can receive them.
Only an active scene with a successfully loaded library consumes a pending request;
the current `AppRuntime.activeScene` is preferred when available. Consumption is
synchronous and removes the request exactly once. Each scene then applies its own
request generation, selection and draft protection. Loading failure retains the
mailbox request for a later successful activation.
Restoration failures use the library's existing failure/retry presentation;
explicit navigation failures also report that the requested destination is unavailable.

App calls the semantic methods in `TripModel+HostNavigation` and
`TripModel+HostWorkflows` to open a saved detail, prepare an assistant draft,
start search/import/checklist review, or suspend services. Trips owns the internal
route updates, lookup selection, child workflow setup and cancellation. The host
does not mutate those child presentation fields to carry out a navigation request.

Saved-trip sections share `TripSection` routes between Siri, keyboard commands,
and the native navigation-title picker. The picker marks the current section;
child sections show the trip name as an iOS navigation subtitle. Keep visionOS
on its supported title menu and native Back path. A day-map route carries the
saved day UUID in a typed map target, including when entered from the itinerary menu.
Each presentation has a visit identity: a late Back binding cannot close the same
destination after it has been dismissed and reopened. Repeated section requests
compare destination identity and keep the existing visit and lookup state. Do not add a
separate untracked push for the same destination. A stale dismissal binding must
not remove a newer route. Explicit Open My Trips returns to the library; opening
a saved trip returns to its itinerary, including when that trip was already selected.

Foreground tool requests validate canonical records before queueing and protect
editing again when delivered to a scene. Trip/day tools reuse the feature's existing
review workflows. Saved detail search opens the current booking or visit editor,
retaining search context after dismissal. Export review never performs an export.
Onscreen trip, detail, and checklist identifiers are injected by App composition.
Features do not construct app-owned entity types.

Repeated section requests preserve the current lookup query and filters. Validate
day/detail destinations before replacing the visible route, and recheck new-event
day identity and capacity at delivery. Draft creation stays in the Trips model;
App only selects the trip and delivers the validated request. Opening an export
review keeps the current section so Cancel returns to the same context.

This follows Apple's [toolbar guidance](https://developer.apple.com/design/human-interface-guidelines/toolbars)
on useful titles, restrained controls, and standard Back behavior, and
[Siri guidance](https://developer.apple.com/design/human-interface-guidelines/siri)
on familiar task names and contextual entities. Runtime usability remains a
separate verification step from the compile-only checks authorized for this change.

`TripAppTests` supplies local service implementations and a controllable store for
request-ordering, slow-restoration, editing-protection, missing-ID and single-window
delivery checks. Test fixtures do not import DEBUG preview data or open the live
storage/AI services. Source checks, test-bundle compilation, executed tests and
native visual interaction are separate verification results.

## Service composition

`Dependencies/AppTripServices.swift` constructs production Trips models with
TripStoring and domain planning/lookup/ordering protocols. AppRuntime shares the
durable library and its system publisher; each scene gets its own assistant,
lookup, packing, and tracking state. App intents use the same service factory. AppModel requires its
Trips model explicitly. See [Dependencies](Dependencies.md) for lifetime details.

Native booking capture, explicit exports and alarms, and planned-visit weather follow
[the native travel service contract](NativeTravelServices.md). Reusable adapters stay
in TripIntegrations; feature models receive TripDomain protocols from AppTripServices.
