# Engineering lessons and their owners

Keep demonstrated decisions in the contract that can prevent their recurrence.
This record captures the relevant lessons from the UI, maps, Siri, adaptive layout,
and architecture work reviewed on 2026-11-08. It is an adoption map, not a new set
of framework instructions. Proposals do not become product policy until accepted.

| Trigger and observed problem | Accepted correction and owner | Evidence or continuing check |
| --- | --- | --- |
| More map controls reduced the useful map area | Preserve existing native entry points and progressive disclosure; [DesignSystem](DesignSystem.md) and [universal contract](../UNIVERSAL-APP.md) own Trip's choices | The toolbar location-control change from `4d133d0` was reverted by user request; automatic MapKit hosting is restored. Review controls after live resizing, not only fresh launch |
| Large modal content obscured routes on wide layouts | Use native adaptive presentations and measured exclusions; [map contract](Search.md) and [universal contract](../UNIVERSAL-APP.md) | Keep the documented retained-sheet SDK observation scoped to its runtime/reproduction; compilation does not resolve it |
| An available API was mistaken for behavior verification | Record SDK declarations, compilation, executable behavior, and visual results separately; [Testing](Testing.md) | `scripts/verify.py` records exact command and source fingerprints; unchanged source is required to reuse evidence |
| Many short files still exposed root Trips capabilities to Checklist views | Give Checklist its own model/controller and narrow callbacks; [Trips](Trips.md) and [decision 0002](decisions/0002-workflow-contracts.md) | Checklist fixtures and hosted draft, cancellation, stale-result and current-data tests |
| Navigation could wait for data while user intent changed | One scene request generation; validate identity and editing protection again at delivery; [App](App.md) | Controlled restoration, overlapping requests, missing IDs, draft protection and once-delivery tests |
| Siri and in-app actions risked separate mutation rules | Share domain operations and resolve current records; [system integration contract](../SYSTEM-INTEGRATIONS.md) | Checklist completion uses TripChecklistEditing in both paths; domain and hosted tests remain separate from Siri evaluation |
| A file-wide design exception could hide new literals | Review exact occurrences and production geometry anchors; [DesignSystem](DesignSystem.md) | Scoped policy regression fixtures; rendered contrast and motion still need UI review |
| Text containing `#Preview` could satisfy a source audit | Parse real macros and require distinct names per file; [PreviewSupport](PreviewSupport.md) | SwiftSyntax fixtures reject fake/comment/unnamed previews; reviewers still check view/state coverage and service isolation |
| Parallel work touched shared manifests and produced stale verification | Agree file ownership and crossing contracts, name an integrator, isolate build outputs; [Development](Development.md) | Impact/context tooling, source digest records, and integrated checks; metrics are advisory |

Reusable methods live in the maintained global `app-development` skill: architecture,
navigation, map diagnosis, verification, and guidance ownership references. Its
installer retains a content manifest and backup. Trip skills retain the local model
names, paths, native UX policy, commands, and platform contract. Existing local Siri
guidance was preserved in the maintained source before updating that installation.

For a new lesson, record the trigger, consequence, correction, evidence, and owner.
Mark it accepted, proposed, superseded, or runtime-specific. Prefer an owning guide
and a meaningful regression fixture over another overlapping skill or blanket rule.
