import SwiftUI
import TripDomain
import Foundation

struct TripLibraryArtworkView: View {
    let category: PlaceCategory?
    let date: Date
    var timeZone: TimeZone = .current
    @ScaledMetric(relativeTo: .body) private var size = 64.0

    var body: some View {
        VStack(spacing: AppTheme.Spacing.compact) {
            Text(date, format: Date.FormatStyle(timeZone: timeZone).month(.abbreviated)).font(.caption.weight(.semibold))
            Text(date, format: Date.FormatStyle(timeZone: timeZone).day()).font(.title2.bold().monospacedDigit())
        }
            .foregroundStyle(category?.color ?? AppTheme.accent)
            .frame(width: size, height: size)
            .background((category?.color ?? AppTheme.accent).opacity(0.12), in: .rect(cornerRadius: 18))
            .accessibilityHidden(true)
    }
}

#Preview("Trip artwork", traits: .sizeThatFitsLayout) {
    let date = Date(timeIntervalSince1970: 1_791_676_800)
    HStack {
        TripLibraryArtworkView(category: .hotel, date: date)
        TripLibraryArtworkView(category: .park, date: date)
        TripLibraryArtworkView(category: nil, date: date)
    }.padding()
}
#Preview("Trip artwork · dark", traits: .sizeThatFitsLayout) {
    TripLibraryArtworkView(category: .attraction, date: Date(timeIntervalSince1970: 1_791_676_800))
        .padding().preferredColorScheme(.dark)
}
