import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func eventDay(_ keyPath: WritableKeyPath<TripEvent, UUID>, draft: TripEventDraft) -> Binding<UUID> {
        Binding(get: { draft.event[keyPath: keyPath] }, set: { draft.setDay($0, at: keyPath) })
    }

    func eventValue<Value>(_ keyPath: WritableKeyPath<TripEvent, Value>, draft: TripEventDraft) -> Binding<Value> {
        Binding(get: { draft.event[keyPath: keyPath] }, set: { draft.set($0, at: keyPath) })
    }

    func eventText(_ keyPath: WritableKeyPath<TripEvent, String>, draft: TripEventDraft) -> Binding<String> {
        Binding(get: { draft.event[keyPath: keyPath] }, set: { draft.setText($0, at: keyPath) })
    }

    func eventTime(_ keyPath: WritableKeyPath<TripEvent, Int?>, draft: TripEventDraft) -> Binding<Date> {
        Binding(get: { draft.time(for: keyPath) }, set: { draft.setTime($0, at: keyPath) })
    }

    func eventTimeEnabled(_ keyPath: WritableKeyPath<TripEvent, Int?>, draft: TripEventDraft) -> Binding<Bool> {
        Binding(get: { draft.event[keyPath: keyPath] != nil }, set: { draft.setTimeEnabled($0, at: keyPath) })
    }
}
