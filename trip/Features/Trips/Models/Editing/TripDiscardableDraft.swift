/// Draft-owned dismissal state shared by focused trip editors.
@MainActor protocol TripDiscardableDraft: AnyObject {
    var hasUnsavedChanges: Bool { get }
    var isDiscarding: Bool { get set }
}
