# Choose a task guide

Use the guide for the task you are doing. Each guide should tell you where to work,
which contracts to preserve, and how to check the result. Read only the areas your
change crosses. Use source code and ownership manifests to resolve implementation
details, then correct the owning guide when it drifts.

## Get started

| Task | Guide |
| --- | --- |
| Understand the app | [Project overview](../README.md) |
| Make and verify a change | [Contributing](../CONTRIBUTING.md) |
| Follow project requirements | [Project rules](../AGENTS.md) |
| Find owners, generate context or scaffold | [Development workflow](Development.md) |
| Understand module boundaries | [Architecture](../ARCHITECTURE.md) |
| Choose task-specific guidance | [Skills](Skills.md) |

## Work on a feature

| Area | Guide |
| --- | --- |
| App lifecycle, navigation and host callbacks | [App](App.md) |
| Map, camera, markers and place details | [Explore](Explore.md) |
| Autocomplete, matching and saved-detail filtering | [Search](Search.md) |
| Retained photo-gallery implementation | [Place gallery](PlaceGallery.md) |
| Routing feature ownership | [Directions](Directions.md) |
| Routing API, host integration and tests | [Directions integration](../DIRECTIONS.md) |
| User-facing trip planning | [Trip planning](../TRIPS.md) |
| Trip models, editing and planning contracts | [Trips developer guide](Trips.md) |
| Time zones, schedules and Today | [Destination times](TripTimeAndToday.md) |
| Booking import, exports, alarms and weather | [Native travel services](NativeTravelServices.md) |
| Siri, Shortcuts, widgets and Live Activities | [System integrations](../SYSTEM-INTEGRATIONS.md) |
| Multiple windows, iPad and visionOS | [Adaptive app](../UNIVERSAL-APP.md) |

## Shared foundations

| Area | Guide |
| --- | --- |
| Package products | [TripKit](../Packages/TripKit/README.md) |
| Provider injection and lifetimes | [Dependencies](Dependencies.md) |
| Reusing the map host | [Map reuse](../REUSE.md) |
| Colors, controls and shared presentation | [Design system](DesignSystem.md) |
| Symbol choice and rendering | [SF Symbols](../SF-SYMBOLS.md) |
| Icon assets and design inputs | [App icons](AppIcons.md) |
| String catalogs and generated accessors | [Localization](Localization.md) |
| Local fixtures | [Preview support](PreviewSupport.md) |

## Review and plan a change

| Task | Guide |
| --- | --- |
| Use repository tools | [Scripts](../scripts/README.md) |
| Run requested algorithm checks and benchmarks | [Performance harness](../Performance/README.md) |
| Profile app behavior and report evidence | [Performance validation](../PERFORMANCE.md) |
| Choose test seams | [Testing](Testing.md) |
| Review visual consistency | [Design review procedure](DesignConsistencyReview.md) |
| Review map quality and performance | [MapEngine review procedure](MapEngineReview.md) |
| Apply cross-cutting safeguards | [Engineering safeguards](EngineeringLessons.md) |
| Understand architectural decisions | [Decisions](decisions/README.md) |
| Evaluate feature proposals | [Feature planning](FeatureRoadmap.md) |
| Prepare a focused change | [Task template](../templates/task.md) and [decision template](../templates/decision.md) |

## Maintain the docs

Keep each contract in its owning guide and link to it from overviews. Explain when
to use the guide, owning paths, steps, constraints, and relevant checks. Update
guidance with the implementation. Keep feature proposals clearly conditional.
Put dated execution results, commit recaps, and delivery summaries in PRs or ignored
verification records; do not add them to these reusable instructions. Follow
[Skills](Skills.md) for guidance ownership and formal skill entrypoints.
