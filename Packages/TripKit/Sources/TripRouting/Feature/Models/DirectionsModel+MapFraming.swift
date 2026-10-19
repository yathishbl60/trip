#if os(iOS) || os(visionOS)
import Foundation

extension DirectionsModel {
    /// Coalesce result and sheet geometry changes without retaining the host's map proxy.
    public func scheduleRouteFit(isActive: @escaping () -> Bool, fit: @escaping () -> Void) {
        cancelRouteFit()
        guard isActive(), status == .ready, presentation.needsRouteFraming else { return }
        framingTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(180))
                guard let self, !Task.isCancelled, isActive(), presentation.needsRouteFraming else { return }
                fit()
            } catch { /* Superseded by a sheet change, selection, or map gesture. */ }
        }
    }

    public func cancelRouteFit() { framingTask?.cancel() }
}
#endif
