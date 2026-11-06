import Foundation
import SwiftUI
import TripDomain
import TripLocalization

struct TripWeatherAttributionView: View {
    private static let markSize = CGSize(width: 100, height: 22)
    let attribution: TripWeatherAttribution
    let issuedAt: Date?
    var coverage: DateInterval?
    var timeZone: TimeZone = .current
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Section {
            attributionLink
            if let issuedAt {
                LabeledContent(TripText.weatherIssuedAt.resource) {
                    Text(issuedAt, format: dateFormat)
                }.font(.footnote).foregroundStyle(.secondary)
            }
            if let coverage {
                LabeledContent(TripText.weatherAvailableHours.resource) {
                    Text("\(coverage.start, format: dateFormat) – \(coverage.end, format: dateFormat)")
                }.font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private var attributionLink: some View {
        Link(destination: attribution.legalURL) {
            HStack {
                mark
                Spacer()
                Text(TripText.weatherDataSources.resource).font(.footnote)
            }
        }
    }

    private var dateFormat: Date.FormatStyle {
        Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: timeZone)
    }

    private var mark: some View {
        AsyncImage(url: colorScheme == .dark ? attribution.darkMarkURL : attribution.lightMarkURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Text(verbatim: " Weather").font(.headline)
        }
        .frame(width: Self.markSize.width, height: Self.markSize.height)
        .accessibilityLabel(TripText.weatherAppleWeather.resource)
    }
}

#if DEBUG
#Preview("Apple Weather attribution") {
    List { TripWeatherAttributionView(attribution: TripWeatherPreview.attribution, issuedAt: TripWeatherPreview.date) }
}
#endif
