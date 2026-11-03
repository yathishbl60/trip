# Trip state and identity contracts

Use global `app-development` state and performance topics for Observation and identity techniques.
Read only the relevant `app-development` state/performance topic when additional API detail is needed.

- AppRuntime's durable library is shared; AppModel, camera, selection, search, drafts, and sort are window-local.
- Map and trip-selection side effects have dedicated modifiers; preserve those ownership boundaries.
- Lists use persisted trip/place IDs. Save-search query state belongs to its sheet, not library refreshes.
- Library mutations go through insert/update/updateDay/updateCollection/remove; views cannot mutate its array.
- Keep MapProxy observations and conversions inside the live MapReader callback.
- Controller setters preserve validation and save semantics when introducing bindings.
- Trip package text stays bundle-aware and deferred; follow [localization](../../../../docs/Localization.md).
- Fixtures inject independent models and services rather than the shared AppRuntime.

For a source extraction, preserve existing state lifetimes and inspect the affected consumers.
The [applied review](../../../../docs/reviews/apple-guidance-2026-10-24.md) records earlier Trip changes, not current verification.
