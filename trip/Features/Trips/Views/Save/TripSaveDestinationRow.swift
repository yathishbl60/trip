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

    var body: some View {
        Button(action: action) { content }
            .buttonStyle(.plain)
            .disabled(availability != .available)
    }

    private var content: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            TripPlaceLabel(title: title, subtitle: subtitle, symbol: symbol, color: AppTheme.accent)
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

#Preview("Save destination · long name, accessibility") {
    List {
        TripSaveDestinationRow(title: "A weekend exploring the riverside", detail: "Friday, October 9",
                               symbol: "calendar", availability: .available, action: {})
    }.frame(width: 320).dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
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
