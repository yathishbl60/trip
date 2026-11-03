import SwiftUI

struct AnnotationGalleryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            heading
            progression
            selection
            edgeCases
            Text("Rendered from the app’s SwiftUI components. Photos and ratings are illustrative samples.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(36)
        .frame(width: 820)
        .background(.background.secondary)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Places, at a glance").font(.largeTitle.bold())
            Text("A quieter overview. More detail as you get closer.").foregroundStyle(.secondary)
        }
    }

    private var progression: some View {
        HStack(alignment: .center, spacing: 24) {
            ForEach(MarkerStyle.allCases, id: \.self) { style in
                VStack(spacing: 12) {
                    PlaceMarkerView(place: AnnotationGalleryData.hotel, style: style).frame(height: 100)
                    Text(style.title).font(.caption.weight(.medium)).foregroundStyle(.secondary)
                }
            }
        }
    }

    private var selection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Easy to find again").font(.headline)
            HStack(spacing: 26) {
                PlaceMarkerView(place: AnnotationGalleryData.cafe, style: .card)
                PlaceMarkerView(place: AnnotationGalleryData.hotel, style: .card, isSelected: true)
                PlaceMarkerView(place: AnnotationGalleryData.park, style: .thumbnail, includesPhoto: false)
            }
        }
    }

    private var edgeCases: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Long names, missing ratings, larger text").font(.headline)
            HStack(spacing: 20) {
                PlaceMarkerView(place: AnnotationGalleryData.longName, style: .card)
                PlaceMarkerView(place: AnnotationGalleryData.unrated, style: .card)
                PlaceMarkerView(place: AnnotationGalleryData.cafe, style: .card, scale: 1.5)
            }
        }
    }
}

#if DEBUG
#Preview("Annotation gallery · light") { AnnotationGalleryView() }
#Preview("Annotation gallery · dark") { AnnotationGalleryView().preferredColorScheme(.dark) }
#endif
