# Trip visual and interaction contracts

Use global `app-development` HIG, accessibility, motion, and runtime-review topics for general practice.
This reference records Trip's product choices; a framework modernization does not authorize a redesign.

## Navigation and canvases

- Preserve Explore and Trips entry points, screen hierarchy, and existing contextual actions.
- AppShellView applies soft top scroll edges on iOS, including pushed destinations and sheets.
- Standalone navigation roots retain that policy; unsupported visionOS styling stays guarded.
- Explore navigation remains transparent during loading, failure, and ready states.
- Keep secondary actions in existing menus/toolbars; no persistent chip rails, gesture panels, or scattered canvas buttons.
- Place details use focused native sheets with their established detents and scrolling.
- Closing details uses the Close role; confirmation placement commits changes.
- Compact directions retain gently rounded native corners; expanded sheets restore automatic corners.
- Preserve map controls and attribution; follow [map sheet contracts](../../trip-map-decluttering/references/directions-and-safe-areas.md).

## Domain interactions

- Selecting a dot promotes map zoom without replacing the marker identity; keep the three rendering stages.
- User gestures interrupt camera following; compatible content updates preserve camera intent.
- Save feedback must appear in the currently presented sheet; keep tabs and native controls clear.

Use [runtime flows](../../trip-previews-build/references/runtime-flows.md) for affected Trip acceptance paths.
