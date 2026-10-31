import TripLocalization
import SwiftUI
import TripDomain

struct TripTimeAllocation: Identifiable {
    enum Kind: String, CaseIterable { case visits, travel, betweenVisits, open }
    let kind: Kind
    let minutes: Int
    let start: Int
    var id: Kind { kind }
    var end: Int { start + minutes }

    var title: String {
        switch kind {
        case .visits: TripText.visits.text
        case .travel: TripText.travel.text
        case .betweenVisits: TripText.bufferGaps.text
        case .open: TripText.openTime.text
        }
    }

    var color: Color {
        switch kind {
        case .visits: AppTheme.accent
        case .travel: .secondary
        case .betweenVisits: .orange
        case .open: .gray.opacity(0.25)
        }
    }

    var symbol: String {
        switch kind {
        case .visits: "mappin"
        case .travel: "arrow.triangle.swap"
        case .betweenVisits: "clock"
        case .open: "sun.horizon"
        }
    }

    static func segments(_ budget: TripTimeBudget) -> [Self] {
        let values = [budget.visits, budget.travel, budget.betweenVisits, budget.open]
        var cursor = 0
        return zip(Kind.allCases, values).compactMap { kind, minutes in
            defer { cursor += minutes }
            return minutes > 0 ? Self(kind: kind, minutes: minutes, start: cursor) : nil
        }
    }
}
