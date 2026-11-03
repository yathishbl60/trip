# Applied skill review · 2026-10-24

The eleven supplied skills and 87 original source files are preserved in the private
global reference archive. This document records their historical application to Trip. Applying every skill does not mean introducing unrelated frameworks,
changing security policy, or migrating tests into this app.

## Retained changes backed by the relevant guidance

| Guidance | Application in this change |
| --- | --- |
| SwiftUI observation | Map and trip-selection side effects have their own modifiers; the owning map/split-view body no longer reads those inputs solely for callbacks. |
| SwiftUI structure and identity | Trip library and save-destination lists are separate View types with existing persisted row identities and native navigation. Each list obtains its filtered result once per render. Save search reads stay in the list; its sheet retains the query across library changes. |
| Native accessibility | Map status messages honor accessibility Dynamic Type and wrap; normal text retains its compact line. The measured notice frame continues to reserve annotation space. |
| SDK/API correctness | Removed a preview write to the read-only accessibilityReduceMotion environment value. The named preview uses the existing animation-disabled configuration. |
| App Intents query design | Detail identifiers resolve in requested order, omit missing records, and reuse one trip projection per trip in cancellable background work. Canonical app data and native entity construction retain their required isolation. |
| Localization | Generation is independent of catalog key order. Regrouping preserves all 952 accessor declarations. The audit distinguishes format-only extraction artifacts from real labels, which still require all supported translations. The bundle name retains the same brand in every language. |

## Map-control boundary

The original native mapControls host remains in use. The map-scope, safe-area,
and viewport experiments remain removed. The restored UI changes cover observer
isolation, list boundaries, retained save-search state, and accessible status text.

## Skills with conditional applicability

- New SwiftUI/App Intents APIs are not adoption targets by themselves. Existing
  current APIs remain where they satisfy the workflow; public intent identities,
  phrases, and enum raw values have not been renamed.
- Device-interaction guidance applies to runtime verification. Simulator access
  was declined; no screenshot, interaction, or frame-pacing claim is made.
- xctrace guidance remains available for requested profiling. No trace or benchmark
  was run, so these changes do not establish a measured performance improvement.
- Xcode hardening and C bounds safety remain intact reference workflows. This
  change adds no C, security entitlements, compiler flags, or signing-policy edits.
- Document-app guidance remains available for document workflows. SwiftData
  persistence and sharing are not replaced with a document architecture.
- Test modernization remains available for existing test maintenance. No new app
  test target or unrelated test migration was added.

## Verification boundary

- Xcode 27.2, iOS Simulator Debug, arm64 and x86_64, signing disabled: app and
  widget build succeeded after the preview fix, including App Intents processing.
- The restored UI changes pass source/architecture checks. Their earlier build
  result does not establish current-revision compilation or runtime behavior.
- A source check verified generator key-order independence, unchanged accessor
  declarations, and rejection of untranslated real labels or authored symbols.
- The final rebuild was declined. Current-revision compilation, visionOS builds,
  Canvas rendering, device interactions, and measured performance remain unverified.
