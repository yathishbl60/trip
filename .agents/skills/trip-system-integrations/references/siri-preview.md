# Trip Siri preview integration

Trip targets iOS/iPadOS and visionOS 27.3+ by explicit user decision. Use the APIs
directly; preserve newer-member gates and the existing native platform boundaries.
General framework contracts live in global app-development's App Intents, Siri,
and Siri evaluation references. Local procedures and contracts live in [Siri preview](../../../../docs/SiriPreview.md).

- Preserve shipped intent/entity names, parameters, IDs, enum values, and Siri phrases.
- App/Intents owns tool exposure and app-only actions; Shared/System remains widget-safe.
- Saved trips and details use authenticated, described, indexed entities. Their
  transferable text includes only the saved summary/detail, never private notes.
- Checklist text remains outside Spotlight and App Group snapshots. Its authenticated
  enumerable query resolves the complete bounded canonical library when needed.
- Generable input is a transient value; keep the target saved entity separate.
- Visit timing edits resolve exact trip/item IDs, reject bookings and invalid clocks,
  preserve unspecified fields, protect unsaved edits, and flush before success.
- AppRuntime owns host operations; TripDomain owns pure timing validation.
- Runtime Siri skills belong in trip/Resources/Skills.skillsbundle, not .agents.
  Refer to tools by their user-facing titles. Skills do not replace model validation.
- Keep travel timing, booking status, and checklist completion claims precise.
- Keep on-device planning the default; PCC remains an explicit choice.
- Require fresh compiled metadata and the compiled Skills.skillsc artifact before
  claiming that Siri skills ship. Never inspect the private compiled skill format.
- Run the metadata analyzer for en/hi/kn on the successful current build; language
  coverage is not native-speaker review. Preserve needs_review translation markers.
- Physical Siri evaluations require supported 27.3 hardware, Apple Intelligence,
  development signing, prepared fixtures, and an unlocked device in Automation Mode.
- Maintain deterministic regression checks separately from Siri behavior evaluations.
- Report source, build, metadata, resources, and real-device evidence separately.
