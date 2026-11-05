# Visual consistency review · 2026-11-05

Scope: source review of shared components, Explore filters/details/gallery/map
presentation, Trips library/editor/save/checklist/schedule/journey/assistant views,
reusable directions, Siri snippets, widgets, and Live Activities. The task is to
make existing planning and travel flows easier to read and more predictable.

| Finding | Change and reason |
| --- | --- |
| Similar row relationships used 2, 3, 4, or 6 point text gaps, with 10/12/14/16 point surrounding gaps | Adopt the existing 4/8/12/16/20 content scale; reserve 2 for compact artwork/system surfaces. Shared numerical checks keep routing/widgets aligned without app dependencies. |
| Save destinations duplicated place-row layout and used smaller metadata text | Reuse TripPlaceLabel with headline identity, secondary subheadline metadata, and the same title/subtitle gap. |
| Fixed symbol/number frames could become smaller than their scalable text | Scale symbol tiles, itinerary numbers, and direction step/picker badges relative to their semantic text role. Place labels stack at accessibility sizes. |
| A scaled minimum category-column width could exceed a narrow container | Use one flexible column at accessibility sizes, with counts below the title. Keep the existing glass selection animation inside the filter sheet. |
| Orange clock warnings and red error paragraphs differed from existing neutral schedule warnings | Reuse TripWarningLabel: primary text, an explanatory warning symbol, and wrapping. Native Delete roles stay destructive. |
| Similar completion/value changes used several slightly different timings | Centralize ordinary feedback at 0.2 seconds, selection/completion at 0.25, and custom press feedback at 0.16, all with explicit Reduce Motion handling. |
| Category symbol transition was applied to the whole button; the controller also opened a broad animation transaction | Scope replacement to the symbol and let the filter view own selection motion. Downstream map/search work no longer inherits the controller transaction. |
| Live Activity action buttons shared a horizontal row with large text | Stack the activity footer at accessibility sizes, keeping actions below its context. |
| Existing adaptive palette had no automated contrast/variant gate | Preserve the established palette and add checks for all appearance variants, solid reference contrast, 12% tint washes, and increasing contrast. |

## Preserved decisions

Explore/Trips navigation, native forms/toolbars/sheets, map annotation geometry,
camera timing, saved data, and existing contextual actions retain their owners.
This pass adds no screens or permanent map controls. Map glyph/caption sizing and
clearance remain documented geometry exceptions; ordinary content must not copy
those fixed sizes. Widgets retain their native compact hierarchy and rendering modes.

The palette itself did not need replacement: all 23 named colors meet the 4.5:1
reference threshold across light/dark and increased-contrast variants. The minimum
tested reference pair is 5.27:1. This does not measure translucent materials, imagery,
system surfaces, or the actual device's appearance.

## Verification boundary

- Source architecture, ownership, localization, preview presence, Swift file/member
  limits, skill limits, and the new design-policy gate are checked by `scripts/check.sh`.
- The source gate passed across 927 Swift files and 236 view files; its design-policy
  subset covered 654 Swift files and 23 adaptive colors. Isolated temporary fixtures
  confirmed rejection of fixed fonts, literal spacing/insets/colors/motion, colored
  warnings, repeated animation, missing palette variants, weak contrast, and spacing
  drift between targets. Native/tokenized styles and preview-only geometry passed.
- Deterministic previews were added or extended for narrow category choices, large
  symbols, save destinations, warning forms, routing search, and activity footers.
  Preview declarations have not been rendered in this pass.
- The final UI changes have not been compiled. Earlier successful iOS app and Siri
  evaluation-target builds predate this visual pass; the subsequent build request
  was declined, so no further build or app execution was performed.
- Runtime acceptance remains open for compact/wide iOS and visionOS layouts, actual
  materials, VoiceOver, increased contrast, Reduce Motion/Transparency, rapid changes,
  and navigation/dismissal. Source checks do not establish those outcomes.

Future changes follow [the shared visual contract](DesignSystem.md); AGENTS.md and
the development workflow point contributors to the same rules and source gate.
