import Foundation

protocol PersistenceServiceProtocol {
    func loadProgress() -> GameProgress?
    func saveProgress(_ progress: GameProgress)
    func clearProgress()
    var hasSeenHowToPlay: Bool { get }
    func markHowToPlaySeen()
    func loadAppearance() -> AppAppearance
    func saveAppearance(_ appearance: AppAppearance)
}

final class PersistenceService: PersistenceServiceProtocol {
    private let progressKey = "sudoku.game.progress"
    private let howToPlaySeenKey = "sudoku.howToPlay.seen"
    private let appearanceKey = "sudoku.appearance"

    var hasSeenHowToPlay: Bool {
        UserDefaults.standard.bool(forKey: howToPlaySeenKey)
    }

    func markHowToPlaySeen() {
        UserDefaults.standard.set(true, forKey: howToPlaySeenKey)
    }

    func loadAppearance() -> AppAppearance {
        guard let rawValue = UserDefaults.standard.string(forKey: appearanceKey),
              let appearance = AppAppearance(rawValue: rawValue) else {
            return .system
        }
        return appearance
    }

    func saveAppearance(_ appearance: AppAppearance) {
        UserDefaults.standard.set(appearance.rawValue, forKey: appearanceKey)
    }

    func loadProgress() -> GameProgress? {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else { return nil }
        return try? JSONDecoder().decode(GameProgress.self, from: data)
    }

    func saveProgress(_ progress: GameProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }

    func clearProgress() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }
}
