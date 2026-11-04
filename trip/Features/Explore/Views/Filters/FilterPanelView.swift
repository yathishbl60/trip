import TripLocalization
import TripDomain
import SwiftUI

struct FilterPanelView: View {
    let controller: FilterController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            categories.navigationTitle(TripText.filters.resource).navigationBarTitleDisplayMode(.inline).toolbar { tools }
                #if os(iOS)
                .scrollEdgeEffectStyle(.soft, for: .top)
                #endif
        }
        .presentationDetents(typeSize.isAccessibilitySize ? [.large] : [.medium, .large])
        .presentationSizing(.form)
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.selection, trigger: controller.model.filters.selected)
    }

    @ViewBuilder private var categories: some View {
        if typeSize.isAccessibilitySize {
            categoryList
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacing) {
                    CategoryChipsView(controller: controller)
                    footer.font(.footnote).foregroundStyle(.secondary)
                }.padding()
            }
        }
    }

    private var categoryList: some View {
        List {
            Section {
                allPlaces
                ForEach(controller.model.filters.rows) { row in
                    CategoryFilterRow(row: row, controller: controller)
                }
            } footer: { footer }
        }
    }

    private var footer: some View {
        Text(TripText.valueCountsIncludePlacesOutsideTheVisibleMap(controller.model.filters.loadedPlacesDescription).resource)
    }

    private var allPlaces: some View {
        Button(action: controller.clear) {
            HStack {
                Label(TripText.allCategories.resource, systemImage: "square.grid.2x2")
                Spacer()
                if controller.model.filters.allSelected { Image(systemName: "checkmark.circle.fill") }
            }
            .foregroundStyle(AppTheme.accent).frame(minHeight: AppTheme.controlTarget).contentShape(.rect)
        }
        .accessibilityAddTraits(controller.model.filters.allSelected ? .isSelected : [])
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.showPlaces.resource, action: controller.dismiss).buttonStyle(TripButtonStyles.prominent)
                .tint(AppTheme.accentFill)
        }
    }
}

#if DEBUG
#Preview("All categories") {
    FilterPanelView(controller: FilterController(model: PreviewFixtures.explore()))
}
#Preview("Multiple filters · dark") {
    FilterPanelView(controller: FilterController(model: PreviewFixtures.explore(categories: [.hotel, .cafe])))
        .preferredColorScheme(.dark)
}
#Preview("Filters · accessibility") {
    FilterPanelView(controller: FilterController(model: PreviewFixtures.explore()))
        .dynamicTypeSize(.accessibility2)
}
#Preview("Filters · short window") {
    FilterPanelView(controller: FilterController(model: PreviewFixtures.explore()))
        .frame(width: 680, height: 320).dynamicTypeSize(.accessibility1)
}
#endif
