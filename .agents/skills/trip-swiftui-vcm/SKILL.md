---
name: trip-swiftui-vcm
description: Change Trip feature ownership, struct controllers, composed models, injected services, or app/package boundaries.
---

# Trip feature architecture

Read [rules](../../../AGENTS.md), [architecture](../../../ARCHITECTURE.md), and the owning feature's context.
Use global `app-development` architecture, state, and concurrency topics for framework detail.
The global skill owns the implementation workflow; this skill defines Trip's contracts.

## Local implementation contract

- Feature code lives in `trip/Features/<Feature>/{Views,Controllers,Models}`.
- Views render model projections; domain edits and validated bindings go through controller actions.
- Each controller is a struct storing only its model. Models compose behavior and smaller state owners.
- App composes features; package targets never reference app or sibling feature types.
- Read [state ownership](references/state-ownership.md) when changing identity, lifetimes, or observation.
- Keep 100-line Swift files and 20-line members; use cohesive extractions, not compressed statements.
- Use [trip-previews-build](../trip-previews-build/SKILL.md) for local fixtures and verification commands.

## Existing owners

- AppRuntime shares the durable library and system publisher; ContentView owns each window's AppModel.
- ExploreModel composes camera, catalog, filter, layout, location, and TripRouting models.
- TripModel composes focused Checklist and Collections owners; each owns its drafts and library-backed edits.
- AppTripServices selects live services; PreviewTripServices supplies isolated workers.
- Inject providers, availability, failure presentation, and host callbacks; no live-service fallback in Trips models.
- MapEngine's PlaceRepository owns caching; MarkerLayoutEngine owns layout history.
- TripDomain owns Sendable contracts; implementation packages depend on it and TripLocalization.
- Check `scripts/architecture/app-ownership.json` before introducing dependencies.
- TripPlaces owns native search and item conversion; Shared/Places retains autocomplete UI and appearance.
- Checklist/Collections views use focused controllers; App invokes semantic Trips host operations.
- AppTripServices injects the Trips search factory; local previews have no live-search fallback.

## Product-specific UI and compiler policy

Read [native UX](references/native-ux.md) for canvas, sheet, or styling changes.
AppShellView applies soft top scroll edges on iOS; standalone navigation roots retain that policy.
Keep Explore navigation transparent. Guard iOS styling from unsupported visionOS APIs.
MemberImportVisibility requires explicit defining-module imports in every file.
Read [compiler boundaries](../trip-previews-build/references/compiler-boundaries.md) when extracting shared helpers.
Do not replace VCM with MVVM or introduce UIKit adapters.
