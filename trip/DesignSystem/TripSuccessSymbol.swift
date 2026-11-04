import SwiftUI

/// Starts a single confirmation after the successful action enters the hierarchy.
struct TripSuccessSymbol: View {
    let revision: Int
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TripCompletionSymbol(isComplete: reduceMotion || revealed, revision: revision)
            .task(id: revision) {
                revealed = false
                await Task.yield()
                guard !Task.isCancelled else { return }
                revealed = true
            }
    }
}

#Preview("Repeat successful action") {
    @Previewable @State var revision = 0
    Button { revision += 1 } label: {
        Label { Text("Save again") } icon: { TripSuccessSymbol(revision: revision) }
    }.padding()
}
#Preview("Success · follows system motion setting") {
    TripSuccessSymbol(revision: 1).padding()
}
