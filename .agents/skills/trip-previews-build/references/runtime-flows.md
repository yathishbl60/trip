# Trip runtime acceptance paths

Use global `app-development` runtime-review for the review method and evidence boundaries.
Exercise the changed path and its affected neighbors when runtime verification is requested.

| Changed owner | Useful acceptance path |
| --- | --- |
| Explore | Cold launch → discovery → pan/zoom → select dot/place → details → dismiss/reselect |
| Search | Type completion → submit/select → clear → restore discovery; check no-results and retry |
| Save to Trip | Select map place → existing/new trip → save/cancel → inspect persisted destination |
| Trips | Create/open → edit/cancel/save → change selection; check another window deleting the trip |
| Directions | Choose origin/mode/stops → wait/retry → select route → resize sheet → gesture → Maps handoff |
| Planning/Today | Edit day/event/booking → save → reopen; retain destination calendar and occurrence choices |
| System surfaces | Resolve saved IDs → act → reload durable projection; deleted IDs must fail usefully |

For map changes also read [map regressions](../../trip-map-decluttering/references/launch-and-regression-review.md).
Keep Legal/control positions stable while sheets, keyboard, and safe areas change.
Verify saved-place actions in their actual List/sheet, not only an isolated row preview.
Check feedback inside the active save sheet and native Close/Cancel behavior.
Use independent preview stores; runtime checks preserve the user's existing trip data.
Report the actual configuration and any unexercised path; these cases are not claims of completed verification.
