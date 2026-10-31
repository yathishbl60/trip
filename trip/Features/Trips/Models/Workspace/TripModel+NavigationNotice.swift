extension TripModel {
    func showNavigationNotice(_ message: String) {
        if let draft = presentation.editDraft { draft.error = message }
        else if let draft = presentation.eventDraft { draft.error = message }
        else if let draft = presentation.daySchedule { draft.error = message }
        else if let draft = presentation.stopTiming { draft.error = message }
        else if let draft = presentation.planning { draft.notice = message }
        else if presentation.assistantTripID != nil { assistant.error = message }
        else { presentation.notice = message }
    }
}
