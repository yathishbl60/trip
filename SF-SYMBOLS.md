# SF Symbols audit

Audited on October 11, 2026 against [Apple’s SF Symbols guidance](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
and the installed SF Symbols catalog. API declarations were checked in Xcode beta’s
iOS 27.2 SDK against the project’s iOS and visionOS 27.0 deployment requirements.

The review covers Explore, Directions, Trips, shared presentation, previews,
widgets, Live Activities, and App Shortcuts.
It includes literal image names and computed symbol mapping accessors.

## Semantic changes

| Context | Previous | Choice | Reason |
| --- | --- | --- | --- |
| Attractions | `heart.fill` | `star` | A point of interest; avoids implying a favorite or saved state. |
| Entertainment | `star.tv.fill` | `theatermasks` | Represents venues and performances; the previous name is absent from the installed catalog. |
| Shopping | `cart.fill` | `bag` | Covers general retail rather than groceries or checkout. |
| Directions | `arrow.turn.up.right` in Explore | `arrow.triangle.turn.up.right.diamond` throughout | Uses the same directions sign in Explore and Trips. |
| Collections | Mixed `bookmark` and `square.stack` | `square.stack` | A consistent grouping metaphor in navigation and save destinations. |
| Stop ordering | `arrow.triangle.branch` | `list.number` | Indicates an ordered itinerary; branching remains appropriate for alternative routing. |
| New window | `macwindow.badge.plus` | `rectangle.badge.plus` | Avoids desktop window chrome in iPad and visionOS controls. |
| Duplicate trip | `plus.square.on.square` | `square.on.square` | Indicates copying an existing trip. |
| First-trip prompt | `bookmark` | `suitcase.rolling` | Matches the Trips destination. |
| Internal place details | `arrow.up.right` | `chevron.right` | Matches internal navigation rather than an external destination. |
| Satellite style | `globe.americas` | `globe` | Works without implying a particular geographic region. |

Place categories and driving/transit modes now expose base names. Native controls
can choose their context-appropriate variants. Small map glyphs and photo badges
explicitly request filled, monochrome rendering for a clear silhouette.

## Rendering and interaction

| Capability | Use or decision |
| --- | --- |
| Outline/fill variants | Native controls choose variants from base names; compact map artwork uses `.symbolVariant(.fill)`. |
| Monochrome | Explicit on compact map artwork to retain contrast at small sizes. |
| Hierarchical | Category artwork in the trip library and checklist completion symbols use the symbol’s layer hierarchy. Single-layer fallback symbols retain their ordinary appearance. |
| Palette | Confirmation checkmarks use a primary foreground and a subtle accent enclosure, while confirmation text remains legible. |
| Gradient | The large first-trip empty-state suitcase uses native `.symbolColorRenderingMode(.gradient)` for depth. |
| Magic Replace | Checklist completion, category filters, and filter status use a shared native replacement transition scoped to the changing value. |
| Draw On / Draw Off | Supported related symbols receive the system’s Draw enhancements through Magic Replace. There is no extra draw animation stacked on top. |
| Variable color / variable draw | Reviewed; existing `ProgressView` and `Gauge` controls already communicate real journey progress. No arbitrary variable values or duplicate meters were added. |
| Multicolor | Reviewed; category identity comes from the existing app palette, while toolbar and widget symbols retain native contextual rendering. |
| Bounce / wiggle / pulse / breathe / rotate | Reviewed; these interfaces have native progress indicators and feedback, so additional repeating effects would not communicate new information. |

`TripSymbolReplacement` reads `accessibilityReduceMotion` directly and uses an
identity transition with no animation when enabled. It preserves the existing
view identity. Map annotations have no new per-marker animation or effects.
Selected category chips retain their checkmarks, including categories without a
fill variant, so selection does not depend on color alone.

Existing text labels, accessibility labels and selected traits provide meaning
beyond the glyph. Standard share, delete, search, edit, close, location, map,
calendar, checklist, contact and tracking symbols retain their familiar meanings.
Apple-product symbols were considered in context. This change retains generic
`sparkles` for itinerary generation and introduces no restricted Apple brand mark.

## Verification

- At the time of this audit, all 98 explicit symbol names and 241 literal references resolved in the installed catalog.
- Every name is available at or before iOS and visionOS 27.0.
- Native gradient and replacement APIs are supported by the installed SDK and deployment targets.
- `bash scripts/check.sh` validates architecture, source/member/skill line limits, previews, forbidden UIKit and whitespace.
- Named previews cover all category badges, all compact category glyphs, and interactive replacement with Reduce Motion enabled and disabled.
- No app build, benchmark, Canvas rendering or device animation verification was performed.

The audit-time catalog reference inventory follows. Counts include declarations and previews;
computed mappings are counted where each literal is defined rather than at every
runtime use. Dynamic consumers resolve through the reviewed mapping accessors.

<!-- symbol-inventory -->

| Symbol | iOS since | visionOS since | Literal references |
| --- | --- | --- | --- |
| `arrow.clockwise` | 13.0 | 1.0 | 4 |
| `arrow.counterclockwise` | 13.0 | 1.0 | 2 |
| `arrow.down` | 13.0 | 1.0 | 1 |
| `arrow.triangle.branch` | 14.0 | 1.0 | 1 |
| `arrow.triangle.turn.up.right.diamond` | 14.0 | 1.0 | 4 |
| `arrow.up` | 13.0 | 1.0 | 1 |
| `arrow.up.arrow.down` | 13.0 | 1.0 | 1 |
| `arrow.up.forward.app` | 14.0 | 1.0 | 2 |
| `arrow.up.left.and.arrow.down.right` | 13.0 | 1.0 | 1 |
| `arrow.uturn.backward` | 14.0 | 1.0 | 1 |
| `bag` | 13.0 | 1.0 | 1 |
| `bed.double` | 13.0 | 1.0 | 1 |
| `bicycle` | 14.0 | 1.0 | 1 |
| `binoculars` | 14.0 | 1.0 | 2 |
| `book.closed` | 14.0 | 1.0 | 2 |
| `bookmark` | 13.0 | 1.0 | 7 |
| `brain` | 15.0 | 1.0 | 1 |
| `building.columns` | 14.0 | 1.0 | 1 |
| `calendar` | 13.0 | 1.0 | 5 |
| `calendar.badge.exclamationmark` | 14.0 | 1.0 | 1 |
| `calendar.badge.plus` | 13.0 | 1.0 | 1 |
| `car` | 13.1 | 1.0 | 1 |
| `car.side` | 16.1 | 1.0 | 1 |
| `checklist` | 15.0 | 1.0 | 3 |
| `checkmark` | 13.0 | 1.0 | 7 |
| `checkmark.circle` | 13.0 | 1.0 | 4 |
| `checkmark.circle.fill` | 13.0 | 1.0 | 8 |
| `chevron.right` | 13.0 | 1.0 | 2 |
| `circle` | 13.0 | 1.0 | 4 |
| `circle.hexagongrid` | 15.0 | 1.0 | 1 |
| `clock` | 13.0 | 1.0 | 1 |
| `cube` | 13.0 | 1.0 | 3 |
| `cube.transparent` | 14.0 | 1.0 | 1 |
| `cup.and.saucer` | 15.0 | 1.0 | 1 |
| `dollarsign.circle.fill` | 13.0 | 1.0 | 1 |
| `drop` | 14.0 | 1.0 | 1 |
| `ellipsis` | 13.0 | 1.0 | 5 |
| `ellipsis.circle` | 13.0 | 1.0 | 1 |
| `exclamationmark.arrow.trianglehead.2.clockwise.rotate.90` | 18.0 | 2.0 | 1 |
| `exclamationmark.triangle` | 13.0 | 1.0 | 1 |
| `externaldrive.badge.exclamationmark` | 16.0 | 1.0 | 1 |
| `eye` | 13.0 | 1.0 | 1 |
| `eye.slash` | 13.0 | 1.0 | 1 |
| `figure.2` | 17.0 | 1.0 | 1 |
| `figure.arms.open` | 16.0 | 1.0 | 1 |
| `figure.stand` | 14.0 | 1.0 | 3 |
| `figure.strengthtraining.traditional` | 16.0 | 1.0 | 1 |
| `figure.walk` | 14.0 | 1.0 | 3 |
| `fork.knife` | 15.0 | 1.0 | 2 |
| `globe` | 13.0 | 1.0 | 3 |
| `hand.draw` | 13.0 | 1.0 | 2 |
| `heart` | 13.0 | 1.0 | 1 |
| `info.circle` | 13.0 | 1.0 | 7 |
| `line.3.horizontal.decrease` | 15.0 | 1.0 | 2 |
| `line.3.horizontal.decrease.circle.fill` | 15.0 | 1.0 | 1 |
| `list.bullet` | 13.0 | 1.0 | 5 |
| `list.number` | 13.0 | 1.0 | 2 |
| `location.fill` | 13.0 | 1.0 | 2 |
| `location.north.line` | 13.0 | 1.0 | 1 |
| `lungs` | 14.0 | 1.0 | 1 |
| `magnifyingglass` | 13.0 | 1.0 | 4 |
| `map` | 13.0 | 1.0 | 15 |
| `mappin` | 13.0 | 1.0 | 1 |
| `mappin.and.ellipse` | 13.0 | 1.0 | 7 |
| `minus` | 13.0 | 1.0 | 1 |
| `note.text` | 14.0 | 1.0 | 1 |
| `pencil` | 13.0 | 1.0 | 4 |
| `phone` | 13.0 | 1.0 | 2 |
| `plus` | 13.0 | 1.0 | 8 |
| `plus.circle` | 13.0 | 1.0 | 1 |
| `plus.circle.fill` | 13.0 | 1.0 | 2 |
| `plus.magnifyingglass` | 13.0 | 1.0 | 1 |
| `rectangle.badge.plus` | 14.0 | 1.0 | 1 |
| `scope` | 13.0 | 1.0 | 1 |
| `slider.horizontal.3` | 13.0 | 1.0 | 1 |
| `sparkle.magnifyingglass` | 15.0 | 1.0 | 3 |
| `sparkles` | 13.0 | 1.0 | 5 |
| `square.3.layers.3d` | 16.0 | 1.0 | 1 |
| `square.and.arrow.up` | 13.0 | 1.0 | 2 |
| `square.dashed.inset.filled` | 15.0 | 1.0 | 1 |
| `square.grid.2x2` | 13.0 | 1.0 | 2 |
| `square.on.square` | 13.0 | 1.0 | 1 |
| `square.stack` | 13.0 | 1.0 | 6 |
| `square.stack.3d.up` | 13.0 | 1.0 | 1 |
| `star` | 13.0 | 1.0 | 1 |
| `star.fill` | 13.0 | 1.0 | 2 |
| `stop.circle` | 13.0 | 1.0 | 2 |
| `suitcase.rolling` | 16.1 | 1.0 | 18 |
| `suitcase.rolling.fill` | 16.1 | 1.0 | 3 |
| `text.badge.plus` | 13.0 | 1.0 | 1 |
| `theatermasks` | 15.0 | 1.0 | 1 |
| `tram` | 14.0 | 1.0 | 1 |
| `trash` | 13.0 | 1.0 | 4 |
| `tree` | 16.1 | 1.0 | 1 |
| `viewfinder` | 13.0 | 1.0 | 2 |
| `wineglass` | 16.0 | 1.0 | 1 |
| `xmark` | 13.0 | 1.0 | 2 |
| `xmark.circle` | 13.0 | 1.0 | 1 |
