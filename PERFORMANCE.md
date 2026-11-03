# Performance validation

Trip has two complementary verification paths: deterministic production-algorithm
checks and measurements of the running app. Neither replaces the other.

## Algorithm checks and benchmarks

[Performance/README.md](Performance/README.md) owns the commands, coverage,
comparison rules, and extension workflow. It uses production source files listed
in `Performance/sources.txt`. Checked-in reports under `Performance/Baselines`
are measurement artifacts, not guarantees for another machine or revision.

Run builds and benchmarks only when requested for agent work. Record the exact
configuration, dataset, command, and result; never compare different machines or
build modes as if they were controlled measurements.

## Profile the running app

Use a signed build that preserves the intended App Group configuration. Select a
representative device, data volume, and repeatable route through the UI. Capture
Time Profiler and animation/hitch evidence while exercising:

- Cold launch, first map projection, and restored selection.
- Continuous pan, pinch, rotation and pitch in dense map areas.
- Search submission, rapid query changes, cancellation and retry.
- Opening, resizing and dismissing details or directions during map interaction.
- Large saved trips, editing and save/reload, and background/foreground transitions.
- Widget publication and bounded native-service work after durable edits.

Check frame pacing, MainActor work, memory growth, task cancellation, network
requests and battery impact. Preserve stable selection and useful visible content
while measuring. Slow motion, recording overhead and debug instrumentation affect
results; describe those conditions.

## Report evidence

Separate source audits, compilation, executable correctness checks, benchmark
timings and observed device behavior. State sample counts and median/p95 where the
harness provides them. Name untested devices and interactions. A passing source
gate or a local preview declaration establishes neither responsiveness nor runtime
correctness. See [Contributing](CONTRIBUTING.md) for the verification policy.
