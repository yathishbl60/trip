import SwiftUI

extension EnvironmentValues {
    @Entry var tripPresentationNamespace: Namespace.ID? = nil
}

struct TripPresentationSource: ViewModifier {
    let id: String
    @Environment(\.tripPresentationNamespace) private var namespace

    @ViewBuilder func body(content: Content) -> some View {
        if let namespace { content.matchedTransitionSource(id: id, in: namespace) }
        else { content }
    }
}

struct TripPresentationZoom: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.navigationTransition(transition)
    }

    private var transition: AnyNavigationTransition {
        if reduceMotion { return AnyNavigationTransition(.crossFade) }
        return AnyNavigationTransition(.zoom(sourceID: id, in: namespace))
    }
}

#Preview("Button to sheet · interactive") {
    @Previewable @Namespace var namespace
    @Previewable @State var presented = false
    Button("Save", systemImage: "bookmark") { presented = true }
        .modifier(TripPresentationSource(id: "save"))
        .environment(\.tripPresentationNamespace, namespace)
        .sheet(isPresented: $presented) {
            Text("Choose a day").padding()
                .presentationDetents([.medium])
                .modifier(TripPresentationZoom(id: "save", namespace: namespace))
        }
}

#Preview("Sheet transition · follows system motion setting") {
    @Previewable @Namespace var namespace
    Text("Choose a day")
        .modifier(TripPresentationZoom(id: "save", namespace: namespace))
}
