import TripLocalization
import SwiftUI
import TripDomain

struct TripChecklistRow: View {
    let item: TripChecklistItem
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Button { controller.toggleChecklistItem(item.id, tripID: tripID) } label: {
            Label {
                Text(item.title).foregroundStyle(item.isComplete ? .secondary : .primary)
                    .strikethrough(item.isComplete)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: { completionSymbol }
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.isComplete ? TripText.done.text : TripText.notDone.text)
        .contextMenu {
            Button(TripText.edit.resource, systemImage: "pencil") { controller.editChecklistItem(in: tripID, item: item) }
        }
    }

    private var completionSymbol: some View {
        TripCompletionSymbol(isComplete: item.isComplete)
    }
}

#if DEBUG
#Preview("Checklist item", traits: .sizeThatFitsLayout) {
    TripChecklistRow(item: TripChecklistItem(title: "Confirm hotel reservations"), tripID: UUID(),
                     controller: TripController(model: PreviewFixtures.tripPlanner())).padding()
}
#Preview("Completed item · large text", traits: .sizeThatFitsLayout) {
    var item = TripChecklistItem(title: "Download offline maps for the whole journey")
    item.isComplete = true
    return TripChecklistRow(item: item, tripID: UUID(), controller: TripController(model: PreviewFixtures.tripPlanner()))
        .padding().dynamicTypeSize(.accessibility2)
}
#endif
