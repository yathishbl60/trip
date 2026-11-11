# Review the map engine

Use this workflow when changing geographic lookup, placement, annotation geometry,
overlay exclusions, camera coordination, or map request scheduling. Start with
[Explore](Explore.md), [reuse contracts](../REUSE.md), and the
[map skill](../.agents/skills/trip-map-decluttering/SKILL.md).
Keep native MapKit interaction and stable identities as acceptance requirements.

## Trace a placement from input to display

1. Resolve the source owner with `python3 scripts/workspace.py locate <path> --json`.
   Follow geographic candidates through live projection, exclusions, placement,
   display stages, and the final native annotation.
2. Identify which values are immutable inputs and which revision owns the result.
   Check cancellation before work, during expensive loops, and before publication.
3. Trace selection and camera updates separately from ordinary placement. A
   refresh must not move a place to a synthetic coordinate or change its identity.
4. Compare the visible artwork, collision bounds, and hit target. They serve
   different purposes and must not share an accidental visibility test.

## Inspect edge cases

| Boundary | Required behavior |
| --- | --- |
| Visibility | Visible artwork qualifies a candidate; offscreen hit padding and zero-area tangency do not consume scarce slots |
| Obstructions | Validate malformed, empty, or infinite geometry before clipping/inflating; legitimate finite obstructions remain effective |
| Sheet and notice geometry | Convert measured content into map-local coordinates; clear exclusions when hidden or removed |
| Notice interaction | Measure the actual pill/control, not the outer centering frame; surrounding map space remains interactive |
| Geometry changes | Cancel obsolete placement/refinement immediately; delayed work obtains a fresh projection after coalescing |
| Identity refresh | Prefer exact IDs; same-name proximity matching chooses nearest distance, then stable ID for a tie |
| Cancelled work | Even empty merges and public proximity helpers respect cancellation and invalid bounds |
| Artwork fallback | Missing sample/photos retain category artwork rather than an empty image disc |
| Labels | Preserve semantic font size and the title budget; truncate intentionally and use useful secondary metadata |
| Selection near edges | Keep the true coordinate and native annotation; use readable clearance or the existing compact fallback |

Preserve the three annotation stages. The current base visible sizes are 12×12
for dots, 44×44 for compact artwork, and 184×64 for detailed cards. The caption is
110×52: 35 for title, 3 for separation, and 14 for metadata. These are map geometry,
not general UI spacing. Keep accessibility scaling and hit bounds intact, including
reverse zoom transitions where clipping/opacity hide the inactive stage.

## Check bounded work and stable transitions

Keep current annotation footprints collision-free. Animation envelopes additionally
reserve space for new or growing artwork; retained and shrinking markers must not
evict each other because old envelopes overlap after camera movement. Preserve
appearance history and mounted content when a retirement fade reverses before it
finishes. Fully hidden reentry still starts at its new size with fresh content.

Inspect candidate budgets, geographic cutoff, antimeridian splitting, cache
freshness/LRU, zoom hysteresis, retirement, and reentry. Confirm filtering and
selection persist while compatible content refreshes. Expensive work belongs
outside view bodies; MapProxy is used synchronously, never retained across awaits.
A faster run that drops places or ignores exclusions is not an optimization.

For changes to request scheduling, follow scene suspension and cancellation
through search, location, directions, and layout. A late completion must not
restore a previous viewport, obstruction set, route, or selection.

## Choose the checks

Run `bash scripts/check.sh` for source policy. When algorithm execution is
requested, use `bash scripts/performance.sh check`; see the
[harness guide](../Performance/README.md) for coverage and limitations. Exercise
invalid/translated/floating geometry, notice disappearance, reverse zoom,
nearest-branch ties, exact IDs, radius isolation, and cancelled empty results.

For requested performance work, establish correctness first, then compare the
same optimized workload, toolchain, hardware, sample counts, and output checksums.
Use fresh before/after reports and [the performance workflow](../PERFORMANCE.md).
Do not infer native frame pacing from host algorithm timings.

For requested native review, include rapid pan/zoom reversal, selected edges,
long localized labels, light/dark tiles, sheet/fold transitions, Legal attribution,
VoiceOver, Reduce Motion, and map gestures beside notices and sheets. Describe
source, algorithm, compilation, and device observations separately; do not treat
one as proof of the others.
