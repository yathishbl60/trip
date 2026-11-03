# Trip

Trip is a native SwiftUI and MapKit app for discovering places and planning local
itineraries. Explore provides map search and directions; Trips keeps saved places,
bookings, schedules, checklists, and visit progress together.

## Start here

1. Open `trip.xcodeproj` and select the shared `trip` scheme.
2. Choose a supported iPhone or iPad simulator, or configure signing for a device.
3. Read [Contributing](CONTRIBUTING.md) before making a change.

The deployment baseline is iOS/iPadOS 27.0+. The project also configures visionOS
27.0; TripKit supports macOS 27.0 for its package targets. Use an Xcode installation
with the required SDKs. Swift 6 language mode and MainActor default isolation are
enabled. The app uses seven local package products and no remote package dependencies.

## What the app does

| Area | Capabilities | Guide |
| --- | --- | --- |
| Explore | MapKit search, category filters, adaptive annotations, place details, Look Around | [Explore](docs/Explore.md) |
| Directions | Route alternatives, travel modes, intermediate stops, Apple Maps handoff | [Directions](DIRECTIONS.md) |
| Trips | Local itineraries, bookings, collections, schedules, Today, checklists, sharing | [Trip planning](TRIPS.md) |
| Intelligence | Reviewed itinerary and packing suggestions; saved-detail question interpretation | [System integrations](SYSTEM-INTEGRATIONS.md) |
| Native services | Booking extraction, Calendar/Reminders exports, travel alarms | [Native travel services](docs/NativeTravelServices.md) |
| System surfaces | Siri, Shortcuts, Spotlight, widgets, visit tracking and Live Activities | [System integrations](SYSTEM-INTEGRATIONS.md) |

Trips use local storage; cloud sync and collaboration are not implemented. Manual
planning works without Apple Intelligence. WeatherKit and Private Cloud Compute
are disabled in the checked-in configuration. Their availability requires eligible
signing and explicit host configuration.

Explore starts over Bangkok and loads live MapKit results. The starting coordinate
is not the device's location. Preview fixtures are separate from production data.
The gallery code is retained, but no photo assets or live photo source are bundled;
place details therefore hide the gallery entry. See [Gallery](docs/PlaceGallery.md).

## Development

Run source checks from the repository root:

```sh
bash scripts/check.sh
```

This audits source and project contracts; it does not build or run the app.
Builds, executable checks, benchmarks, and device verification are separate steps.
The commands and their scope are in [Contributing](CONTRIBUTING.md).

- [Documentation index](docs/README.md): choose a guide by task.
- [Architecture](ARCHITECTURE.md): modules, feature boundaries, and ownership.
- [Development workflow](docs/Development.md): context lookup, scaffolding, and review.
- [TripKit](Packages/TripKit/README.md): reusable package products.
- [Project rules](AGENTS.md): product, source, and delivery requirements.
