import SwiftUI
import CoreGraphics

/// Stable pane identity inside NavigationSplitView, including collapsed and folded windows.
struct TripMapLayout<Primary: View, Detail: View>: View {
    private let primary: Primary
    private let detail: Detail
    private let reservedDivision: CGRect?
    @ScaledMetric(relativeTo: .body) private var listHeight: CGFloat = 240

    init(reservedDivision: CGRect? = nil, @ViewBuilder primary: () -> Primary, @ViewBuilder detail: () -> Detail) {
        self.primary = primary()
        self.detail = detail()
        self.reservedDivision = reservedDivision
    }

    var body: some View {
        GeometryReader { geometry in
            panes(TripMapLayoutMetrics(size: geometry.size, listHeight: listHeight,
                division: reservedDivision ?? TripMapLayoutMetrics.division(in: geometry)))
        }
    }

    private func panes(_ metrics: TripMapLayoutMetrics) -> some View {
        let layout = metrics.horizontal ? AnyLayout(HStackLayout(spacing: metrics.spacing))
            : AnyLayout(VStackLayout(spacing: metrics.spacing))
        return layout {
            primary.frame(width: metrics.horizontal ? metrics.primaryLength : nil,
                          height: metrics.horizontal ? nil : metrics.primaryLength)
            detail.frame(width: metrics.horizontal ? metrics.detailLength : nil,
                         height: metrics.horizontal ? nil : metrics.detailLength)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Map and details · narrow") {
    TripMapLayout {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: {
        List(1...10, id: \.self) { Text("Stop \($0)") }
    }.frame(width: 320, height: 560)
}
#Preview("Map and details · wide, large text") {
    TripMapLayout {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: {
        List(1...10, id: \.self) { Text("Stop \($0)") }
    }.frame(width: 1000, height: 650).dynamicTypeSize(.accessibility2)
}
#Preview("Map and details · short window") {
    TripMapLayout {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: {
        List(1...10, id: \.self) { Text("Stop \($0)") }
    }.frame(width: 600, height: 280)
}

#Preview("Map and details · simulated book division") {
    TripMapLayout(reservedDivision: CGRect(x: 350, y: 0, width: 28, height: 600)) {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: { List(1...10, id: \.self) { Text("Stop \($0)") } }
        .frame(width: 740, height: 600)
}
#Preview("Map and details · simulated tabletop division") {
    TripMapLayout(reservedDivision: CGRect(x: 0, y: 320, width: 600, height: 28)) {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: { List(1...10, id: \.self) { Text("Stop \($0)") } }
        .frame(width: 600, height: 700).dynamicTypeSize(.accessibility1)
}

#Preview("Map and details · simulated book, right to left") {
    TripMapLayout(reservedDivision: CGRect(x: 350, y: 0, width: 28, height: 600)) {
        Color.teal.opacity(0.2).overlay { Label("Map", systemImage: "map") }
    } detail: { List(1...10, id: \.self) { Text("Stop \($0)") } }
        .frame(width: 740, height: 600).environment(\.layoutDirection, .rightToLeft)
}
