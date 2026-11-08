# Review visual consistency

Use this workflow for changes to existing Trip screens, shared components,
directions, widgets, and Live Activities. Start from the user task and the
[design-system contract](DesignSystem.md); a review does not authorize a redesign.
For framework techniques, use the relevant topics in the global app-development
skill through [Skills](Skills.md).

## Locate the owner and adjacent surfaces

1. Identify the changed view, its controller/model, and the token or component it
   consumes. Use `python3 scripts/workspace.py locate <source-path> --json`.
2. Read the owning guide and inspect the current container: native list/form,
   sheet, map overlay, sidebar, widget, or activity. Preserve its navigation.
3. Find consumers of a shared change. Include app, routing, and extension surfaces
   without introducing dependencies between them merely to share presentation.
4. Choose local fixtures that expose long content, empty/loading/error states,
   large text, selection, and the smallest supported container.

## Review the relationships

| Area | Check | Trip owner or rule |
| --- | --- | --- |
| Spacing | Similar title/metadata and row relationships use the same scale; fixed map geometry stays intentional | Design-system spacing; documented geometry exceptions |
| Place identity | Title, category, address, and selected state stay recognizable across saving, search, and detail | Reuse `TripPlaceLabel` where it fits the same task |
| Typography | Long text wraps or truncates intentionally; it does not shrink to hide layout problems | Semantic text roles; headline identity and secondary metadata |
| Symbols and numbers | Badges grow with their text; color is not the only state cue | Scaled symbol tiles and itinerary/directions badges |
| Narrow and accessibility layouts | Columns become flexible or stack; counts/actions remain associated with their content | Category choices, place rows, and activity footers |
| Warnings and recovery | Explain the issue and next action without inventing competing error styling | `TripWarningLabel`; native destructive roles for Delete |
| Motion | The smallest owning view animates the changed value; background work does not inherit broad transactions | Shared motion recipes and explicit Reduce Motion behavior |
| Palette | Semantic colors remain legible in every catalog variant and over the actual surface | Adaptive palette; distinguish reference contrast from rendered materials |
| Native interaction | Toolbars, sheets, forms, gestures, and dismissal remain predictable | Existing platform presentation and feature owner |

A geometry exception is a reasoned product decision, not a substitute for using
an existing spacing or text token. Map glyph/caption dimensions and collision
clearance belong to the map contract; ordinary content must not copy them.

## Exercise the interaction when runtime review is requested

- Compare compact, wide, short, and accessibility-size layouts in their real
  containers. Include long localized names and empty or partially available data.
- Check light/dark appearance, increased contrast, Reduce Transparency, and
  readability over map tiles, images, and materials.
- Use VoiceOver and keyboard/focus navigation. Confirm labels, selected traits,
  action order, touch targets, and equivalent actions for gesture-only flows.
- Toggle Reduce Motion, repeat selection changes, and dismiss during an update.
  Inspect replacement motion on the symbol rather than the whole row/control.
- Revisit adjacent save/edit/cancel/delete, map gestures, sheet resizing, and
  navigation flows. A shared component change can affect all of them.

## Check and describe the change

Run `python3 scripts/check_design_system.py` for the focused source policy, or
`bash scripts/check.sh` for the complete source gate. Keep geometry exceptions in
`scripts/design_system_policy.json` with a current anchor and a concrete reason.
Do not add broad exclusions to make a local layout pass.

Use the requested build/runtime scope from [Contributing](../CONTRIBUTING.md).
Record affected components, fixtures, exercised cases, and unresolved behavior in
the change description. Source checks establish policy compliance; compilation
and rendered interaction checks answer different questions.
