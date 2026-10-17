import Foundation

public nonisolated struct TripWeatherHour: Identifiable, Sendable {
    public static let duration: TimeInterval = 60 * 60
    private static let likelyRainProbability = 0.6
    private static let hotApparentCelsius = 32.0
    private static let strongWindKilometersPerHour = 40.0
    public var id: Date { date }
    public let date: Date
    public let symbol: String
    public let temperatureCelsius: Double
    public let apparentCelsius: Double
    public let precipitationChance: Double
    public let windKilometersPerHour: Double

    public init(date: Date, symbol: String, temperatureCelsius: Double, apparentCelsius: Double,
                precipitationChance: Double, windKilometersPerHour: Double) {
        self.date = date
        self.symbol = symbol
        self.temperatureCelsius = temperatureCelsius
        self.apparentCelsius = apparentCelsius
        self.precipitationChance = precipitationChance
        self.windKilometersPerHour = windKilometersPerHour
    }

    /// Planning prompts, not severe-weather alerts or safety limits.
    public var advice: [TripWeatherAdvice] {
        var result: [TripWeatherAdvice] = []
        if precipitationChance >= Self.likelyRainProbability { result.append(.rain) }
        if apparentCelsius >= Self.hotApparentCelsius { result.append(.heat) }
        if windKilometersPerHour >= Self.strongWindKilometersPerHour { result.append(.wind) }
        return result
    }
}

public nonisolated enum TripWeatherAdvice: String, Identifiable, Sendable {
    case rain, heat, wind
    public var id: Self { self }
}
