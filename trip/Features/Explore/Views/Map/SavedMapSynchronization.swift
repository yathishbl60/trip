import SwiftUI

struct SavedMapSynchronization: ViewModifier {
    let controller: SavedMapController

    func body(content: Content) -> some View {
        let request = controller.request
        content.task(id: request) { await controller.refresh(request) }
    }
}

#if DEBUG
#Preview("Saved map synchronization · local") {
    Color.clear.modifier(SavedMapSynchronization(controller: SavedMapController(model: PreviewFixtures.explore())))
}
#endif
