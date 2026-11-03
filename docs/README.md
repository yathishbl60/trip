# Documentation

Start with the guide for the task you are doing. Feature guides describe current
contracts; the roadmap contains proposals. Source code and ownership manifests
settle implementation details when documentation and code differ.

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

## Verification and planning

| Task | Guide |
| --- | --- |
| Use repository tools | [Scripts](../scripts/README.md) |
| Run requested algorithm checks and benchmarks | [Performance harness](../Performance/README.md) |
| Profile app behavior and report evidence | [Performance validation](../PERFORMANCE.md) |
| Choose test seams | [Testing](Testing.md) |
| Understand architectural decisions | [Decisions](decisions/README.md) |
| Evaluate future work | [Feature roadmap](FeatureRoadmap.md) |
| Prepare a focused change | [Task template](../templates/task.md) and [decision template](../templates/decision.md) |

## Maintain the docs

Keep each contract in its owning guide and link to it from overviews. Update
paths, commands, dependencies and limitations with the relevant implementation.
Remove obsolete progress logs and duplicate explanations. Keep proposals distinct
from implemented behavior and verification instructions distinct from measured
results. Do not treat an old successful build as evidence for a new revision.
