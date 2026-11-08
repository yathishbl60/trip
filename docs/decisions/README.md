# Architecture decision guidance

Use these records when a change affects ownership, dependency edges, service
lifetimes or public reuse contracts. They explain the reasons behind current
boundaries; [Architecture](../../ARCHITECTURE.md) is the source map and
[Development](../Development.md) is the contribution workflow.

| Decision | Use it when |
| --- | --- |
| [Feature ownership and explicit composition](0001-feature-ownership.md) | Choosing a feature owner, injecting a provider or considering a new package |
| [Focused workflows and request delivery](0002-workflow-contracts.md) | Splitting model responsibility, changing draft ownership or adding external navigation |
| [Native travel service boundaries](trip-system-services.md) | Adding imports, exports, alarms or weather behind a domain contract |

For a new cross-cutting decision, use [the decision template](../../templates/decision.md)
and a descriptive numbered filename. State the problem, chosen boundary, alternatives
and consequences. Include the source paths and conditions a contributor must preserve.
Small local choices belong in code review. Keep delivery logs, commit evidence and
transient verification status out of these reusable guides.
