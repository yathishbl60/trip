# Trip intent and query contracts

Use global `app-development` system-integration topics for query, entity, execution, and metadata rules.
Read only the relevant framework reference and verify SDK-specific behavior.

- Preserve shipped intent type names, entity identifiers, enum raw strings, and automatic Siri phrases.
- Resolve persistent trip/day/stop IDs against the canonical library; omit deleted IDs and retain requested order.
- Build one immutable projection per requested trip and keep native construction at its required isolation boundary.
- Exclude private notes from system-facing properties and projections.
- Durable actions validate current records; repeat execution must not duplicate or reverse a completed edit.
- Shared entities cannot reference AppRuntime or feature models; host handlers are injected by App composition.
- Configuration intents remain parameter-only; interaction intents perform canonical mutations.
- Keep app-only navigation intents in App/Intents and preserve unsaved window drafts.
- Trip's custom scheme works with existing widgetURL/Link handling, not universal-link-only URL intents.
- Adopt schemas only when saved Trip data satisfies their documented meaning and required fields.
- Reusable snippets reload durable records; a display snapshot is not authority for a write.

Follow [metadata contracts](metadata-contract.md) and [packing/control ownership](packing-controls.md).
Preserve local storage and manual planning; new APIs do not justify replacing these product contracts.
