import Foundation

struct GamePreferences: Codable, Equatable {
    var pencilModeEnabledByDefault: Bool

    static let `default` = GamePreferences(pencilModeEnabledByDefault: true)
}
