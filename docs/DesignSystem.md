# Shared presentation contract

`trip/DesignSystem` owns shared app presentation. `AppTheme` supplies spacing,
colors, shapes, and custom control targets (44 points on iOS, 60 on visionOS).
`PressFeedbackStyle` owns custom press feedback; `trip/Shared/Places` adapts domain
places to annotation text and category colors. Native controls keep native sizing
and styling where applicable.

Shared UI must not depend on feature models, app navigation, services, or another
feature's assets. Promote a component here when several features need its semantics;
otherwise keep it with the owning views. Directions uses injected appearance and
system styling so its package has no app-theme dependency. Contributor setup and
verification commands live in [Contributing](../CONTRIBUTING.md).

## Spacing and typography contract

Use this scale for authored content. Keep native List/Form/toolbar/sheet/widget
margins; ordinary `.padding()` can remain system-owned. Collision footprints, hit
targets, and safe-area clearance are separate geometry, not content spacing.

| Relationship | `AppTheme.Spacing` | Points |
| --- | --- | ---: |
| Compact artwork/constrained system surface | `compact` | 2 |
| Title and supporting text | `tight` | 4 |
| Related items/vertical row padding | `small` | 8 |
| Icon and text/controls within a group | `medium` | 12 |
| Separate content blocks | `large` | 16 |
| Custom content edge outside native containers | `edge` | 20 |

`WidgetTheme` and `DirectionsSpacing` own local subsets with checked values;
extensions/packages do not import app types. Widgets retain their family-specific
hierarchy rather than squeezing an app row into a small surface.

| Text role | Treatment |
| --- | --- |
| Place/trip/destination identity | `.headline` |
| Supporting dates, category, address | `.subheadline`, `.secondary` |
| Native fields and action labels | `.body` unless a documented compact role requires otherwise |
| Tertiary counts/provenance/map metadata | `.caption` or `.caption2` |

Do not shrink important text to fit. Fixed fonts are limited to documented map
footprints/decorative geometry. `TripPlaceLabel` provides title/subtitle rows,
including save destinations. At accessibility sizes it stacks its symbol above
text; category choices use one flexible column with counts beneath titles.
Scale symbol tiles and numbered badges with their text role. Keep primary text
wrapping and never cap Dynamic Type to preserve a layout. Compact surfaces may
truncate only when full meaning remains available through accessibility/detail.

## Colors

`DesignSystem/Colors.xcassets` is shared by the app and widgets, with light, dark,
and increased-contrast variants. Use `accent` for teal foregrounds/unfilled controls,
`accentFill` for prominent filled controls, and `onAccentFill` on those fills.
Ratings have adaptive gold. Preserve native primary/secondary text, surfaces,
materials, disabled states, and destructive roles; do not tint whole sheets.

Category `color` is a foreground/soft-background color. `markerTint` is the darker
native MapKit marker fill behind white glyphs. Pair color with labels, checkmarks,
outlines, and selected traits. Directions keeps blue routes distinct from teal
actions. Widgets honor native rendering modes.

Use `TripWarningLabel` for clock conflicts, validation, and save/export failures:
primary wrapping text plus a warning symbol. A Delete action uses the native
destructive role; explanatory text should not depend on red/orange alone.

Local theme/category previews cover controls and artwork. Increased contrast and
Reduce Transparency need system-setting review; solid reference contrast checks
cannot certify materials over a map. See [Apple color guidance](https://developer.apple.com/design/human-interface-guidelines/color).

## Motion contract

`AppTheme.Motion` owns ordinary feedback: `feedback` 0.2 seconds, `selection`
0.25 seconds, and custom `press` 0.16 seconds. Each recipe takes Reduce Motion
and returns no animation when enabled. Native controls/navigation retain native
motion; do not add a second press effect to a native glass button. Map and gallery
gesture timing stay with their own owners.

Animate the view explaining the change. Category selection is view-owned;
controllers do not wrap downstream map/search work in a broad transaction.
Checklist movement/progress and numeric/symbol transitions observe their relevant
value. Keep symbol replacement on the symbol, numeric identity under Reduce
Motion, finite completion feedback, and stable IDs when transitions are interrupted.
Native progress controls own continuous loading indication.

`TripPresentationSource`/`TripPresentationZoom` share a host-owned namespace between
the place Save button and its sheet. App composition supplies it without coupling
Explore to Trips. Context-menu saves have no retained source button and use standard
presentation. Reduce Motion uses the native cross-fade. `TripCompletionSymbol`
retains a stable footprint; the owning row/action supplies spoken completion state.

## Presentation and copy

Place details lead with identity and native Directions/Save actions. `ViewThatFits`
stacks long labels; accessibility text always stacks. Fitted buttons retain their
content height and explicit action names. Contact rows, Look Around, and nearby
search follow; Share/secondary actions remain in the toolbar. Live metadata and
category artwork must not imply bundled photos or a live photo provider.

On iOS, app pages and standalone feature navigation roots apply soft top scroll-edge
styling; visionOS keeps its supported native treatment. Explore's navigation
background stays transparent. Trip Map extends its map background while controls
and attribution retain safe areas. Place/directions use native Close roles. Compact
directions has a 32-point sheet corner radius; expanded sheets retain system
radius, background, grabber, and gestures. Styling a scroll edge does not verify
a map canvas's header appearance.

Library rows separate title, date range, and saved-place counts, with artwork
stacking at accessibility sizes. Forms explain validation and can expand while
typing. Filters describe active categories and loaded counts. Keep short, direct,
sentence-case app copy and native product/menu conventions. Name the action:
Save to trip, Show in Explore, Open in Maps. Empty states suggest the next step;
errors explain the problem and recovery. Preserve deletion consequences, sample
labels, attribution, and route/AI limits. Localize whole messages and count forms;
do not assemble sentences from fragments. See [Localization](Localization.md).

## Enforcement and review

`check_design_system.py`, included in the source gate, checks scoped literal
spacing/fonts/colors/motion, colored warnings, repeated custom animations, shared
spacing, and palette variants/reference contrast. Geometry exceptions belong in
`scripts/design_system_policy.json` with a path, rule, reason, and current code
anchors. Unused exceptions fail; new ones require design review rather than a lint
bypass. Preview-only geometry is excluded.

This bounded source check is not a type checker or accessibility certification.
It cannot establish materials, clipping, spoken navigation, gesture behavior, or
animation pacing. Use the [visual review workflow](DesignConsistencyReview.md)
to assess those behaviors in the affected screen and adjacent flows.

For a UI change, identify affected roles and explain component/token choices.
Use named local previews in their real container for relevant long text, narrow
width, dark appearance, and accessibility sizes. When runtime review is in scope,
check light/dark/increased contrast, Reduce Motion/Transparency, VoiceOver, rapid
changes, and dismissal. Report source, compilation, and visual/device evidence
separately.

Framework references: [typography](https://developer.apple.com/design/human-interface-guidelines/typography),
[motion](https://developer.apple.com/design/human-interface-guidelines/motion),
[accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility),
[scroll edges](https://developer.apple.com/documentation/swiftui/view/scrolledgeeffectstyle(_:for:)),
[background extension](https://developer.apple.com/documentation/swiftui/view/backgroundextensioneffect()),
[button sizing](https://developer.apple.com/documentation/swiftui/buttonsizing), and
[Close role](https://developer.apple.com/documentation/swiftui/buttonrole/close).
Trip's exact tokens are project decisions, not numerical values prescribed by Apple.
