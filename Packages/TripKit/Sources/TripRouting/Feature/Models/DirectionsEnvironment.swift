#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

/// Host integration only. Routing and presentation do not depend on app navigation or storage.
@MainActor public struct DirectionsEnvironment {
    public var currentLocation: () -> Coordinate?
    public var locationAuthorized: () -> Bool
    public var requestLocation: () -> Void
    public var loadedPlaces: () -> [Place]
    public var search: (String) async throws -> [Place]
    public var close: () -> Void
    public var sheetFrameChanged: (CGRect) -> Void
    public var placeTint: (Place) -> Color
    public var appearance: DirectionsAppearance

    public init(currentLocation: @escaping () -> Coordinate? = { nil }, locationAuthorized: @escaping () -> Bool = { false },
                requestLocation: @escaping () -> Void = {}, loadedPlaces: @escaping () -> [Place] = { [] },
                search: @escaping (String) async throws -> [Place] = { _ in [] }, close: @escaping () -> Void = {},
                sheetFrameChanged: @escaping (CGRect) -> Void = { _ in },
                placeTint: @escaping (Place) -> Color = { _ in .accentColor }, appearance: DirectionsAppearance = .init()) {
        self.currentLocation = currentLocation
        self.locationAuthorized = locationAuthorized
        self.requestLocation = requestLocation
        self.loadedPlaces = loadedPlaces
        self.search = search
        self.close = close
        self.sheetFrameChanged = sheetFrameChanged
        self.placeTint = placeTint
        self.appearance = appearance
    }
}
#endif
