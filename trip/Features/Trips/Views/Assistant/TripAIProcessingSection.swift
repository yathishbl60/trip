import TripLocalization
import SwiftUI
import TripDomain

struct TripAIProcessingSection: View {
    @Binding var selection: TripAIProcessing
    let explanation: String
    let availableModes: [TripAIProcessing]

    var body: some View {
        Section {
            if availableModes.count > 1 {
                Picker(TripText.processing.resource, selection: $selection) {
                    ForEach(availableModes) { mode in Text(mode.title).tag(mode) }
                }
            } else { LabeledContent(TripText.processing.resource, value: selection.title) }
        } header: { Text(TripText.appleIntelligence.resource) } footer: {
            Text(explanation)
        }
    }
}

#if DEBUG
#Preview("Processing · on device") {
    @Previewable @State var mode = TripAIProcessing.onDevice
    Form { TripAIProcessingSection(selection: $mode, explanation: mode.lookupExplanation, availableModes: [.onDevice]) }
}
#Preview("Processing · entitled cloud build and large text") {
    @Previewable @State var mode = TripAIProcessing.privateCloudCompute
    Form { TripAIProcessingSection(selection: $mode, explanation: mode.planningExplanation, availableModes: TripAIProcessing.allCases) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
