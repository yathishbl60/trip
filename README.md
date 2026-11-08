# Trip

Trip is a native SwiftUI and MapKit app for discovering places and planning travel.
Explore keeps search, place details, and directions on the map. Trips brings saved
places, bookings, schedules, checklists, and visit progress into one itinerary.

Use this page to choose a contribution and find the guide that owns it.

## Choose an area

| Area | Capabilities | Guide |
| --- | --- | --- |
| Explore | MapKit search, filters, adaptive annotations, place details, Look Around | [Explore](docs/Explore.md) |
| Directions | Route alternatives, travel modes, stops, Apple Maps handoff | [Directions](DIRECTIONS.md) |
| Trips | Itineraries, bookings, collections, schedules, Today, checklists, sharing | [Trip planning](TRIPS.md) |
| Native services | Booking extraction, Calendar/Reminders exports, travel alarms | [Native travel services](docs/NativeTravelServices.md) |
| System integration | Siri, Shortcuts, reviewed AI suggestions, Spotlight, widgets, Live Activities | [System integrations](SYSTEM-INTEGRATIONS.md) |

Preserve local-first planning: Trips are stored locally, and manual planning works
without Apple Intelligence. Cloud sync and collaboration are not implemented.
WeatherKit and Private Cloud Compute require explicit host configuration and eligible
signing; they are disabled by default. Explore starts over Bangkok using live MapKit
results, not the device's location. Keep the [gallery](docs/PlaceGallery.md) hidden
until a real photo source is supplied.

## Prepare to contribute

Documentation, translation review, bug reports, and focused fixes are welcome.
Follow [Contributing](CONTRIBUTING.md) for setup and a first change. Use the
[documentation index](docs/README.md) to select one owning guide.

Native development requires a Mac with Xcode and the **27.3 or newer SDKs** for
iOS, visionOS, and macOS. Deployment minimums are iOS/iPadOS **27.3**, visionOS
**27.3**, and macOS **27.3** for TripKit. Repository tooling requires **Python
3.10+**; CI uses Python 3.12. The app uses Swift 6, MainActor default isolation, and
**eight local package products** with no remote package dependencies.

After [setting up Python and selecting Xcode](CONTRIBUTING.md#local-setup):

```sh
python3 scripts/workspace.py doctor --require-ready --json
bash scripts/check.sh
```

These commands inspect prerequisites and source contracts without building or
launching the app. Open `trip.xcodeproj` with the shared `trip` scheme for native
development. Follow [signing and capability setup](SYSTEM-INTEGRATIONS.md#signed-run-setup) before
running the app. Choose compilation, test, and UI checks using [Testing](docs/Testing.md).

## Read the owning instructions

- [Architecture](ARCHITECTURE.md): place changes in the right module or feature.
- [Development](docs/Development.md): find context, scope a change, and scaffold.
- [TripKit](Packages/TripKit/README.md): use reusable package contracts.
- [Project rules](AGENTS.md): apply product, source, and delivery requirements.
- [Documentation index](docs/README.md): find task-specific procedures.

## License

Trip is licensed under the [MIT License](LICENSE).
