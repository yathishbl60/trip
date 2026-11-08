#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsOptionsView: View {
    let controller: DirectionsController
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var preferredHeight = 360.0

    var body: some View {
        NavigationStack {
            options
            .navigationTitle(TripText.routeOptions.resource).navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(role: .close) { dismiss() } } }
        }
        .frame(idealWidth: 350, idealHeight: preferredHeight)
        .presentationSizing(.form.fitted(horizontal: true, vertical: true))
        #if os(iOS)
        .presentationCompactAdaptation(.sheet)
        #endif
    }

    private var options: some View {
        Form {
            if controller.model.mode.supportsAvoidance {
                Section(TripText.avoid.resource) {
                    Toggle(TripText.tolls.resource, isOn: controller.avoidsTolls)
                    Toggle(TripText.highways.resource, isOn: controller.avoidsHighways)
                }
            }
            travelTime
        }
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
