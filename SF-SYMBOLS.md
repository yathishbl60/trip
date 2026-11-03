# SF Symbols in Trip

Use symbols consistently across Explore, Trips, directions and system surfaces.
The source mappings and their local previews are authoritative; avoid maintaining
a second inventory of every literal name or occurrence count in documentation.

## Ownership

- Place categories: `trip/Shared/Places` and category previews.
- Shared styling and replacement transitions: `trip/DesignSystem`.
- Travel modes and route controls: `Packages/TripKit/Sources/TripRouting`.
- Widget and activity content: `TripWidgets` and `trip/Shared/System`.

## Selection and rendering

Choose a familiar symbol that describes the action or content. Reuse an existing
mapping for directions, collections, duplication, trip navigation, and categories.
Use base names where native controls choose variants; compact map artwork requests
filled monochrome symbols for legibility. Keep the semantic category palette
consistent with [shared presentation](docs/DesignSystem.md).

Preserve text labels, VoiceOver labels, selected traits and checkmarks. Color or
an unfamiliar glyph alone must not communicate state. `TripSymbolReplacement`
respects Reduce Motion and retains view identity. Avoid repeating animation on
map annotations or adding a second progress indicator to existing native controls.

## Verify a change

Check each new name and API against the installed SDK/catalog and configured
platform minimums. Use the affected control's same-file preview, then request
runtime verification for clipping, contrast, replacement motion, large text and
accessibility. Source audits do not prove a symbol renders on every platform.
