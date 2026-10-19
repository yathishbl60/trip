#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsOptionsView: View {
    let controller: DirectionsController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            Form {
                if controller.model.mode.supportsAvoidance {
                    Section(TripText.avoid.resource) {
                        Toggle(TripText.tolls.resource, isOn: controller.avoidsTolls)
                        Toggle(TripText.highways.resource, isOn: controller.avoidsHighways)
                    }
                }
                travelTime
            }
            .navigationTitle(TripText.routeOptions.resource).navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(TripText.done.resource) { dismiss() } } }
        }
        .presentationDetents(typeSize.isAccessibilitySize ? [.large] : [.medium, .large])
    }

    private var travelTime: some View {
        Section {
            Picker(TripText.travelTime.resource, selection: controller.timing) {
                ForEach(DirectionsTiming.allCases) { Text($0.title).tag($0) }
            }
            if controller.model.options.timing != .now {
                DatePicker(controller.model.options.timing.title, selection: controller.date, in: Date.now...)
            }
        } header: {
            Text(TripText.travelTime.resource)
        } footer: {
            if controller.model.options.timing != .now {
                Text(TripText.estimatesUseThisTimeSetItAgainInApple.resource)
            }
        }
    }
}

#if DEBUG
#Preview("Driving options") {
    DirectionsOptionsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
}
#Preview("Arrive by") {
    let model = DirectionsPreviewFixtures.ready()
    model.options.timing = .arriveBy
    return DirectionsOptionsView(controller: DirectionsController(model: model))
}
#endif
#endif
