# Trip project rules

These are this project's defaults; explicit user instructions take precedence.

## Product quality and UX — required for every change

- Treat Trip as a production product aiming to lead its App Store category; UI and UX quality are primary acceptance criteria for every feature, not later polish.
- Before adding a feature, identify the user task, the concrete benefit over the existing flow, and how the implementation delivers it. Requests for cool features still require practical value. Omit features that merely animate repeated information or add controls without helping planning, decisions, or travel; keep low-value experiments out of primary screens. A useful idea must also remain useful in its actual implementation. Do not claim user appeal or validation without evidence.
- Preserve the established visual language, navigation, screen hierarchy, map behavior, and working interactions. Inspect the existing flow before editing it; make focused improvements rather than unrelated redesigns.
- An unapproved design proposal does not authorize UI implementation or inclusion in delivery. Keep proposals and unfinished UI work out of unrelated commits unless explicitly approved.
- Integrate new capabilities into existing entry points. Prefer progressive disclosure and contextual actions over extra permanent buttons, panels, explanatory text, or competing controls.
- Make the main task clear and easy to complete. Use native controls, consistent spacing and typography, legible content, and predictable Save, Cancel, Delete, and recovery behavior.
- Keep the interface calm while loading, refreshing, failing, or showing no results. Preserve useful content and selection during compatible updates; avoid flicker, layout jumps, and unnecessary camera changes.
- Account for Dynamic Type, VoiceOver, Reduce Motion, dark appearance, long content, compact widths, and supported adaptive layouts as part of the feature.
- Treat map gesture responsiveness, stable annotation identities, bounded background work, and sensible network/battery use as user experience requirements.
- Review adjacent workflows for regressions, including editing, navigation, persistence, sharing, and asynchronous updates. Do not ship decorative or nonfunctional controls.
- Add useful deterministic previews and maintain focused regression checks. Follow the verification rules below; report source audits, compilation, and visual/device verification separately and state what remains unverified.
- Apply these expectations automatically on future work; the user should not need to repeat them. More features or visual novelty alone do not establish a better product.

## Implementation

- Use SwiftUI and MapKit with current APIs supported by the installed SDK.
- Target iOS/iPadOS and visionOS 27.3+ (user-approved 2026-11-04); use available native APIs directly and guard only newer additions. Keep TripKit's configured platforms aligned at 27.3. Do not add older compatibility paths or silently raise the minimum.
- Use the task-to-skill map in `docs/Skills.md`; load only relevant Trip skills and installed global framework topics. Verify exact signatures and member availability against the installed SDK; preserve other configured platform targets.
- Do not introduce UIKit, UIKit bridges, or UIKit image types.
- Keep every authored Swift file at most 100 physical lines, including previews.
- Keep each function, initializer, and computed property at most 20 physical lines.
- User-approved exception: `TripShortcuts.appShortcuts` may use 22 lines for its ten static App Shortcut declarations; all other members retain the 20-line limit.
- Count declarations, braces, comments, and blank lines; do not compress code to evade limits.
- Keep each file within a project skill at most 50 physical lines.
- Split by responsibility and use descriptive names; avoid artificial fragmentation.
- Use View–Controller–Model inside `trip/Features/<Feature>/{Views,Controllers,Models}`.
- Keep app composition in `trip/App`, shared UI in `trip/DesignSystem`, and fixtures in `trip/PreviewSupport`.
- Reusable domain, algorithms, storage, and intelligence belong in `Packages/TripKit/Sources`.
- Read `ARCHITECTURE.md` for the module graph; package targets must never depend on app types.
- Views render state and delegate actions to controllers; no business logic in views.
- Controllers are structs whose only stored property is their model.
- Models own behavior and state; compose smaller models instead of growing one root model.
- Keep mutable UI models on MainActor; use actors for shared caches and layout state.
- Use async/await with cancellation and stale-result protection; avoid GCD and unsafe isolation.

## Interface and data

- Prefer native SwiftUI components, SF Symbols, and minimal customization.
- Keep stable marker identities and smooth zoom transitions; respect Reduce Motion.
- Keep camera positioning responsive and expensive work outside view bodies.
- Render interactive places with native MapKit annotations; overlays must not block map gestures.
- Use three annotation stages: dots, icons/images, and labeled views; preserve filters and selection.
- Use MapKit search for place information; identify sample photos and ratings as samples.
- Use Explore and Trips navigation with native toolbars and focused sheets.
- Put named previews for every view in its own file, including useful variations.
- Prefer deterministic, local preview fixtures; identify previews that use live services.

## Verification and delivery

- Maintain standalone performance checks and benchmarks in `Performance` and `scripts`.
- Keep `bash scripts/performance.sh` ready for requested algorithm checks; see `Performance/README.md`.
- Do not add unrelated tests or app test targets unless requested.
- Run builds and benchmarks only when the user requests them; audit source and skill line limits before finishing.
- Run `python3 scripts/check_architecture.py` after moving sources or changing module dependencies.
- Run `python3 scripts/check_project_skills.py` when changing project skills. Global SDK evidence and its maintenance tools belong with the global skill, not this repository.
- Report the actual configuration and result; compilation is not visual verification.
- Never weaken concurrency checks or deployment requirements to hide build errors.
- Ignore generated build artifacts and personal Xcode state; retain shared project files.
- Do not publish or push unless requested.

## Contributor and AI workflow

- Use `python3 scripts/workspace.py context <Owner> --json` to find contracts, consumers, guides, and source paths.
- If only a source path is known, use `python3 scripts/workspace.py locate <path> --json` to resolve its owner. Context skill suggestions are conditional; load only those relevant to the task.
- Read `docs/Development.md` for task, feature, decision, and review templates; scaffolding defaults to a dry run.
- Keep Trips production service creation in `trip/App/Dependencies`; inject contracts into feature models, including availability and failure policy.
- Use local `PreviewTripServices` for Trips component previews; see `docs/Dependencies.md` for lifetimes and `docs/Testing.md` for future tests.
- Update ownership manifests and their guide/entry-point references in the same change when boundaries move.
- Before adding guidance, classify ownership: reusable framework/workflow guidance extends the relevant global skill; Trip paths, domain rules, UX choices, and verification commands stay in `trip-*` or project docs. Never vendor or symlink global skills into the project.
- Name skills by responsibility; keep platform versions in baseline/evidence content. If a global skill is unavailable, continue from Trip contracts and current SDK/primary documentation without installing a project copy.
- Use the single global `app-development` skill for common app engineering. SwiftUI, iPad, review, and framework guidance are topics inside it, not separate competing skills.

## Local skills

- Skill ownership and context selection: [docs/Skills.md](docs/Skills.md)
- Architecture: [.agents/skills/trip-swiftui-vcm/SKILL.md](.agents/skills/trip-swiftui-vcm/SKILL.md)
- Map behavior: [.agents/skills/trip-map-decluttering/SKILL.md](.agents/skills/trip-map-decluttering/SKILL.md)
- Routing and directions: [.agents/skills/trip-routing/SKILL.md](.agents/skills/trip-routing/SKILL.md)
- Previews/builds: [.agents/skills/trip-previews-build/SKILL.md](.agents/skills/trip-previews-build/SKILL.md)
- Universal/adaptive app: [.agents/skills/trip-universal-app/SKILL.md](.agents/skills/trip-universal-app/SKILL.md)
- System integrations: [.agents/skills/trip-system-integrations/SKILL.md](.agents/skills/trip-system-integrations/SKILL.md)
- Xcode target and tooling contracts: [.agents/skills/trip-xcode-tooling/SKILL.md](.agents/skills/trip-xcode-tooling/SKILL.md)
