import Foundation
import Observation

@MainActor @Observable final class TripFeedbackModel {
    var message: String?
    var revision = 0
    @ObservationIgnored private var dismissal: Task<Void, Never>?

    func show(_ message: String) {
        dismissal?.cancel()
        self.message = message
        revision += 1
        dismissal = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(3)) }
            catch { return }
            self?.message = nil
        }
    }
}
