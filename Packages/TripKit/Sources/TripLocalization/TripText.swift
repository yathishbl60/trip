import Foundation

/// Shared, bundle-aware text for the app, packages, widgets, and intents.
public nonisolated struct TripText: Sendable {
    public let resource: LocalizedStringResource
    public var text: String { String(localized: resource) }

    init(_ key: StaticString, value: String.LocalizationValue = "") {
        resource = LocalizedStringResource(key, defaultValue: value,
            bundle: .atURL(Self.bundle.bundleURL))
    }

    public static func number(_ value: Int) -> String { value.formatted() }

    /// Use in deterministic language previews without changing system preferences.
    public func localized(locale: Locale) -> String {
        var localized = resource
        localized.locale = locale
        return String(localized: localized)
    }

    private static var bundle: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        Bundle(path: ProcessInfo.processInfo.environment["TRIP_LOCALIZATION_BUNDLE"] ?? "") ?? .main
        #endif
    }
}
