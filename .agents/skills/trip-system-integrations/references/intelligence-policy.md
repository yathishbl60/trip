# Trip Intelligence policy

Use global `app-development` intelligence and system-integration topics for current APIs and availability.
Reviewed SDK declarations and primary sources belong to global `app-development`.

- General planning defaults to on-device processing; PCC is a separate explicit user choice.
- Check the selected model's availability/locale/capabilities and describe server-bound data honestly.
- Private notes stay out of prompts and system projections.
- Planning drafts use saved places only, bounded input, cancellation, and review before saving.
- Keep manual filters and existing planning controls available when Intelligence is unavailable.
- Open/edit intents validate saved records without discarding unsaved window drafts.
- Packing is strictly on-device through TripAISession, with deterministic fallback templates.
- TripPackingContext sends duration and category names only; see [packing contracts](packing-controls.md).
- Do not present system relevance contexts as general trip contexts without a matching SDK contract.
- Source review does not establish model output quality or signed-device behavior.
