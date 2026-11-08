---
name: trip-universal-app
description: Change Trip's split navigation, window ownership, Duo map exclusions, or iOS/visionOS host and extension integration.
---

# Trip adaptive app contracts

Read [rules](../../../AGENTS.md), [architecture](../../../ARCHITECTURE.md), and [platform contract](../../../UNIVERSAL-APP.md).
Use global `app-development` platform topics for iPad, Duo, and spatial framework detail.
Platform API evidence lives in global `app-development`; this skill owns Trip's integration choices.

## Navigation and layout

- Trips uses NavigationSplitView for library/editor; preserve native compact collapse and selected UUIDs.
- TabView remains sidebarAdaptable with native toolbar items; retain search appearance and sheet theme.
- Resizing does not authorize changes to Explore's header, controls, annotation stages, or native attribution.
- Feed measured value rectangles into map exclusions and route framing in the same coordinate space.
- Keep MapProxy inside its reader; follow [map safe areas](../trip-map-decluttering/references/directions-and-safe-areas.md).
- Preserve all safe-area edges and reserved-region updates; do not replace measured geometry with device tables.
- iOS top scroll styling remains guarded; visionOS uses its supported native equivalent.
- Trip targets iOS/iPadOS and visionOS 27.3+ by explicit user decision; align TripKit platforms and gate only newer APIs.

## Window and platform ownership

- AppRuntime shares TripLibraryModel and the system publisher, not an AppModel or map.
- ContentView owns each window's AppModel, ExploreModel, presentation, assistant, search, and sort.
- Commands use the focused scene; foreground intents queue AppRequests for one eligible scene.
- Links and restoration share scene request generations; newer user actions invalidate older loading.
- SceneStorage restores tab and selected trip; validate IDs after load and cross-window deletion.
- Trip windows use value-based WindowGroup; ordinary row taps stay in their current window.
- iOS and visionOS host/extension settings and shared-source membership must agree.
- ActivityKit, activity widgets, and their previews remain guarded by os(iOS).
- visionOS retains real visit tracking and native spatial widget families.
- Preserve shared App Group data and package dependency boundaries across both platforms.

## Acceptance paths

Use [trip-previews-build](../trip-previews-build/SKILL.md) for local commands and fixtures.
When requested, exercise compact/wide resizing, Duo poses, split views, and two independent windows.
Check search, selected annotations, route framing, sheets, keyboard, and Legal after resizing.
Keep iOS and visionOS build/runtime results separate; untested poses remain unverified.
