# Packing, checklist intents, and controls

Use these patterns when extending Trip's preparation or system launch surfaces.
Verify changed signatures against the installed SDK; review device behavior separately.

## Packing with Foundation Models

- TripPackingContext contains duration and category names only; no trip title, notes, booking text, or checklist text.
- TripPackingService uses SystemLanguageModel through TripAISession with on-device processing only.
- TripPackingPlanning is nonisolated: the package defaults to MainActor, while its implementation runs on its worker actor.
- Keep preferences in the untrusted prompt and generation bounded; validate and deduplicate every generated title.
- TripPackingModel owns cancellation, a deadline, and generation tokens; changing context invalidates its draft.
- Review selections before append. Recheck the current checklist and capacity without replacing completed tasks.
- Keep deterministic templates available when the model, language, or hardware is unavailable.

## Checklist actions and widgets

- TripChecklistIdentity combines trip and item UUIDs; query canonical data and omit deleted identities.
- Set explicit completion values; never toggle a stale snapshot. Flush mutations before reporting success.
- Require authentication for checklist text and mutations. Reload reusable snippets after durable saves.
- Publish only TripChecklistProgress counts, never checklist titles, to App Group projections or Spotlight.
- New projection/activity fields remain optional so older JSON still decodes.
- Departures use the trip's civil calendar; a completed checklist is not a claim of travel readiness.
- Preserve existing automatic Siri phrases. Extra actions can be composed into custom named Shortcuts.

## Control Center and Dynamic Island

- ControlConfigurationIntent plus AppIntentControlConfiguration provides trip/destination selection.
- Request user configuration for required trip parameters; keep deleted-trip errors explicit.
- Control trip parameters use optional Swift types even when selection is required in the UI; metadata export rejects nonoptional entities without defaults.
- Foreground controls run in the host via allowedExecutionTargets.main and a handler installed at MyApp initialization.
- Shared code calls an injected handler, never AppRuntime or feature types; the host validates canonical records.
- URLRepresentableIntent and OpenURLIntent require universal links; do not use Trip's custom scheme with them.
- Existing widgetURL/Link navigation uses Trip's custom scheme and the app's guarded URL handler.
- Maps directions links use saved coordinates only; hide them when the activity is stale or ended.
- This handoff does not add a live ETA, routing updates, or location tracking.

## Sources and verification

- [Foundation Models guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation)
- [Configurable controls](https://developer.apple.com/documentation/widgetkit/appintentcontrolconfiguration)
- [Intent runtime and host execution](https://developer.apple.com/documentation/appintents/configuring-the-runtime-behavior-of-your-app-intents)
- [Universal-link-only URL intents](https://developer.apple.com/documentation/appintents/urlrepresentableintent)
- Run scripts/check.sh for source/wiring audits. Builds and Performance checks require user requests.
- Preview closures that mutate fixture state must explicitly return their final view.
- Verify cold controls, Siri snippets, unavailable models, and all widget/activity sizes on signed supported hardware.
