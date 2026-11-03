# Native skill application to Trip

## Scope and user benefit

Apply the global `app-development` guidance to Trip's existing travel workflows.
Improve reliable planning and recovery in Explore, Trips,
directions, and external navigation. Existing module boundaries, service injection,
native controls, and local fixtures provide the implementation foundation.

## Findings and changes

| User task | Source finding | Improvement | Acceptance case |
| --- | --- | --- | --- |
| Find and open a place | Dismissing autocomplete left suggestion resolution active | Cancel and invalidate the obsolete lookup; observe loading state | Dismiss during resolution; no late sheet or camera movement |
| Recover from search trouble | Retry retained the prior resolution error; submitted search was hidden in some suggestion states | Clear retry state and expose Search places | Fail a suggestion, retry, or submit the typed query |
| Edit a trip or plan a day | Several draft sheets could discard changes on cancellation or swipe | Change-aware discard confirmation and protected dismissal | Keep or discard changed settings, schedules, visit timing, and day ordering |
| Retry library loading | Loading state was excluded from Observation | Show progress and prevent repeated retry taps | Retry a failed load; progress becomes visible until completion |
| Open a trip from another surface | Some launch paths cleared the current edit or selection; older links could override newer navigation | Guard navigation before and after async loading; cancel superseded links; preserve drafts and expose app-owned failure feedback | Open a trip link or either New Trip shortcut while editing; select Explore during link loading |
| Choose and follow a route | Searched origins were absent from annotation exclusions; steps fragmented assistive reading | Include all route markers in exclusions; combine each instruction and name route choices | Inspect marker overlap and read route alternatives/steps with VoiceOver |
| Continue in Maps | Failure belonged to the underlying sheet; callbacks could outlive a journey | Scope feedback to its initiating presentation and reject stale completions | Fail handoff from route overview and Steps; replace journey before completion |

## Guidance applied

The relevant global topics are feature delivery, state ownership, cancellation,
native interface decisions, presentation lifecycle, accessibility, map behavior,
previews, and finding quality. Trip's VCM, map, routing, and preview contracts supply
local adoption details. No missing reusable skill has been demonstrated by this
pass; these changes use the existing unified topics.

Source ownership, package dependencies, persistence revision handling, scene-local
navigation, and system projection boundaries were reviewed as integration context.
No new app test target or framework is required for the selected improvements.

## Verification

The starting source gate passed: six package modules, 818 Swift files, 4009 members,
228 view files, and 19 project skill files. This establishes the source baseline.
The final source gate passed: six package modules, 825 Swift files, 4026 members,
229 view files, and 19 project skill files. Architecture and context references,
localization consistency, native-framework restrictions, previews, physical line
limits, and diff whitespace passed. The diff contains no shared design or asset
changes. The new reusable dismissal protocol is an app-owned
implementation detail; it adds no package dependency or skill entrypoint.

Independent source review found and corrected three integration defects: missing
trip errors without a visible presentation, a second New Trip shortcut bypassing
the command guard, and delayed links overriding newer navigation. Model guards,
app-owned feedback, and pending-link cancellation now cover those paths.

The user selected **source-only verification** for this delivery. No app/package
build, benchmark, automated test, Simulator interaction, or visual/device check was
run. Dismissal overloads were inspected in the installed iOS 27.2 SDK; local previews
cover loading, failure, discard choices, larger text, dark appearance, and rejected
Maps launches. Those previews were authored, not rendered. The acceptance cases
above remain runtime verification work and are not claimed as observed behavior.
