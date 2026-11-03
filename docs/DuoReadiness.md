# Adaptive interface pass — 2026-10-26

## Navigation correction — 2026-11-01

The running iPhone Duo on iOS 27.2 lost both app tabs on its open display while
Trips retained its library sidebar. iPhone now requests native tab-bar placement;
iPadOS and visionOS keep their sidebar preference. Ordinary scene restoration
preserves the saved tab, and reopening the same trip reveals its compact detail
without clearing drafts or nested navigation. Local shell previews cover the tab
bar beside split navigation and Explore with a retained trip selection.

The iOS Debug command-line build succeeded, including widgets, without compiler
warnings. The final source also built and launched through the existing Xcode
Duo scheme. Source architecture, workspace, skill, SwiftSyntax and whitespace
checks passed. The full source gate remains blocked by the pre-existing extra
` Weather` entry in the generated host localization catalog.

Runtime checks verified both tabs and switching in closed, open and partially
folded poses, plus opening Duo with New Trip presented and cancelling the sheet.
Saved-trip Back, same-trip reopening and restoration with a selected UUID remain
unverified. Accessibility sizes, other orientations, iPadOS and visionOS were not
runtime-tested in this correction.

During verification, installing the unsigned command-line build removed the
simulator's previous App Group container. Relaunching the signed Xcode build
created an empty group; the prior saved trip was no longer available. Read-only
checks found no recoverable store, deleted container or local snapshot. This was
a verification installation failure, not evidence that trip persistence passed.
Use the existing signed Xcode scheme for runtime checks; the unsigned build
script output is for compilation verification only.

## Scope and verification

This pass uses the supplied `iphone-duo-skills-main` guidance and Trip's existing
SwiftUI architecture. The initial scope was **source changes and previews only**;
the subsequent build-error report requested compilation and repair.
Previews below are authored configurations, not evidence of rendered device results.
No benchmark, Simulator UI session, or device verification was run for this pass.

The subsequent `bash scripts/build.sh app Debug` completed successfully using
Xcode 27.2 and the generic iOS Simulator destination, with signing disabled.
The app, widget extension, and App Intents processing completed without compiler
warnings. `bash scripts/check.sh` passed after the fixes. Logs are retained in
`.build/adaptive-build-fix.log` and `.build/adaptive-build-fix-audit.log`.
This result does not verify the updated visionOS configuration or rendered UI.

All 11 supplied skills were installed or updated under `~/.codex/skills`, including
their licenses and three shared reference documents. Relative reference links were
adjusted for standalone installation; the remaining contents match the source.
Previous global versions are retained under
`~/.codex/skill-backups/iphone-duo-20261026-081333`.

## Screen coverage

| Flow | Source review and changes |
| --- | --- |
| App navigation | Native adaptable tabs explicitly prefer sidebar placement using the separate iPhone/visionOS and iPadOS APIs. Retain trip split navigation and per-window state. Add short-window, wide-sidebar, large-type, right-to-left shell previews. |
| Explore map and search | Retain native map controls, continuous map, reserved-region collision/framing values, and searchable navigation. Prioritize the existing previous-area toolbar action. |
| Place details and filters | Use semantic cancellation placement for detail dismissal. Filters join existing native form-sized sheets; add short-window accessibility preview. Existing place action stacking remains. |
| Photo gallery | Preserve zoom and the viewed image position on resize, clamp to the new viewport, and suppress stale active gesture translations until release. Keep toolbar title/count horizontal and remove the axis-dependent toolbar spacer. Add short-window previews. |
| Trip library and itinerary | Retain native split navigation, stable selection, and list-based editing. Integrate secondary actions into ToolbarOverflowMenu so constrained bars have one system-managed overflow. Add compact accessibility editor preview. |
| Trip map | Replace nested ArrangementView with stable AnyLayout panes. An active division supplies the gap and pane lengths; other windows use their live shape. Keep both map and stop list available. Day selector stays horizontal. |
| Trip editing and assistant | Add native form presentation sizing to existing sheets. Preserve drafts, validation, Save/Cancel behavior, async ownership, and availability states. |
| Trip checklist, collections, schedule, today, packing | Retain existing native scrollable lists/forms and contextual navigation. No extra pose controls or decorative effects. |
| Directions | Retain adaptive expanded sheet content. Move options and close to semantic primary/cancellation placements. |
| Widgets and system integrations | Retain native family/platform layouts and existing integration entry points; no changes needed for the app-window toolbar/pane fixes. |

## Layout and motion contracts

- Use current container geometry, not device names or orientation tables.
- Do not nest a collapsing arrangement inside the trip navigation split view.
- Division frames already include system margins. Pane layout uses logical layout
  coordinates; the existing continuous map keeps its physical reserved-region handling.
- Synthetic book/tabletop previews inject division rectangles into TripMapLayout;
  they do not simulate system pose changes or prove hardware occlusion behavior.
- Keep map/stop-list identity stable through AnyLayout changes. Resize geometry is
  applied directly, without an extra animation chasing a live window resize.
- Preserve existing Reduce Motion-aware gallery and annotation animations. Do not
  add hinge-linked decoration or animate map projection during user gestures.
- Reduce Motion is a read-only SwiftUI environment value. Verify it using system
  accessibility settings rather than attempting a writable environment override.
- Keep controls native and progressively disclosed; avoid forced toolbar axes.
- Cross-platform web frameworks, camera capture, and game-specific skills are
  installed for reuse but do not justify new dependencies or features in Trip.

## Follow-up verification when requested

Run `bash scripts/check.sh` for source limits, previews, architecture, and localization.
Build iOS and visionOS separately using the commands in `UNIVERSAL-APP.md`.
Visually inspect short/wide/narrow windows, asymmetric safe areas, both layout
directions, large text, Reduce Motion, and active fold/occlusion changes.
During resizing, check selected trip/stop continuity, map gestures and attribution,
gallery pinch/pan cancellation and paging, sheet dismissal, text-entry drafts,
and keyboard access. Runtime smoothness and actual poses remain unverified.
