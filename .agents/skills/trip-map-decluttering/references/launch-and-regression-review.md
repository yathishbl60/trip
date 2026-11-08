# Launch, search, and native map regressions

Use for an empty/sparse map, search failure, or changes to native map controls.

## Diagnose the stage before changing it

- Reproduce cold launch and record tiles, loading/status, filters, and markers.
- Compare provider result count, unique identities, geographic spread, geographic
  candidates, and displayed placements. A loaded catalog is not visible coverage.
- Nearby POI search may fill its limit within a small cluster. At city scale,
  correct collision handling can reduce that cluster to one marker. Fix discovery
  coverage rather than weakening collisions or adding synthetic/sample places.
- Keep supplemental work bounded, cancellable, scoped to the viewport/categories,
  and subject to existing cache, timeout, generation, and identity-merge rules.
- Verify named search separately from discovery. Check query changes, submission,
  result selection, clearing, retry, and camera settlement; stale motion state must
  not silently leave an explicit search request unhandled.

## Native controls and scope

For partial names such as “Ph”, use MKLocalSearchCompleter for type-ahead choices.
MKLocalSearch interprets a submitted query and may return one country/place; raising
a UI result limit cannot create missing suggestions. Resolve the selected native
completion with MKLocalSearch.Request(completion:), retaining query/session guards.
Check both Explore and Add places; show provider results rather than hardcoded names.

- Keep location, compass, and scale in automatic mapControls across all layouts.
  The toolbar tracking relocation was reverted by user request.
  Do not infer a control frame from its surrounding container.
- Validate every proposed exclusion against the live viewport. A container-sized
  rectangle can exclude all markers; a successful build will not detect it.
- ExploreMapView keeps its original MapReader and automatic native control scope.
  Preserve this structure when changing nearby toolbar or presentation code.
  Check fresh projection after pan/search, continuous/end callbacks, tracking, compass,
  selection/framing, attribution, and single-control ownership through fold transitions.
- Keep MapProxy inside live callbacks. Do not substitute approximate projection,
  ignore cancellation, raise marker limits, or remove native controls to mask bugs.

## Minimum runtime regression pass when authorized

- Cold launch without seeded/sample places; wait for discovery to finish.
- Pan/settle, reverse zoom, select a dot, open details, dismiss, and change selection.
- Search a real place/category, submit, choose/save, clear, and restore discovery.
- Check an unmatched query and available recovery; distinguish no results from
  service failure. Retain compatible content during a failed refresh.
- Verify filters/reset, selected-marker visibility, tabs/Legal, dark appearance,
  and large text. Report unsupported/unexercised configurations explicitly.
- Reject a control/scope experiment that breaks an adjacent flow. Restore the
  smallest known-working structure before adding any further visual changes.
