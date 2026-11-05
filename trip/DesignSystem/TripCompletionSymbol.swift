import SwiftUI
import Symbols

struct TripCompletionSymbol: View {
    let isComplete: Bool
    var revision = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Image(systemName: "circle").foregroundStyle(.secondary)
            if isComplete { checkmark.id(revision) }
        }
        .animation(AppTheme.Motion.selection(reduceMotion: reduceMotion), value: isComplete)
        .animation(AppTheme.Motion.selection(reduceMotion: reduceMotion), value: revision)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var checkmark: some View {
        if reduceMotion { mark }
        else { mark.transition(.symbolEffect(.drawOn)) }
    }

    private var mark: some View {
        Image(systemName: "checkmark").scaleEffect(0.55).foregroundStyle(AppTheme.accent)
    }
}

#Preview("Draw completion and undo") {
    @Previewable @State var complete = false
    Button { complete.toggle() } label: {
        TripCompletionSymbol(isComplete: complete).font(.largeTitle)
    }.padding().accessibilityLabel("Toggle completion")
}
#Preview("Completed · dark, follows system motion setting") {
    TripCompletionSymbol(isComplete: true).font(.largeTitle).padding()
        .preferredColorScheme(.dark)
}
