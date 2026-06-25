import Foundation

struct GameFeedbackSettings: Codable, Equatable {
    var hapticsEnabled: Bool
    var soundsEnabled: Bool

    static let `default` = GameFeedbackSettings(hapticsEnabled: true, soundsEnabled: true)
}
