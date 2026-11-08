# Directions and native map chrome

Use this reference for map sheets, directions, safe areas, or native control placement.
Read [DIRECTIONS.md](../../../../DIRECTIONS.md) for current APIs and supported capabilities.

## Ownership

- `Views/Map/MapCanvasView.swift` preserves safe areas and overlays search notices.
- `Models/Camera/CameraModel+Viewport.swift` supplies host obstructions to TripRouting geometry.
- `Models/Camera/CameraModel+Routes.swift` applies TripRouting's camera rectangle.
- `Models/Explore/ExploreModel+RouteFraming.swift` delegates coalescing to DirectionsModel.
- These paths are relative to `trip/Features/Explore`.
- `Packages/TripKit/Sources/TripRouting` owns routing, UI, overlays, geometry, and Maps handoff.
- Apply [trip-routing](../../trip-routing/SKILL.md) for module and host integration changes.

## UI decisions from the current product

- Keep Explore's navigation header clear in loading, failure, and ready states.
- Use native MapUserLocationButton, compass, scale, and Apple's Maps/Legal attribution.
- ExploreMapView hosts location, compass, and scale together through automatic mapControls.
- Preserve the MapReader structure and automatic native control scope when editing adjacent toolbars.
- Reserve native map safe-area space only for persistent UI that covers or blocks attribution.
- Keep transient overlays, including bottom sheets, out of map safe-area insets.
- Float notices above attribution; showing or resizing a sheet must not move it.
- Ignore keyboard safe areas in the map host so loading and typing do not move attribution.
- Use measured place/directions sheet space for marker exclusions and route framing.
- Account for tabs, keyboard, rotation, floating sheets, and right-to-left layouts.
- Clear sheet obstruction on dismissal/replacement; reject callbacks from a previous selection.
- Keep native map chrome anchored while collision exclusions and camera fitting account for sheets.
- Offset route framing into the exposed viewport without changing native map safe areas.
- Coalesce route fits until sheet geometry settles; allow map gestures to interrupt following.
- Keep one interactive map panel and remeasure on selection or route replacement, including identical bounds.
- Native map deselection must not dismiss details; reject stale sheet/geometry callbacks by selection revision.
- On iOS use native leading placement for Directions and Place Details, with map interaction at every detent.
- Preserve the system grabber, corners, height choices and Close action as window size changes.
- On visionOS put contextual map tools in a split-view sidebar and frame the map in its own column.
- Keep action buttons content-sized with visible text, and use the native Close role for dismissal.
- Its compact state is non-dismissible by default; do not add overview/resize or share-direction buttons.
- Match the supplied visual hierarchy using native components and minimal customization.
- Expose only functional, supported controls; fewer supported features are preferable to inert replicas.

## Reuse and behavior

- Inject routing, place search, location, close, geometry, and tint through existing contracts.
- Directions must remain usable without Explore, app navigation, or a particular data provider.
- Treat location denial, no location fix, loading, stale responses, cancellation, no routes, and retry explicitly.
- Preserve compatible results during refresh; prevent navigation using obsolete results.
- Check installed MapKit support before adding transport modes, route options, or metadata.
- Keep Apple Maps handoff distinct from in-app route calculation and step presentation.
- Test control actions and sheet states when verification is requested; previews alone do not prove behavior.
