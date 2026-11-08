# Adaptive app and window contract

Trip configures native iOS/iPadOS and visionOS hosts and widgets at 27.3+.
TripKit also declares macOS 27.3 for its package targets; that does not create a
native Mac app. Use this guide for window/layout changes and [App](docs/App.md)
for request delivery. Setup and build commands live in [Contributing](CONTRIBUTING.md).

## Navigation and data

- `TabView` uses `sidebarAdaptable`; iPhone requests tab-bar placement while iPadOS
  and visionOS retain sidebar preference. SwiftUI owns adaptation.
- Trips uses `NavigationSplitView` for the library and selected plan, including
  native compact collapse. Ordinary selection stays in the current window.
  Open in New Window uses a UUID-valued `WindowGroup` where supported.
- Each `ContentView` retains its own `AppModel`, map, routing, selection, search,
  sort, drafts, and assistant. Production windows/intents share a revisioned
  `TripLibraryModel` and system publisher, not their transient feature state.
- Commands use focused scene values. Foreground intents deliver typed requests
  to one eligible active scene; a background scene must not consume them.
- Links/restoration share request generations. New user input invalidates older
  loading; validate saved IDs again after awaiting data and before presentation.
- `SceneStorage` restores the tab and selected trip UUID. Explicit trip-window
  links open Trips; restoration preserves the saved tab. Deleted trips clear
  selection across windows. Reopening a selected trip reveals compact detail
  without resetting compatible state.
- Keep secondary editor actions in native `ToolbarOverflowMenu`, and protect
  unsaved editing sessions when external requests arrive.

## Resizing and reserved regions

Use measured value rectangles, not device-width tables. `MapReader` reprojects
when geometry changes; its proxy stays inside the live callback. On iOS, reserved
regions and measured sheets are translated into the same global/map-local spaces
used by collision and camera code. Frames already include system margins.
The map remains a continuous native surface with controls and attribution in
native safe areas.

Trip Map and Today observe hinge context only while mounted. An active interior
division during a partial fold selects their pane treatment. Closed/fully open
poses and windows without hinge data use normal container adaptation. Moving a
hinge within a pose must not reset navigation or camera state.

Trip Map uses `AnyLayout` inside the existing split navigation, retaining map and
stop-list identity through column collapse. Division geometry selects the axis,
lengths, and gap; otherwise container aspect ratio does. A narrow usable sliver
moves content to the larger side. Vertical maps use a text-scaled preferred list
height, capped at half the available height. Today keeps the next commitment and
remaining itinerary independently scrollable. See [Today](docs/TripTimeAndToday.md).

On a partial fold with room for both panes, the day picker lives in the stop-list
title. Place actions use `ViewThatFits` and native button sizing; long labels stack,
and accessibility text always stacks. Keep semantic toolbar placement, keyboard
reachability, and equivalent list actions.

## Sheets and spatial windows

Place Details and Directions request leading native sheets on iOS/iPadOS, with a
400-point ideal width and native detents. The exposed map remains interactive.
Dragging changes height while retaining selection/route and the navigation path;
accessibility text omits the smallest stop. Forms and assistants use form-sized
presentations. Directions Steps/search stay in its navigation stack and Options
uses its toolbar popover. See [Directions](DIRECTIONS.md).

On visionOS, Explore uses a leading `NavigationSplitView` sidebar beside the map.
Hiding it keeps the route active; Close ends the presentation. The map column's
measured size already accounts for the sidebar. Native resizable windows, controls,
sheets, and hover feedback remain the platform model.

ActivityKit and its widgets/previews compile only on iOS. visionOS retains visit
tracking through shared projections and interactive widgets, with native spatial
families and simpler distant content. It does not simulate Dynamic Island.
Custom place/trip targets use 44 points on iOS and 60 on visionOS; system controls
keep their own styling. See [Shared presentation](docs/DesignSystem.md).

The inactive photo-gallery implementation preserves zoom and scales/clamps pan
after a resize; in-flight gestures wait for release. This retained code is not
a currently reachable photo feature. See [Place gallery](docs/PlaceGallery.md).

## Check retained presentation across resizing

Open a place, directions, or save sheet before resizing or folding. Compare its
content, ideal width, selected detent, and exposed map with the same sheet opened
after the transition. Preserve drafts, selection, and presentation identity.

If native sheet sizing differs between those paths, isolate the layout in a
small SwiftUI reproduction before changing Trip's geometry. Check whether the
system requests a fresh size proposal. Do not force dismissal/reopening, reset
presentation identity, or add a UIKit bridge to hide a sizing problem.

## Check adaptive behavior

Review compact, wide, and short windows; Duo closed/open/folded transitions;
Split View, Stage Manager, external displays, two trip windows, keyboard focus,
restoration, deleted links, map controls/Legal, place/directions/save sheets,
location denial, route cancellation, Dynamic Type, VoiceOver, and Reduce Motion.

Use the shared source gate and targeted platform commands from
[Contributing](CONTRIBUTING.md) when verification is in scope. Report iOS and
visionOS compilation separately. Source checks and builds do not establish pose,
spatial-input, rendering, or signed system-integration acceptance.

Framework references: [layout](https://developer.apple.com/design/human-interface-guidelines/layout),
[Duo layouts](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo),
[ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview),
and [button sizing](https://developer.apple.com/documentation/swiftui/view/buttonsizing(_:)).
Trip's pane ownership and geometry policy remain project decisions.
