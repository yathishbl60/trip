---
name: trip-system-integrations
description: Add or improve Trip's Siri, Shortcuts, Apple Intelligence, widgets, and Live Activities using saved trip data and native system surfaces.
---

# Trip system integrations

Read [project rules](../../../AGENTS.md), [architecture](../../../ARCHITECTURE.md),
and [integration contract](../../../SYSTEM-INTEGRATIONS.md). Apply the existing
system-integration topics in global `app-development` after verifying current SDK declarations. Use the installed global `app-development` services topic for framework ownership details.

## Ownership and data

- AppRuntime shares durable data with intents; windows own navigation, map, drafts, search, and sort state.
- Keep app-only navigation intents in trip/App/Intents; AppTripServices in trip/App/Dependencies selects live services.
- Shared/System entities, attributes, runtime, and interaction intents compile in both targets.
- TripDomain owns Sendable projections; TripStorage owns atomic App Group publication.
- Publish projections after durable saves. Widgets never open the private SwiftData database.
- Keep payloads bounded; exclude private notes and sample metadata from system projections.
- Keep entities' persistent UUIDs. Queries omit missing IDs and preserve requested order.
- Validate edits against the canonical app library, not stale AppEntity display properties.

## Native surfaces

- Use supportedModes from the installed SDK; foreground actions must open useful app UI.
- Siri phrases include the application token and real trip parameters; read [metadata guidance](references/metadata-contract.md).
- Use IndexedEntity/OpenIntent and onscreen entity identifiers for system discovery.
- Serialize Spotlight updates; remove deleted entities without clearing unrelated index data.
- Use configurable native widgets, privacySensitive content, and exact trip deep links.
- Widget and Live Activity actions carry trip, day, and stop IDs; stale/double taps are idempotent.
- Check Live Activity authorization; reconcile removed/reordered stops and expired activities.
- Guard Live Activities with os(iOS); use native widgets and real visit progress on visionOS.
- Provide compact, minimal, expanded, Lock Screen, completed, and stale presentations.
- Update progress from actual visits. Do not invent ETA, navigation, push updates, or GPS tracking.
- AI drafts use saved places only, bounded input, cancellation, and review before saving.
- Give precise Intelligence availability messages and preserve manual planning.

## Verification

- Keep 100-line Swift files, 20-line members, named same-file previews, and local fixtures.
- Keep host/extension source membership, embedding, Info.plist, and App Groups aligned.
- Run bash scripts/check.sh after changes; it audits both source and system target wiring.
- Build only when requested; source audits do not establish compilation or device behavior.
- Verify Siri, widgets, protected data, and Dynamic Island on signed supported devices.

## Current framework guidance

Read [Intelligence policy](references/intelligence-policy.md) before adding Intelligence or Siri features.
Keep selected-model privacy and manual planning intact. Read [Trip intent contracts](references/intent-contracts.md) for saved identifiers and canonical mutations.
For preparation/controls read [packing contracts](references/packing-controls.md); for Siri tools and app skills read [preview adoption](references/siri-preview.md).
