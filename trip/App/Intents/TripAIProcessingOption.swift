import AppIntents
import TripDomain

enum TripAIProcessingOption: String, AppEnum {
    case onDevice, privateCloudCompute
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "ai_processing") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.onDevice: DisplayRepresentation(title: "on_device"), .privateCloudCompute: DisplayRepresentation(title: "apple_private_cloud_compute")]
    }
    var processing: TripAIProcessing { TripAIProcessing(rawValue: rawValue) ?? .onDevice }
}
