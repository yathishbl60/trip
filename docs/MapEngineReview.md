# MapEngine review · 2026-11-05

The pre-review work was committed as `b30a519` before this pass. The review follows
Trip's native MapKit, stable identity, three-stage annotation, bounded work, and
uncluttered map contracts. It targets concrete defects rather than a new map design.

| Finding | Correction | Why it matters |
| --- | --- | --- |
| Invisible touch padding/clearance could qualify an offscreen marker for a limited slot | Test visible artwork separately from collision/hit bounds; reject zero-area tangency | Visible places retain the scarce candidate/annotation budget without weakening touch clearance |
| Infinite obstruction sentinels became finite covering rectangles after clipping | Validate before clipping and explicitly reject `CGRect.infinite`; check cancellation during grid setup | Malformed measurements cannot conceal the whole map; legitimate finite obstructions still work |
| Measured sheets and search notices were absent from annotation exclusions | Clip measured overlays into map-local coordinates; guard empty geometry before inflation | Placement accounts for the actual exposed map while native safe areas and attribution stay put |
| Geometry movement left obsolete layout/refinement work alive until the coalescing delay | Cancel old work immediately, then request a fresh live projection after geometry settles | Late results cannot reintroduce placement based on old obstructions |
| Notice measurement and retry hit shape included its outer centering frame | Measure content/control bounds before outer width and padding; clear on hide/disappear | Empty space around a compact notice remains available for map gestures |
| Same-name refreshes chose the lowest ID within a radius | Choose nearest distance, then stable ID; retain exact-ID precedence | A nearby branch refresh no longer moves another branch's annotation |
| Cancelled empty merges could still produce snapshots; public proximity helpers accepted malformed bounds | Add early cancellation and explicit bounds validation, retaining index validation outside its loop | Avoid obsolete work and keep public helper behavior aligned with the index |
| Unavailable sample images hid the main category glyph | Explicitly use category artwork until an actual bundled photo source exists; enforce at the leaf view | Saved/sample places cannot render an empty photo disc |
| Long labels shrank and unrated cards repeated a generic action prompt | Preserve font size with truncation, use category metadata, and allocate the full title budget | Names stay consistently legible and secondary text helps identify the place |

## Annotation geometry

The visible surfaces remain 12×12, 44×44, and 184×64 points for dots, compact
artwork, and labeled cards. Existing accessibility scaling and hit bounds remain.
Detailed captions use 110×52 points: 35 for the title, three for separation, and
14 for metadata. The retained caption keeps that title budget during reverse
zoom transitions; clipping/opacity still own hidden-stage visibility.

Selection stays at the true coordinate, uses the existing native annotation,
and retains its stable ID. Full selected labels need readable edge clearance;
compact fallback remains available. No new map control, synthetic coordinate,
screen, network request, or larger annotation budget was added.

The existing geographic heap cutoff, antimeridian splitting, cache freshness/LRU,
zoom hysteresis, retirement lifecycle, and native reentry were reviewed. No concrete
defect justified replacing those mechanisms. Source review is not a speed measurement.

## Verification · 2026-11-06

The standalone correctness suites passed on both the baseline and the updated tree.
The updated suite exercised 74 visual-edge layout requests, 12 obstruction
layout requests, translated/floating/invalid overlay geometry, notice disappearance,
generation/refinement invalidation, nearest branches, deterministic ties, exact IDs,
radius isolation, cancelled empty merges, and invalid geographic bounds.

Paired optimized runs on an Apple M5 Max used Swift 6.4.2 and macOS SDK 27.3.
All 11 workload checksums matched. Each layout stage used 20 warmups and 200
measured layouts. Times below are in milliseconds.

| Stage | Median before | Median after | p95 before | p95 after |
| --- | ---: | ---: | ---: | ---: |
| Overview | 2.720 | 2.678 | 2.936 | 2.818 |
| Places | 2.734 | 2.732 | 2.932 | 2.865 |
| Details | 2.782 | 2.773 | 2.975 | 2.976 |

Every median and p95 stayed within the 20% regression threshold. The largest
increase was the 2,000-place indexed lookup for a 0.4° span. Its p95 rose from
5.167 to 5.959 µs (+15.3%) while its median fell from 4.875 to 4.750 µs.
The JSON writer initially failed on comments and blank lines in the source manifest.
Both reports were generated from the original timing samples after the writer fix.
The baseline inputs were verified against commit `b30a519`.
[Baseline report](../Performance/Baselines/mapengine-review-before-mac.json) ·
[Updated report](../Performance/Baselines/mapengine-review-after-mac.json)

Debug builds succeeded for generic iOS and visionOS Simulator destinations at 27.3.
The source gate passed for ownership, source registration, Swift size limits,
previews, localization, and design policy.

Verification stopped at compilation for the native UI. Rendered label legibility
in light and dark appearance, Thai/Hindi/Kannada glyphs, contrast over map tiles,
hit targets beside sheets, rapid reverse zoom, VoiceOver, Reduce Motion, and
on-device frame pacing remain open for visual and device review.

Primary framework references: Apple's [native Annotation](https://developer.apple.com/documentation/mapkit/annotation)
and [SwiftUI performance guidance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance).
Trip's geometry, density, and scheduling choices remain product-specific contracts.
