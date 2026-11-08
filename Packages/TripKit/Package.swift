// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TripKit",
    defaultLocalization: "en",
    platforms: [.iOS("27.3"), .macOS("27.3"), .visionOS("27.3")],
    products: [
        .library(name: "TripLocalization", targets: ["TripLocalization"]),
        .library(name: "TripDomain", targets: ["TripDomain"]),
        .library(name: "TripPlaces", targets: ["TripPlaces"]),
        .library(name: "TripRouting", targets: ["TripRouting"]),
        .library(name: "MapEngine", targets: ["MapEngine"]),
        .library(name: "TripStorage", targets: ["TripStorage"]),
        .library(name: "TripIntelligence", targets: ["TripIntelligence"]),
        .library(name: "TripIntegrations", targets: ["TripIntegrations"])
    ],
    targets: [
        module("TripLocalization"),
        module("TripDomain", dependencies: ["TripLocalization"]),
        module("TripPlaces", dependencies: ["TripDomain", "TripLocalization"]),
        module("TripRouting", dependencies: ["TripDomain", "TripLocalization"]),
        module("MapEngine", dependencies: ["TripDomain", "TripLocalization"]),
        module("TripStorage", dependencies: ["TripDomain", "TripLocalization"]),
        module("TripIntelligence", dependencies: ["TripDomain", "TripLocalization"]),
        module("TripIntegrations", dependencies: ["TripDomain", "TripLocalization"]),
        .testTarget(name: "TripRoutingTests", dependencies: ["TripRouting", "TripDomain"]),
        .testTarget(name: "TripDomainTests", dependencies: ["TripDomain"]),
        .testTarget(name: "TripPlacesTests", dependencies: ["TripPlaces", "TripDomain"])
    ],
    swiftLanguageModes: [.v6]
)

func module(_ name: String, dependencies: [Target.Dependency] = []) -> Target {
    .target(name: name, dependencies: dependencies,
        exclude: name == "TripLocalization" ? ["HostResources"] : [],
        resources: name == "TripLocalization" ? [.process("Resources")] : [], swiftSettings: [
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("MemberImportVisibility")
    ])
}
