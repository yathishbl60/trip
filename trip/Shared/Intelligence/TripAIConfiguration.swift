import TripLocalization
import Foundation
import TripDomain

/// Enabled only in builds signed with Apple's approved PCC entitlement.
nonisolated enum TripAIConfiguration {
    static var cloudEnabled: Bool {
        let value = Bundle.main.object(forInfoDictionaryKey: "TripPrivateCloudComputeEnabled")
        if let boolean = value as? Bool { return boolean }
        return ["YES", "TRUE", "1"].contains((value as? String)?.uppercased() ?? "")
    }

    static var availableModes: [TripAIProcessing] {
        cloudEnabled ? TripAIProcessing.allCases : [.onDevice]
    }

    static func issue(for processing: TripAIProcessing) -> String? {
        guard processing == .privateCloudCompute, !cloudEnabled else { return nil }
        return TripText.privateCloudComputeIsnTEnabledInThisVersion.text
    }
}
