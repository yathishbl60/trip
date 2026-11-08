# Focused workflows and request delivery

Use this decision when a root model accumulates unrelated state, a view receives
more capability than it needs, or an external request can race with local editing.
The goal is a coherent workflow boundary with explicit entry and lifetime rules.

## Focused state ownership

Checklist owns its naming draft, packing session and generation worker through
`TripChecklistModel` and `TripChecklistController`. Collections owns naming,
deletion, notices and saved-place edits through its corresponding model/controller.
Both share the canonical library rather than copying durable state.

Session identities protect dismissal, confirmation and commit. TripModel supplies
cross-workflow policy through narrow environments: day insertion, save-sheet
dismissal, feedback and native entity identifiers. TripEditorView supplies section
navigation. A shared row receives its specific action rather than the root controller.

This keeps local composition useful without inventing a generic workflow framework.
Apply the same pattern only where a workflow has its own task, state lifetime and
entry contract. [Trips](../Trips.md) identifies the current owners.

## Semantic host operations

App calls semantic operations in `TripModel+HostNavigation` and
`TripModel+HostWorkflows`. It does not sequence internal presentation flags or
configure child workers. Features retain their own cancellation and setup rules.

`AppRequest` separates destinations from workflow commands. Each scene owns a
request generation; a new action invalidates older suspended work, including
restoration. Resolve canonical IDs and recheck draft protection at delivery. The
launch mailbox consumes a pending request once in an eligible foreground scene.
See [App](../App.md) for missing-ID, repeated-route and activation behavior.

## Compiler boundaries

TripPlaces is a bounded shared adapter module: native text search, MapKit item
conversion and category filters serve Explore and Trips. It depends only on
TripDomain and TripLocalization. App resources and observable autocomplete state
remain in Shared/Places. TripRouting independently owns directions state and UI.

The host injects a search factory; Trips has no live fallback. Native operations
own cancellation and cleanup, while features own debounce, timeout and generation
policy. Full feature extraction would first require explicit UI, resource, preview
and host contracts. Moving a folder does not establish independent compilation or
a measured build-time improvement.

## Apply and review

- Give each contributor bounded owning paths and agree cross-owner contracts first.
- Coordinate composition, target wiring and manifests through one integrator;
  separate worktrees and output directories avoid different classes of collision.
- Keep drafts scene-local and preserve stable identities during library updates.
- Reuse domain mutation rules for UI and intent actions, including Checklist completion
  and Collection edits.
- Review stale requests, deleted IDs, changed drafts and reopened destinations.
- Use [Preview support](../PreviewSupport.md) and [Testing](../Testing.md); keep source,
  compilation, executable and visual checks distinct.
