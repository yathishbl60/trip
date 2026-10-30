import TripLocalization
#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

/// Pure annotation artwork: MapKit owns selection and gesture recognition.
struct PlaceMarkerView: View {
    let place: Place
    let style: MarkerStyle
    var scale: CGFloat = 1
    var isSelected = false
    var includesPhoto = true
    var includesLabel = true
    var animatesChanges = true
    var motion = MapMotion()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let size = style.hitSize(scale: scale)
        PhotoMarkerView(place: place, style: style, isSelected: isSelected,
                        includesPhoto: includesPhoto && place.hasAnnotationPhoto, includesLabel: includesLabel)
            .equatable()
            .scaleEffect(scale)
            .frame(width: size.width, height: size.height)
            .contentShape(.rect(cornerRadius: style.surfaceRadius * scale))
            .animation(reduceMotion || !animatesChanges ? nil : .easeInOut(duration: motion.morph), value: style)
            .animation(reduceMotion || !animatesChanges ? nil : .easeInOut(duration: motion.selection), value: isSelected)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(place.accessibilityLabel)
            .accessibilityHint(TripText.showPlaceDetails.resource)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#if DEBUG
#Preview("Three zoom appearances", traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 20) {
        ForEach(MarkerStyle.allCases, id: \.self) { style in
            PlaceMarkerView(place: PreviewFixtures.hotel, style: style, scale: 1)
        }
    }
    .padding(24)
}
#Preview("Large text · long name", traits: .sizeThatFitsLayout) {
    PlaceMarkerView(place: PreviewFixtures.longName, style: .card, scale: 1.5)
        .padding(24)
}
#Preview("Unrated card · dark", traits: .sizeThatFitsLayout) {
    PlaceMarkerView(place: PreviewFixtures.unrated, style: .card, scale: 1)
        .padding(24).preferredColorScheme(.dark)
}
#Preview("Dot · image · view", traits: .sizeThatFitsLayout) {
    @Previewable @State var style = MarkerStyle.dot
    VStack(spacing: 20) {
        PlaceMarkerView(place: PreviewFixtures.hotel, style: style, scale: 1)
            .frame(height: 110)
        Picker("Appearance", selection: $style) {
            ForEach(MarkerStyle.allCases, id: \.self) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
    }
    .frame(width: 360).padding()
}
#Preview("Icon without a photo", traits: .sizeThatFitsLayout) {
    PlaceMarkerView(place: PreviewFixtures.unrated, style: .thumbnail).padding(24)
}
#Preview("Selection · each appearance", traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 20) {
        ForEach(MarkerStyle.allCases, id: \.self) { style in
            PlaceMarkerView(place: PreviewFixtures.hotel, style: style, isSelected: true)
        }
    }
    .padding(28)
}
#Preview("Select a place · stable marker footprint", traits: .sizeThatFitsLayout) {
    @Previewable @State var isSelected = false
    VStack(spacing: 24) {
        ForEach(MarkerStyle.allCases, id: \.self) { style in
            PlaceMarkerView(place: PreviewFixtures.hotel, style: style, isSelected: isSelected)
        }
        Toggle("Selected", isOn: $isSelected)
    }.padding(28).frame(width: 300).preferredColorScheme(.dark)
}
#endif
