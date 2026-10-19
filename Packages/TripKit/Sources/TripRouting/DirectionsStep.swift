import MapKit

public nonisolated struct DirectionsStep: Identifiable, Sendable {
    public let id: Int
    public let instruction: String
    public let distance: Double
    public let notice: String?

    public init(id: Int, instruction: String, distance: Double, notice: String? = nil) {
        self.id = id
        self.instruction = instruction
        self.distance = distance
        self.notice = notice
    }

    init?(_ value: (offset: Int, element: MKRoute.Step)) {
        guard !value.element.instructions.isEmpty else { return nil }
        self.init(id: value.offset, instruction: value.element.instructions,
                  distance: value.element.distance, notice: value.element.notice)
    }
}
