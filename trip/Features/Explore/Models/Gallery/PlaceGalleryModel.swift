import Observation
import TripLocalization

@MainActor @Observable final class PlaceGalleryModel {
    let photos: [GalleryPhoto]
    let grid = GalleryGridModel()
    let filmstrip = GalleryFilmstripModel()
    private(set) var isPresented = false
    private(set) var viewer: GalleryPhoto?
    private(set) var focusedID: String?
    private(set) var hidesControls = false
    private(set) var showsInformation = false
    private(set) var isZoomed = false

    init(photos: [GalleryPhoto] = GalleryPhoto.samples) { self.photos = photos }

    var focusedPhoto: GalleryPhoto? { photos.first { $0.id == focusedID } }
    var focusedIndex: Int { photos.firstIndex { $0.id == focusedID } ?? 0 }
    var positionLabel: TripText { .galleryPhotoPosition(focusedIndex + 1, photos.count) }

    func present(_ presented: Bool) {
        isPresented = presented
        guard !presented else { return }
        grid.suspendInteraction()
        filmstrip.setScrubbing(false)
        closeViewer()
    }

    func open(_ photo: GalleryPhoto) {
        guard photos.contains(where: { $0.id == photo.id }) else { return }
        grid.suspendInteraction()
        isZoomed = false
        showsInformation = false
        focusedID = photo.id
        filmstrip.follow(photo.id)
        hidesControls = false
        viewer = photo
    }

    func select(_ id: String?) {
        guard let id, photos.contains(where: { $0.id == id }) else { return }
        if id != focusedID { isZoomed = false }
        focusedID = id
        filmstrip.follow(id)
    }

    func closeViewer() {
        filmstrip.setScrubbing(false)
        grid.reveal(focusedID)
        viewer = nil
        isZoomed = false
        hidesControls = false
        showsInformation = false
    }

    func move(_ offset: Int) {
        let index = min(max(focusedIndex + offset, 0), photos.count - 1)
        guard photos.indices.contains(index) else { return }
        select(photos[index].id)
    }

    func toggleControls() { hidesControls.toggle() }
    func showInformation(_ show: Bool) { showsInformation = show }
    func setZoomed(_ zoomed: Bool) {
        isZoomed = zoomed
        if zoomed { hidesControls = true }
    }

    func setZoomed(_ zoomed: Bool, photoID: String) {
        guard focusedID == photoID, viewer != nil else { return }
        setZoomed(zoomed)
    }

    func scrub(to id: String?) {
        filmstrip.position = id
        if filmstrip.isScrubbing { select(id) }
    }
}
