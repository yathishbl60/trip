import Foundation

extension AppModel {
    func request(_ request: AppRequest) {
        let generation = navigation.beginRequest()
        guard allowNavigation() else { return }
        guard request.requiresLibrary, !trips.library.isReady else {
            deliver(request, generation: generation)
            return
        }
        navigation.requestTask = Task { [weak self] in
            guard let self else { return }
            await resolve(request, generation: generation)
        }
    }

    func resolve(_ request: AppRequest, generation: Int) async {
        if request.requiresLibrary { await trips.library.load() }
        guard navigation.accepts(generation) else { return }
        deliver(request, generation: generation)
        if navigation.accepts(generation) { navigation.requestTask = nil }
    }

    private func deliver(_ request: AppRequest, generation: Int) {
        guard navigation.accepts(generation), allowNavigation() else { return }
        guard !request.requiresLibrary || trips.library.isReady else {
            if case .destination(.restoration) = request.operation { return }
            navigation.notice = TripIntentError.libraryUnavailable.errorDescription
            return
        }
        switch request.operation {
        case .destination(let destination): openDestination(destination)
        case .workflow(let workflow): openWorkflow(workflow)
        }
    }
}
