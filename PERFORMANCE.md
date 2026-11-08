# Performance work

Use this guide for launch delays, map hitches, excessive work, memory growth, or
battery/network concerns. Start with the reported interaction and the owning model;
a source refactor or successful build does not establish a performance improvement.
The [standalone harness](Performance/README.md) covers repeatable CPU algorithms.

## Define the workload

Record the device, OS, app configuration, data volume, and exact steps that expose
the problem. Separate cold launch, warm launch, and returning from background.
Identify when input becomes usable, not only when the first frame appears. Use a
repeatable route through the UI and compare equivalent runs.

For map work, include the place density, filters, selected place, camera pose,
viewport size, directions state, and sheet/keyboard geometry. For saved-trip work,
include trip/day sizes, bookings, collections, and pending saves. Keep personal data
out of shared fixtures and reports.

## Inspect ownership and work

Use the workspace context tools to locate the owner before changing behavior:

```sh
python3 scripts/workspace.py context Explore --json
python3 scripts/workspace.py context MapEngine --json
python3 scripts/workspace.py context App --json
```

Trace synchronous initialization and MainActor work, task lifetime, cancellation,
result publication, cache behavior, and view invalidation. Prioritize measured work
on the interaction's critical path. Keep mutable UI state on MainActor and send
immutable snapshots to workers; do not weaken isolation to hide an expensive call.
Preserve annotation identity, selection, camera intent, and useful visible content.

## Choose the measurement

| Question | Method |
| --- | --- |
| Did a domain/layout algorithm remain correct? | Authorized `performance.sh check` or `system-check` |
| Did host CPU cost change under matching inputs? | Paired harness reports and comparison rules |
| What blocks launch or gestures? | Time Profiler plus launch/hitch measurements on the running app |
| Is work growing across repeated interactions? | Memory/task/network inspection across repeated cycles |
| Does the UI remain usable? | Native interaction, accessibility, and adaptive-layout review |

For requested runtime profiling, use a signed build that preserves the intended
App Group configuration. Do not replace a valued signed installation with unsigned
build output. Select an explicit device and configuration, and document recording,
debugger, thermal, power, and background-load conditions that affect measurements.

## Exercise the affected path

- Launch into Explore and restored Trips state; observe first usable input and map projection.
- Pan, pinch, rotate, and pitch through dense results with a stable selection.
- Submit and rapidly replace searches, then cancel, retry, and leave the feature.
- Open, resize, and dismiss details/directions while interacting with the map.
- Edit and save a large trip; change windows or background during pending work.
- Observe system publication after durable edits, including cancellation of superseded work.

Check frame pacing, MainActor duration, allocations, retained tasks, network requests,
and repeated wakeups. A faster path must not reduce necessary output or move work
into an uncontrolled background loop. Avoid camera jumps, flicker, or dropped input
as a side effect of batching work.

## Compare and deliver

Use the [harness procedure](Performance/README.md#commands) for repeatable algorithm
timings. Keep machine, toolchain, workload, sample counts, and output checksums
compatible. Review median and p95 together and repeat noisy measurements. Do not
compare debug/device timing with optimized host timing as the same result.

Report the changed responsibility, the measured interaction, and the exact commands
and configurations used. Keep source validation, compilation, algorithm correctness,
timing, and native interaction results distinct. Run builds, benchmarks, and runtime
work only within the requested task scope; follow [test ownership](docs/Testing.md)
when a behavior needs an executable regression case.
