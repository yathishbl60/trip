import TripLocalization
import SwiftUI
import TripDomain

struct TripSaveDestinationRow: View {
    let title: String
    let detail: String
    let symbol: String
    let availability: TripStopAvailability
    var showsAddIndicator = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) { content }
            .buttonStyle(.plain)
            .disabled(availability != .available)
    }

    private var content: some View {
        HStack(spacing: 12) {
            TripSymbolTile(symbol: symbol)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).foregroundStyle(.primary)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2).fixedSize(horizontal: false, vertical: true)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if availability == .alreadySaved { Image(systemName: "checkmark").accessibilityHidden(true) }
            else if showsAddIndicator, availability == .available {
                Image(systemName: "plus.circle.fill").foregroundStyle(AppTheme.accent).accessibilityHidden(true)
            }
        }
        .frame(minHeight: AppTheme.controlTarget, alignment: .leading)
        .contentShape(.rect)
    }

    private var subtitle: String {
        switch availability {
        case .available: detail
        case .alreadySaved: TripText.alreadySaved.text
        case .full: TripText.fullValuePlaces(TripText.number(TripLimits.stops)).text
        }
    }
}

#Preview("Save destinations") {
    List {
        TripSaveDestinationRow(title: "Day 1", detail: "Friday, October 9", symbol: "calendar",
                               availability: .available, action: {})
        TripSaveDestinationRow(title: "Favorite cafes", detail: "3 places", symbol: "square.stack",
                               availability: .alreadySaved, action: {})
        TripSaveDestinationRow(title: "Ideas", detail: "100 places", symbol: "square.stack",
                               availability: .full, action: {})
    }
}
