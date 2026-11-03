# Shared presentation

AppTheme owns common spacing, colors, shape constants, and platform control targets
(44 points on iOS, 60 on visionOS). PressFeedbackStyle
owns reusable press feedback. `trip/Shared/Places` adapts TripDomain places to
app-specific annotation labels and category colors.

Keep shared UI free of feature models, app navigation, service calls, and assets
owned by another feature. Place a component here only when multiple features use
it; feature-specific UI stays with its owning Views folder. Every view/style has
named previews in the same file. Directions intentionally uses host-injected tint
and system styling so it remains independently reusable.

Changes here can affect several screens. Coordinate shared API changes, preserve
Dynamic Type and Reduce Motion, and use local light/dark/accessibility previews.
Run `bash scripts/check.sh`; visual verification is separate from compilation.

## Colors

`DesignSystem/Colors.xcassets` is compiled into the app and widget extension. Its
named colors provide light, dark, and increased-contrast variants. `AppTheme.accent`
is the teal foreground and control tint; `accentFill` is the darker background for
prominent buttons with `onAccentFill` content. Keep links and unfilled controls on
the foreground tint. Ratings use a separate adaptive gold. Native primary/secondary
text, grouped surfaces, materials, disabled controls, and destructive roles retain
their system treatment; do not tint whole sheets or replace semantic text colors.

Place categories share one palette across Explore, saved places, and Trip Map.
`PlaceCategory.color` is for foreground symbols and soft tinted backgrounds;
`markerTint` is a darker fill for native MapKit markers with white glyphs. Keep
checkmarks, outlines, labels, and selection traits alongside color. Directions
keeps blue routes distinct from teal app actions and accepts a host appearance.
WidgetTheme reads the same catalog while preserving native widget rendering modes.

AppThemePreview and category previews cover light/dark controls and artwork.
Check increased contrast and Reduce Transparency using system accessibility settings;
their environment values are read-only in the installed SDK. Numeric palette contrast
checks do not replace checking actual materials over maps. Follow Apple's
[color guidance](https://developer.apple.com/design/human-interface-guidelines/color).

## Presentation

Place details lead with the place identity and native Directions/Save to trip
buttons. ViewThatFits stacks the actions when labels do not fit; large accessibility
text always stacks them. Fitted native buttons keep their content height inside
Lists and tall containers; explicit title-and-icon labels preserve action names.
Contact rows, Look Around, and nearby discovery follow; sharing and secondary actions
also remain in the toolbar. Live places use their actual metadata; illustrative category
photos are shown only for bundled sample places, with a visible sample label.

On iOS, navigation screens apply `.scrollEdgeEffectStyle(.soft, for: .top)` to their
content hierarchy, including pushed destinations and modal forms. AppShellView sets
this policy for every page in every app window; standalone feature navigation roots
also apply it so reused features keep the same appearance. This API is unavailable
on visionOS, which retains its native edge treatment. Explore retains
its transparent navigation background. Place and direction dismissal uses the native
Close button role. Compact directions uses a 32-point native sheet corner radius;
expanded sheets retain the system radius, background, grabber, and resize gestures.
Scroll-edge styling configures scroll containers; adding it to a page does not
verify a map canvas's header appearance. Trip Map also clears the navigation-bar
background on iOS and uses the native background extension on its map pane, keeping
controls and attribution inside the existing safe areas.
See Apple's [scroll edge effects](https://developer.apple.com/documentation/swiftui/view/scrolledgeeffectstyle(_:for:)),
[background extension](https://developer.apple.com/documentation/swiftui/view/backgroundextensioneffect()),
[button sizing](https://developer.apple.com/documentation/swiftui/buttonsizing), and
[Close role](https://developer.apple.com/documentation/swiftui/buttonrole/close).

The trip library uses compact category artwork and separate title, date range,
and saved-place counts. Accessibility text sizes stack the artwork above the text.
Trip editor covers may show labeled sample imagery for bundled places; live stops
use category symbols. Forms explain name-length validation and allow an expanded
sheet while typing. Filters identify active categories and describe loaded counts.

Use short, direct text and sentence case for in-app headings and actions. Keep Apple
product names and system menu conventions intact. Name the action or destination:
“Save to trip,” “Show in Explore,” and “Open in Maps.” Avoid internal terms such as
“loaded places,” vague promotional text, and repeating nearby labels. Empty states
explain the next step; errors name the problem and a useful recovery action.
Keep deletion consequences, sample-data labels, attribution, and route or AI
limitations explicit. Handle singular counts in the owning model. Shorter copy
must still explain what an action does and what data it affects.
