import Foundation
import SwiftUI

/// Model tests supply their own services without starting the live app session.
struct AppEntryView: View {
    var initialTripID: UUID?

    var body: some View {
        if AppTestHost.isEnabled { Color.clear }
        else { ContentView(initialTripID: initialTripID) }
    }
}

enum AppTestHost {
    static var isEnabled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["TRIP_MODEL_TEST_HOST"] == "1"
        #else
        false
        #endif
    }
}

#if DEBUG
#Preview("App entry · live services outside model tests") {
    AppEntryView()
}
#endif
