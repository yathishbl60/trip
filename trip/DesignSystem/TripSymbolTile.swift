import SwiftUI

struct TripSymbolTile: View {
    let symbol: String
    var color: Color = AppTheme.accent

    var body: some View {
        Image(systemName: symbol)
            .font(.title3.weight(.medium))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(color)
            .frame(width: 44, height: 44)
            .background(color.opacity(0.12), in: .rect(cornerRadius: 12))
            .accessibilityHidden(true)
    }
}

#Preview("Navigation symbols", traits: .sizeThatFitsLayout) {
    HStack(spacing: 16) {
        TripSymbolTile(symbol: "map")
        TripSymbolTile(symbol: "checklist")
        TripSymbolTile(symbol: "sparkles")
    }.padding()
}
#Preview("Navigation symbols · dark", traits: .sizeThatFitsLayout) {
    TripSymbolTile(symbol: "square.stack").padding().preferredColorScheme(.dark)
}
