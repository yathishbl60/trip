# Apply Trip's engineering safeguards

Use this guide when a change touches several features or repeats a difficult class
of failure. Follow the linked owner contract rather than adding another parallel
rule or framework tutorial.

## Match the risk to its owner

| Change trigger | Required approach | Owning guidance |
| --- | --- | --- |
| Adding map actions | Use existing native entry points and progressive disclosure; preserve map interaction space | [Design system](DesignSystem.md), [adaptive app](../UNIVERSAL-APP.md) |
| Wide layouts, folds, or retained sheets | Use native presentation and measured exclusions; check expansion, collapse, and live resizing | [Search](Search.md), [adaptive app](../UNIVERSAL-APP.md) |
| A feature view gains access to unrelated root state | Give the workflow a composed model/controller and narrow callbacks | [Trips](Trips.md), [workflow contracts](decisions/0002-workflow-contracts.md) |
| Navigation waits for data | Revalidate identity, request generation, and editing protection at delivery | [App](App.md) |
| Siri duplicates in-app mutation behavior | Resolve current records and share domain operations | [System integrations](../SYSTEM-INTEGRATIONS.md) |
| A visual exception is needed | Record exact occurrences and production geometry anchors with a reason | [Design system](DesignSystem.md) |
| A new preview is added | Use a real, distinctly named macro and useful local state | [Preview support](PreviewSupport.md) |
| Parallel work crosses shared files | Agree contracts, assign an integrator, isolate outputs, and check the integrated revision | [Development](Development.md) |
| A successful check is used to justify behavior | Match the claim to the command: source, compilation, execution, or visual review | [Testing](Testing.md) |

## Apply a safeguard

1. Identify the concrete failure the change could introduce and its owning contract.
2. Inspect the current call path, state lifetime, and consumers.
3. Make the smallest coherent correction in that owner.
4. Review adjacent editing, navigation, persistence, and asynchronous behavior.
5. Run relevant checks within the authorized scope and report results in the PR.
6. Update the owner guide if the reusable contract changes.

Keep shared framework techniques in global guidance. Keep Trip-specific rules and
paths here. Add a new safeguard only when it names a concrete consequence,
correction, and responsible owner; avoid vague quality claims and duplicate policy.
