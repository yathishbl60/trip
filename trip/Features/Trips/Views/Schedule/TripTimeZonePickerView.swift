import TripLocalization
import SwiftUI

struct TripTimeZonePickerView: View {
    @Binding var selection: String
    @State private var search = TripTimeZoneSearchModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var search = search
        List(search.results, id: \.self, rowContent: zoneRow)
        .overlay {
            if search.results.isEmpty { ContentUnavailableView.search(text: search.query) }
        }
        .searchable(text: $search.query, prompt: Text(TripText.cityOrTimeZone.resource))
        .navigationTitle(TripText.timeZone.resource).navigationBarTitleDisplayMode(.inline)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private func zoneRow(_ zoneID: String) -> some View {
        Button {
            selection = zoneID
            dismiss()
        } label: {
            HStack {
                Text(search.title(zoneID)).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
                Spacer()
                if selection == zoneID { Image(systemName: "checkmark").accessibilityHidden(true) }
            }
        }
        .accessibilityAddTraits(selection == zoneID ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Choose a destination time zone") {
    @Previewable @State var zone = "Asia/Bangkok"
    NavigationStack { TripTimeZonePickerView(selection: $zone) }
}
#Preview("Time zone · large text") {
    @Previewable @State var zone = "America/Los_Angeles"
    NavigationStack { TripTimeZonePickerView(selection: $zone) }
        .frame(width: 280).dynamicTypeSize(.accessibility5)
}
#endif
