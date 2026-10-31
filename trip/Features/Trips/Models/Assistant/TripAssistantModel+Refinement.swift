import TripLocalization
import TripDomain

extension TripAssistantModel {
    var refinementContext: String {
        guard !days.isEmpty else { return "" }
        let places = selection.selectedPlaces
        let previous = days.map { day in
            let indices = day.stops.compactMap { stop in places.firstIndex { $0.id == stop.place.id } }
            return "Day \(day.number): \(indices)"
        }.joined(separator: "; ")
        return "Previous draft: \(previous). Revision: \(refinement)"
    }

    func refine(_ choice: TripPlanRefinement, source: TripPlan) {
        guard !isGenerating else { return }
        switch choice {
        case .lessTravel: refinement = "Prioritize short distances within each day and fewer cross-area detours."
        case .moreTime:
            guard dayCount < TripLimits.planningDays.upperBound else { return }
            dayCount += 1
            pace = .relaxed
            refinement = "Spread the same places over the extra day, with fewer stops per day."
        case .food:
            focus = .food
            refinement = "Distribute the selected food places across days alongside nearby sights."
        }
        needsNewDraft = true
        generate(from: source)
    }

    var paceWarning: String? {
        let maximum = pace == .relaxed ? 3 : pace == .balanced ? 5 : 7
        guard days.contains(where: { $0.stops.count > maximum }) else { return nil }
        return TripText.someDaysAreBusyForYourChosenPaceTry.text
    }
}

enum TripPlanRefinement { case lessTravel, moreTime, food }
