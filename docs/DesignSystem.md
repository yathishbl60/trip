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

## Spacing and typography contract

Use the spacing scale below for authored content. Keep native List, Form, toolbar,
sheet, and widget-container margins; default `.padding()` can remain system-owned.
Do not replace map collision dimensions, hit targets, or safe-area clearance with
content-spacing tokens. Those values describe different geometry.

| Relationship | AppTheme.Spacing | Points | Reason |
| --- | --- | --- | --- |
| Compact artwork or constrained system surface | compact | 2 | Optical grouping, never ordinary title/subtitle separation |
| Title and supporting text | tight | 4 | Keeps a row's identity together with a readable gap |
| Related items or vertical row padding | small | 8 | Separates peers without making lists sparse |
| Icon and text, controls within a group | medium | 12 | Consistent alignment across place rows and filters |
| Separate content blocks | large | 16 | Stronger grouping than an item's internal spacing |
| Custom content edge | edge | 20 | Common inset outside system-owned containers |

WidgetTheme and DirectionsSpacing own local subsets of the same scale because
extensions and reusable routing cannot depend on app types. The source gate checks
their values against AppTheme. Compact widgets may use denser typography appropriate
to their native family; a Home Screen widget is not an app row squeezed into a box.

Use `.headline` for place, trip, and destination identity; `.subheadline` with
`.secondary` for supporting dates and category/address metadata. Native form fields
and action labels retain `.body` unless a documented compact control needs otherwise.
Reserve `.caption`/`.caption2` for tertiary counts, provenance, map metadata, and
constrained widget families. Do not shrink important row text to make it fit.
Fixed point fonts are restricted to the documented MapEngine annotation footprint
and decorative glyph geometry, not ordinary content or action labels.

TripPlaceLabel is the common title/subtitle row, including save destinations.
At accessibility sizes it stacks its symbol above the text; category choices become
one flexible column and put counts below titles. Symbol tiles and numbered badges
scale with the text role they accompany. Keep primary text wrapping; use truncation
only where a compact map/system surface requires it and exposes the full meaning
through accessibility or the destination. Do not cap Dynamic Type to preserve a layout.

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

Use TripWarningLabel for clock conflicts, validation, and save/export failures.
Its primary text and warning symbol communicate the issue without depending on
orange or red text. Keep destructive controls on the native destructive role;
an error explanation and a Delete action have different responsibilities.

AppThemePreview and category previews cover light/dark controls and artwork.
Check increased contrast and Reduce Transparency using system accessibility settings;
their environment values are read-only in the installed SDK. Numeric palette contrast
checks do not replace checking actual materials over maps. Follow Apple's
[color guidance](https://developer.apple.com/design/human-interface-guidelines/color).

## Motion contract

`AppTheme.Motion` owns ordinary app feedback: `feedback` (0.2 seconds) for a changed
value or confirmation, `selection` (0.25 seconds) for selection/completion/progress,
and `press` (0.16 seconds) for the existing custom press style. Every recipe takes
the host's Reduce Motion value and returns no animation when it is enabled.
Native controls and navigation keep their native motion; do not add a second press
effect to a native glass button. Map motion and interruptible gallery gestures keep
their own documented timing owners instead of inheriting the ordinary-control recipe.

Animate the view that explains the change. CategoryChipsView owns the selected
category animation; FilterController mutates selection without wrapping downstream
map/search updates in a transaction. Checklist row movement is tied to completed
count, and progress/numeric/symbol transitions observe their specific value.
Keep symbol replacement on the symbol, not its enclosing button or label text.
Numeric transitions use identity under Reduce Motion. Completion feedback is finite;
native progress controls own continuous loading indication. Preserve stable IDs and
the actual save/selection outcome when an animation is interrupted or disabled.

## Presentation

`TripPresentationSource` and `TripPresentationZoom` share a host-owned namespace
for the place-detail Save button and its existing destination sheet. AppExploreView
supplies the namespace without coupling Explore to Trips. Map context-menu saves,
which have no retained source button, keep the standard sheet presentation.
Reduce Motion uses the native cross-fade transition. `TripCompletionSymbol` draws
the checkmark only as completion changes; it keeps a stable symbol footprint and
leaves spoken completion state to the owning action or row.

Place details lead with the place identity and native Directions/Save to trip
buttons. ViewThatFits stacks the actions when labels do not fit; large accessibility
text always stacks them. Fitted native buttons keep their content height inside
Lists and tall containers; explicit title-and-icon labels preserve action names.
Contact rows, Look Around, and nearby discovery follow; sharing and secondary actions
also remain in the toolbar. Live places use actual metadata and category symbols. Preview image references do not imply that
photographs are bundled or that a live photo source exists.

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
Trip editor covers use category symbols for live stops. Preview metadata may
reference sample imagery, but the app currently bundles only its icon artwork. Forms explain name-length validation and allow an expanded
sheet while typing. Filters identify active categories and describe loaded counts.

Use short, direct text and sentence case for in-app headings and actions. Keep Apple
product names and system menu conventions intact. Name the action or destination:
“Save to trip,” “Show in Explore,” and “Open in Maps.” Avoid internal terms such as
“loaded places,” vague promotional text, and repeating nearby labels. Empty states
explain the next step; errors name the problem and a useful recovery action.
Keep deletion consequences, sample-data labels, attribution, and route or AI
limitations explicit. Handle singular counts in the owning model. Shorter copy
must still explain what an action does and what data it affects.

## Enforcement and review

`python3 scripts/check_design_system.py` runs inside `bash scripts/check.sh`. It checks
the app, widgets, and routing source for new literal spacing/insets, fixed point
fonts, RGB colors, hard-coded ordinary animation timings, colored warning text,
and repeating custom animations. It also checks the shared spacing scale and all
23 named palette colors for four appearance variants and at least 4.5:1 contrast
against their solid reference background or white foreground. Foreground colors
also pass against a 12% tint wash; increased-contrast variants cannot reduce the ratio.
The current minimum among those reference pairs is 5.27:1 (2026-11-05).

This is a deliberately bounded source check, not a Swift type checker or visual
accessibility certification. Preview-only code is excluded from style linting.
It cannot measure materials over a map, system color rendering, clipping, spoken
navigation, animation pacing, or every possible Swift expression. Exceptions live
in `scripts/design_system_policy.json` with a path, rule, and concrete reason;
unused exceptions fail. Review new exceptions as design decisions, not lint bypasses.

For a UI change, record the affected roles and why a shared component or token is
appropriate. Add useful local previews in their real List/Form/container, including
long text, narrow widths, dark appearance, and accessibility sizes where relevant.
When runtime review is authorized, inspect light/dark/increased contrast, Reduce
Motion, Reduce Transparency, VoiceOver, rapid selection changes, and dismissal.
Always report source checks, compilation, and rendered/device review separately.
See [the 2026-11-05 consistency review](DesignConsistencyReview.md) for this pass's
findings, decisions, and remaining verification.

Framework rationale: Apple's [typography](https://developer.apple.com/design/human-interface-guidelines/typography),
[motion](https://developer.apple.com/design/human-interface-guidelines/motion), and
[accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
guidance support native scalable text, purposeful optional motion, and meaning that
does not depend on color alone. Trip's exact tokens and component roles above are
product decisions, not prescribed Apple numerical values.
