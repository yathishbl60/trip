# UI correction review · 2026-10-18

The earlier source-only layout pass changed too much without rendered evidence.
This review reduces the diff and restores the established design before further
UI work. It does not claim that all screens are visually verified.

## Changes backed out

- Restored shared icon tile sizes, place-label layout, and save-row typography.
- Restored native date/time pickers and steppers, their existing labels, bindings,
  calendars, ranges, and form placement.
- Restored itinerary rails, numbered rows, shortcut button alignment/columns,
  tracking/loading control spacing, and collection badges.
- Restored complete Siri briefing times/items, widget trip identity and departure
  details, and Live Activity context. Removed the content-reducing alternatives.
- Restored route instruction rows. Removed the generic adaptive wrappers and
  their dependent helper files.

38 tracked files were restored to the pre-review baseline before applying the
focused corrections below. Sixteen superseded helper files were moved into
`.build/ui-review-before-correction` with a recoverable copy of the earlier diff.
That directory is ignored and is not part of the delivered app.

## Focused corrections retained

| Area | Source issue | Correction |
| --- | --- | --- |
| Day header | Menu title can compete with date/title text | Explicit ellipsis label with native-sized target and full accessibility label; text can use its intrinsic height |
| Trip statistics and order distances | Width-fitting containers in List rows can negotiate unwanted dimensions | Replace statistic fitting with wrapping text; use content-sized horizontal/vertical distance layouts |
| Category filters | Count and selection compete with the category name at accessibility sizes | Keep the standard count badge; move the count below the name at accessibility sizes and preserve the selection indicator |
| Map search | A secondary Save label competes with the result title/address | Bookmark action with an explicit target and a full accessibility label |
| Checklist | Long item titles can lose vertical space | Allow the title to use its intrinsic height |
| Time-zone search | Unmatched queries leave an unexplained blank list | Native search empty state and selected-row accessibility trait |
| Stop-order/travel-mode selection | Segments can constrain large labels | Use native menus at accessibility sizes |
| Route-options/structure sheets | Medium height is cramped at accessibility sizes | Offer the large detent at those sizes |

## Verification

- Source architecture, source-size limits, same-file previews, and whitespace are
  checked with `bash scripts/check.sh`.
- Corrected native controls and system-content files are compared directly with
  commit `c999080`; their prior unverified redesign is removed.
- After the October 18 error-fix request, the Debug iOS Simulator build passed
  for the app and widget extension. A missing TripDomain import in the app preview
  was corrected. Rendered comparisons and interaction checks remain pending.
- Following Simulator authorization, the running app was inspected on iPhone 18
  Pro Max with iOS 27.2. Exact manual coverage and evidence are recorded below.
- Preview definitions are review cases, not evidence that they compile or render.

This focused review does not verify the whole app or every supported platform.
Further changes should follow rendered evidence, preserving information, native
controls, and existing flows.

## Device screenshots · October 18

The supplied images show actual failures: IMG_2027 has an excessively tall summary,
missing count text, and a stretched Find places capsule; IMG_2028 shows an empty
rounded row above Day 1; IMG_2029 shows a route card with excessive empty space
and the word Tolls split across lines. These observations supersede the earlier
source-only assessment of layout quality.

- Removed width-fitting measurement from the overview, journey controls, route
  summary, and adjacent stop-order summary. Content rows keep their intrinsic
  vertical height; map previews retain their explicit 180-point height.
- The trip overview displays dates and all day/place/event counts as wrapping
  text. Empty trips omit the journey-preview row; their day actions remain.
- Moved the periodic clock outside the itinerary List. The Today section now
  exists only when there is a Today destination, avoiding an opaque clock view
  that contributes a row even when its content is empty.
- Route duration, ETA, distance, route label, and toll information get the full
  row width, with Steps/Open in Maps below. Native actions keep their text labels.
- Added local preview definitions for the supplied three-day empty trip and a
  17-minute toll route with a menu of alternatives. Cases use real List/sheet
  containers, dark appearance, compact widths, and accessibility text sizes.

Source audits check architecture, syntax/line limits, preview presence, and
whitespace. They do not prove the rendered fix. The current Debug iOS Simulator
build succeeds, including the screenshot corrections. Simulator appearance and
interactions are covered below; physical-device behavior is separate.

## Simulator review · October 18

Configuration: iPhone 18 Pro Max, iOS 27.2, current Debug app build. The widget
extension compiled with the app. The simulator started in light appearance with
standard large text; both settings were restored after dark and accessibility
checks. Existing simulator trips were preserved.

Observed clutter drove these additional changes:

- Moved Map, Checklist, and Collections into the existing Trip options menu.
  AI planning already had a menu entry; the four-button overview grid is removed.
  Empty trips omit Map because there are no mapped itinerary places.
- Removed the repeated Find more places footer. Each day opens place search in
  one tap; its adjacent calendar menu contains event types.
- Hide Today when a current day has no commitments, retaining zone-review and
  meaningful current-day entries. Trip summary and actual day actions stay visible.
- Search shows the destination date once, followed by count and geographic
  context. Empty unscoped search no longer repeats its placeholder in a second
  card. Nearby suggestions have short labels and loading uses one compact row.
- Result titles and addresses use primary/secondary text contrast, with accent
  reserved for the Add indicator. The preview button uses the existing accessible
  AccentFill color in dark appearance.
- Moved feedback overlays into tab content. A checklist success message was
  visibly verified above the tab bar instead of covering its labels.
- Zero-distance route instructions omit the redundant 0 cm label; instructions
  themselves remain available.

| Manual scenario | Observed result |
| --- | --- |
| Create/edit Bangkok Weekend | Title/date saved; trip remained available after reinstall and relaunch |
| Day 1 live Maps search | Grand Palace and Wat Pho added; duplicate result disabled with checkmark |
| Day 2 discovery | Coffee suggestion queried Maps; MiVana Coffee saved to Day 2 |
| Undo after destination change | Copied Wat Pho to Day 2, switched to Day 1, undid; Day 1 retained two places and Day 2 returned to zero |
| Three-day Weekend Draft, October 22–24 | Compact summary, three day actions, no empty Today row or preview card; no stretched controls |
| Dark and accessibility-large text | Summary, day actions, and search destination remained readable and scrollable |
| Replay Day 1 | Playback advanced from Grand Palace to Wat Pho; Finish retained the current map selection |
| Live day directions | Route alternatives, ETA/distance, and readable Steps action; instruction sheet opened |
| Relocated checklist | Opened from Trip options, added five essentials; feedback stayed clear of the tab bar |
| Final search footer | Place count and Search near Wat Pho both visibly present |

Local screenshots are saved under the ignored `.build/ui-review` directory:
`empty-trip-dark.png`, `populated-trip-dark.png`, `search-light.png`, and
`empty-accessibility-dark.png`. Source checks and the Debug simulator build pass
without compiler warnings or errors. No benchmark was run for these UI changes.

Not exercised: physical devices, iPad/visionOS/Duo poses, VoiceOver interaction,
AI generation, event creation, or signed widget/Live Activity behavior. Accessibility
labels were inspected through the simulator accessibility tree. Simulator coverage
does not establish those untested results.

## Explore map review · October 18

Same Simulator configuration as the trip review above. Cold launch originally
showed one central hotel marker: the nearby API filled its response with tightly
clustered coordinates, while the native base map deliberately hid Apple's POIs.
The fix supplements concentrated/empty discovery once with a region-constrained
Maps search. Repeated launch checks showed places distributed across the map.
No preview/sample places were inserted into the live catalog.

Additional UI changes remove the duplicate Filters summary and Reset control,
retain All categories as the reset action, shorten the search prompt, use
primary/secondary result text, and avoid duplicate loading notices. Search this
area is available from the existing menu whenever idle; status notices offer
Retry. A successful save from an open place sheet now confirms inside that sheet.

The established native map-control host is retained. An attempted measured
control overlay caused runtime regressions and was withdrawn; it is not part of
the delivered fix. The project skills now require adjacent search/projection
checks before retaining native control or map-scope changes.

Manual checks covered populated cold launch, café filtering, clearing filters,
real restaurant/café search, dot selection and its zoom into labeled details,
selected-marker framing above the sheet, and saving to Bangkok Weekend Day 2.
The sample trip now has five saved places. Dark appearance and accessibility-large
text were inspected, including the complete short search prompt and scrollable
search results. The save confirmation was visibly present in the detail sheet.

The final Debug simulator build restores the original native control host, includes
the widget extension, and passes without compiler warnings/errors. Architecture,
source-size, and the two revised project-skill validators also pass. The final
Simulator relaunch was declined, so the interaction evidence above belongs to
earlier builds of the retained improvements, not a complete final-revision pass.
Simulator appearance restoration was also declined; dark appearance and
accessibility-large text remain from testing. No further device actions were taken.
Physical-device location fixes, VoiceOver operation, iPad/visionOS/Duo layouts,
network-outage injection, and measured gesture/frame-pacing benchmarks were not
exercised. The existing location permission state was preserved.

## Compact map status and controls · October 19

The status bubble now uses a centered spinner/text row, one text line, and six
points of vertical surface padding. Error retry is the entire bubble with a small
refresh symbol; its minimum 44-point hit area sits outside the glass surface,
rather than inflating the visible row. Long messages truncate visually while
VoiceOver receives the complete message. Transient notice typography is capped at
xxxLarge; place content and detail sheets retain their existing Dynamic Type rules.
Native location/compass controls explicitly request regular control size in the
original automatic MapKit host. No map scope or camera logic changed.

Same-file previews cover loading, error/retry, dark appearance, accessibility text,
and a narrow 280-point error row. Architecture/source-size audits pass. This is a
source/preview-definition review; the revised appearance has not been rendered or
checked in Simulator, and compilation was not rerun for these layout-only edits.

## Removal of day preview and autoplay · October 19

Removed the prominent itinerary preview card and the complete replay/player
flow, including its timer, navigation destination, controller/model state, and
feature-specific preview fixtures. The ordinary map and shared journey-event
fixtures remain. Trip options and the existing day menu still open the day map;
its day picker, numbered pins, tappable stop list, fit action, and directions are
preserved. Overview previews are now local and no longer load map tiles.

Architecture/source-size/whitespace audits pass, and a source reference scan found
no remaining replay or preview-day hooks in the Trips feature. Compilation and
Simulator interaction were not rerun for this removal; earlier replay screenshots
and manual checks in this document are historical, not current UI behavior.

## Day map cleanup · October 19

Pin selection now requests scrolling to the matching named stop, without inserting
a selected-place section. Row selection recenters using the last native camera,
preserving zoom, heading, and pitch. Native camera feedback is unobserved to avoid
rebuilding the stop list during gestures. Coordinate/identity changes invalidate
framing; text and order changes preserve it.

Directions remains in a pinned day/date header while stops scroll. Show in Explore
and Share use a visible actions menu on each mapped stop row. Invalid locations stay named in the
list with an explanation. Empty days show one recovery message, and days without
any valid locations omit the map pane. Vertical layouts request a text-scaled list
height rather than a fixed map ratio. Native automatic map controls remain intact.

Local preview definitions cover twelve stops, distant pin selection, a long place
name, empty and missing-location days, compact widths, dark appearance, and
accessibility text. Architecture/source-size/whitespace audits pass. This is source
and preview-definition verification; compilation and Simulator rendering have not
been rerun for these changes. Pin-to-row scrolling, camera behavior, and adaptive
pane sizes still require runtime verification.

## Apple guidance consulted

- [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits)
