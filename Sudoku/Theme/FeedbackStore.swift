import SwiftUI

@Observable
@MainActor
final class FeedbackStore {
    private let persistence: PersistenceServiceProtocol

    var hapticsEnabled: Bool {
        didSet { persistAndSync() }
    }

    var soundsEnabled: Bool {
        didSet { persistAndSync() }
    }

    init(persistence: PersistenceServiceProtocol = PersistenceService()) {
        self.persistence = persistence
        let settings = persistence.loadFeedbackSettings()
        self.hapticsEnabled = settings.hapticsEnabled
        self.soundsEnabled = settings.soundsEnabled
        GameFeedbackService.shared.applySettings(settings)
    }

    private func persistAndSync() {
        let settings = GameFeedbackSettings(
            hapticsEnabled: hapticsEnabled,
            soundsEnabled: soundsEnabled
        )
        persistence.saveFeedbackSettings(settings)
        GameFeedbackService.shared.applySettings(settings)
    }
}
