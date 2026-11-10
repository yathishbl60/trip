import TripLocalization
import SwiftUI
import TripDomain

struct AppShellView: View {
    let controller: AppController
    var initialTripID: UUID? = nil

    var body: some View {
        adaptiveTabs
        .tint(AppTheme.accent)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .ignoresSafeArea(controller.model.navigation.tab == .explore ? .keyboard : [], edges: .bottom)
        .modifier(AppSceneLifecycle(controller: controller, initialTripID: initialTripID))
        .modifier(AppNavigationFeedback(controller: controller))
        .onChange(of: AppLaunchModel.shared.revision) { controller.consumeLaunch() }
        .onOpenURL(perform: controller.openURL)
        .safeAreaInset(edge: .top, spacing: 0) { persistenceStatus }
    }

    private var adaptiveTabs: some View {
        tabs
            .tabViewStyle(.sidebarAdaptable)
            #if os(iOS)
            .defaultTabBarPlacement(.tabBar)
            .defaultAdaptableTabBarPlacement(.sidebar)
            #else
            .defaultTabBarPlacement(.sidebar)
            #endif
    }

    private var tabs: some View {
        TabView(selection: controller.tab) {
            Tab(TripText.trips.resource, systemImage: "suitcase.rolling", value: AppTab.trips) {
                TripManagerView(controller: TripController(model: controller.model.trips))
                    .safeAreaInset(edge: .bottom, spacing: 0) { tripFeedback }
            }
            Tab(TripText.explore.resource, systemImage: "map", value: AppTab.explore) { explore }
        }
    }

    private var persistenceStatus: some View {
        TripPersistenceStatusView(controller: TripController(model: controller.model.trips))
    }

    private var tripFeedback: some View {
        TripFeedbackView(model: controller.model.trips.feedback)
            .padding(.bottom, controller.model.trips.feedback.message == nil ? 0 : AppTheme.Spacing.small)
    }

    private var explore: some View {
        AppExploreView(controller: controller)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if controller.model.explore.selectedPlace == nil { tripFeedback }
            }
    }
}

#if DEBUG
#Preview("Explore and Trips · local data") {
    AppShellView(controller: AppController(model: PreviewFixtures.app()))
}
#Preview("Trips · dark") {
    let model = PreviewFixtures.app()
    model.navigation.tab = .trips
    return AppShellView(controller: AppController(model: model)).preferredColorScheme(.dark)
}
#Preview("Screenshot regression · empty trip, native tabs, local data") {
    let trips = TripLayoutPreview.emptyPlanner()
    let model = AppModel(explore: PreviewFixtures.explore(), trips: trips)
    model.navigation.tab = .trips
    return AppShellView(controller: AppController(model: model), initialTripID: trips.library.trips[0].id)
        .frame(width: 393, height: 852).preferredColorScheme(.dark)
}
#Preview("Trips · short window, right to left") {
    let model = PreviewFixtures.app()
    model.navigation.tab = .trips
    return AppShellView(controller: AppController(model: model))
        .frame(width: 740, height: 340).environment(\.layoutDirection, .rightToLeft)
        .dynamicTypeSize(.accessibility1)
}
#Preview("Trips · wide split navigation with app tabs") {
    let model = PreviewFixtures.app()
    model.navigation.tab = .trips
    return AppShellView(controller: AppController(model: model))
        .frame(width: 1100, height: 800)
}
#Preview("Explore · retained trip selection, local data") {
    let model = PreviewFixtures.app()
    model.trips.selectTrip(model.trips.library.trips.first?.id)
    model.navigation.tab = .explore
    model.navigation.didRestore = true
    return AppShellView(controller: AppController(model: model)).frame(width: 1000, height: 700)
}
#endif
