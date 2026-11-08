# 0002: Focused workflows and request delivery

Status: accepted for implementation, 2026-11-08.

## Problem

Small files did not prevent Checklist views from receiving the entire Trips
controller, or App from coordinating individual feature workers. Navigation
requests and restoration also had different cancellation lifetimes.

## Decision

Keep VCM and existing package responsibilities. Compose a focused Checklist model and
controller, with the shared library as its durable-data boundary. Checklist owns
its naming draft and packing review. App receives semantic feature operations;
it does not configure a sequence of internal presentation flags.

Collections follows the same ownership rule: its model owns naming, deletion,
reordering, and saved-place edits. Session identities prevent stale dismissal or
confirmation from affecting a newer session. Root Trips retains cross-workflow
day scheduling and save-sheet dismissal through narrow callbacks. The shared stop
row receives a show-place action instead of the entire Trips controller.

Separate App screen destinations from workflow requests. Resolve ingress through
one scene-owned request generation. A newer user action invalidates older suspended
work, including restoration. Resolve canonical IDs and recheck draft protection
at delivery. The launch mailbox delivers once to an eligible foreground scene.

TripRouting continues to own geographic directions independently. Preserve its
generation, session, cancellation, geometry and host-publication contracts.

Extract `TripPlaces` as a bounded compiler pilot: native text search, MapKit item
conversion, and category filters serve both Explore and Trips through a small API.
It depends only on TripDomain and TripLocalization. App appearance/resources and
observable autocomplete state stay in Shared/Places. Full feature packages would
first need smaller shared UI, resource, preview, and host contracts; this change
does not claim independent feature compilation or measured build-time improvement.

AppTripServices injects the native search factory and AppSystemModel's existing
providers. Trips has no live search fallback; local fixtures can render without a
provider. Each native search operation owns cancellation and cleanup, while its
feature retains debounce, timeout, and UI-generation policy. Scene activation has
its own lifetime guard before delivering results after foreground work suspends.

## Parallel contribution

Assign bounded workflow paths and agree crossing contracts first. Use separate
worktrees and build outputs. One integration owner coordinates composition,
target wiring, package dependencies and ownership manifests. Shared mutable draft
state never becomes a global service or a sibling-feature dependency.

## Acceptance

- Checklist views depend on Checklist capability, not the root Trip controller.
- Collections views depend on Collections capability with scoped draft/deletion identity.
- Checklist UI and intents share completion mutation rules.
- App invokes semantic feature operations for workflow entry and suspension.
- Older requests and restoration cannot overwrite newer user intent.
- Missing/deleted IDs and protected drafts preserve useful context.
- Deterministic model checks use isolated services and do not open production data.
- Source, compilation, behavioral and visual results are reported independently.

## Limits

A focused ownership boundary is a prerequisite for package extraction, not proof
that moving a folder will improve build time. Public API size, resources, consumers,
and independent verification decide each extraction. Preserve current source limits;
logical-type metrics are advisory, not a reason to split methods artificially.
