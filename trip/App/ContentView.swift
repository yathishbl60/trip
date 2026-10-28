import SwiftUI
import Foundation
struct ContentView: View {
    let initialTripID: UUID?
    @State private var model = AppRuntime.makeScene()

    init(initialTripID: UUID? = nil) { self.initialTripID = initialTripID }

    var body: some View {
        AppShellView(controller: AppController(model: model), initialTripID: initialTripID)
            .focusedSceneValue(model)
    }
}

#Preview("Bangkok · live search") {
    ContentView()
}

#Preview("Dark · live search") {
    ContentView().preferredColorScheme(.dark)
}
