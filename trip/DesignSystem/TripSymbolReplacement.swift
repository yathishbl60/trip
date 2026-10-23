import SwiftUI
import Symbols

private struct TripSymbolReplacement<Value: Equatable>: ViewModifier {
    let value: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: value)
    }
}

extension View {
    func tripSymbolReplacement<Value: Equatable>(value: Value) -> some View {
        modifier(TripSymbolReplacement(value: value))
    }
}

#Preview("Checklist symbol replacement", traits: .sizeThatFitsLayout) {
    @Previewable @State var selected = false
    Button { selected.toggle() } label: {
        Label {
            Text(selected ? "Complete" : "Mark complete")
        } icon: {
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .tripSymbolReplacement(value: selected)
        }
    }.padding()
}

#Preview("Replacement · Reduce Motion", traits: .sizeThatFitsLayout) {
    @Previewable @State var selected = false
    Button { selected.toggle() } label: {
        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
            .tripSymbolReplacement(value: selected)
    }
    .accessibilityLabel("Toggle selection")
    .padding().preferredColorScheme(.dark)
}
