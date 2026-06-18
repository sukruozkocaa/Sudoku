import Foundation

protocol PersistenceServiceProtocol {
    func loadProgress() -> GameProgress?
    func saveProgress(_ progress: GameProgress)
    func clearProgress()
    var hasSeenHowToPlay: Bool { get }
    func markHowToPlaySeen()
}

final class PersistenceService: PersistenceServiceProtocol {
    private let progressKey = "sudoku.game.progress"
    private let howToPlaySeenKey = "sudoku.howToPlay.seen"

    var hasSeenHowToPlay: Bool {
        UserDefaults.standard.bool(forKey: howToPlaySeenKey)
    }

    func markHowToPlaySeen() {
        UserDefaults.standard.set(true, forKey: howToPlaySeenKey)
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
