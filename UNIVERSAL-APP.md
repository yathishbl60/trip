# Adaptive app and window contract

Trip has native iOS/iPadOS and visionOS host and widget configurations. Shared
TripKit modules declare iOS, macOS, and visionOS 27.3 deployment support.

## Contents

- [Navigation and data](#navigation-and-data)
- [Resizing and reserved regions](#resizing-and-reserved-regions)
- [visionOS](#visionos)
- [Verification matrix](#verification-matrix)

## Navigation and data

- Native TabView uses sidebarAdaptable with tab-bar placement on iPhone so
  Trips and Explore remain reachable alongside the Trips library sidebar.
  iPadOS and visionOS retain their sidebar preference. The system owns bar position
  and adaptation.
  Trips uses NavigationSplitView for the
  library and selected plan, collapsing naturally in compact windows.
- Ordinary trip selection stays in the current window. “Open in New Window” in a
  trip context menu uses a UUID-valued WindowGroup when multiple windows are supported.
- Each ContentView retains its own AppModel, map, selection, routing, form drafts,
  assistant, trip search, and sort. All production windows and intents share one
  revisioned TripLibraryModel and system publisher to avoid conflicting store sessions.
- Commands use SwiftUI focused scene values; foreground intents queue requests
  for an active scene. A background scene cannot consume a pending destination.
- SceneStorage restores each window's tab and selected UUID after loading. Deleted
  trips clear selection across windows; missing deep-link destinations remain recoverable.
- Restoring a selected trip preserves the saved tab; explicit trip-window links open
  Trips. Reopening the same trip reveals its compact detail without clearing its state.
- Trip editor secondary actions use ToolbarOverflowMenu, sharing native overflow
  with other toolbar items instead of nesting a custom ellipsis menu.

## Resizing and reserved regions

Navigation, bars, sheets, menus, map controls, and attribution use system components.
MapReader reprojects when container geometry changes. On iOS the map translates
reserved regions into global coordinates and passes their rectangles to collision
and camera logic. Frames include
system margins already. Route and selection framing choose an exposed rectangle
outside the fold, occlusions, and sheet. The map stays one continuous native surface.

Trip Map and Today observe SwiftUI's hinge context while their destination is
mounted. A partially open hinge enables the folded treatments when an active
division crosses the destination. Closed and fully open poses use native window
adaptation, as do windows without hinge data. Moving the hinge within a pose
leaves navigation and camera state alone.

Trip map uses AnyLayout inside the existing NavigationSplitView. It keeps both
the map and stop list present when the navigation columns collapse. On iOS,
an active interior division region determines the pane axis, lengths, and gap.
Without a division, the current container aspect ratio determines the layout.
Pane identity stays stable without device-width tables or nested ArrangementView.
Map controls remain native and within safe areas.
When both panes fit on a partial fold, the day picker is the day title in the
scrollable stop list. Today uses independently scrollable panes for the next
commitment and the remaining itinerary. A narrow sliver sends the content to
the larger usable side. See [Today](docs/TripTimeAndToday.md).
Vertical day maps use a text-scaled preferred list height instead of assigning a
fixed percentage to the map; the fallback caps the list at half the available height.
Place actions use ViewThatFits and native buttonSizing; full labels stack when
they cannot fit alongside each other. Accessibility text always uses the stack.
Place details, filters, trip forms, the assistant, and Directions
use native form-sized presentations. Semantic toolbar placements let the system
position close and primary actions; text-heavy items remain horizontal on iOS 27.1.
Gallery resizing retains zoom and scales the pan offset with the fitted image,
then clamps it to the new viewport. In-flight gestures wait for release after a
resize so old translations cannot jump the image.
Directions expands its content for regular-width and short windows, including
when a previously compact sheet moves into a wider layout.

## visionOS

The app opens native resizable windows, uses standard SwiftUI controls and sheets,
and gives custom map markers native hover feedback. Directions expose their
expanded controls because spatial sheets do not offer the iPhone's collapsed detent.
Saved trips, place search, routes, manual planning, and supported on-device
intelligence keep their existing service availability checks.

ActivityKit and Live Activity widget/previews compile on iOS only. visionOS retains
actual visit tracking through the same App Group projection and interactive widgets.
Spatial widgets support native glass and elevated/recessed mounting, and simplify
content for distant viewing. No unsupported Dynamic Island surface is simulated.
Custom place and trip rows use 60-point targets on visionOS and 44-point targets
on iOS; native buttons retain system styling. Custom selectable rows have standard
hover highlights, and important place names can grow at accessibility text sizes.

Current guidance: [Apple layout](https://developer.apple.com/design/human-interface-guidelines/layout),
[iPhone Duo layouts](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo),
[ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview),
and [native button sizing](https://developer.apple.com/documentation/swiftui/view/buttonsizing(_:)).

## Verification matrix

Run `bash scripts/check.sh` for source ownership, line limits, previews, and wiring.
When requested, `bash scripts/build.sh app Debug` builds iOS Simulator and
`bash scripts/build.sh visionOS Debug` builds visionOS Simulator, including widgets.

Exercise compact/wide/short windows; Dynamic Type; Duo closed/open/folded poses;
Split View on either side; Stage Manager and external-display windows; two concurrent
trip windows; keyboard focus; state restoration; deleted links; map controls/Legal;
place/directions/save sheets; denied location; route loading/cancellation; and Reduce Motion.
Build results establish compilation only; pose, spatial input, and signed system
integration behavior require runtime/device checks.
