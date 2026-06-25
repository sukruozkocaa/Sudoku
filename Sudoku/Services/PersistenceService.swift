import Foundation

protocol PersistenceServiceProtocol {
    func loadProgress() -> GameProgress?
    func saveProgress(_ progress: GameProgress)
    func clearProgress()
    var hasSeenHowToPlay: Bool { get }
    func markHowToPlaySeen()
    func loadAppearance() -> AppAppearance
    func saveAppearance(_ appearance: AppAppearance)
    func loadFeedbackSettings() -> GameFeedbackSettings
    func saveFeedbackSettings(_ settings: GameFeedbackSettings)
    func loadPlayerStats() -> PlayerStats
    func savePlayerStats(_ stats: PlayerStats)
    func loadGamePreferences() -> GamePreferences
    func saveGamePreferences(_ preferences: GamePreferences)
    func loadDailyProgress() -> GameProgress?
    func saveDailyProgress(_ progress: GameProgress?)
}

final class PersistenceService: PersistenceServiceProtocol {
    private let progressKey = "sudoku.game.progress"
    private let howToPlaySeenKey = "sudoku.howToPlay.seen"
    private let appearanceKey = "sudoku.appearance"
    private let feedbackSettingsKey = "sudoku.feedback.settings"
    private let playerStatsKey = "sudoku.player.stats"
    private let gamePreferencesKey = "sudoku.game.preferences"
    private let dailyProgressKey = "sudoku.daily.progress"

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

    func loadFeedbackSettings() -> GameFeedbackSettings {
        guard let data = UserDefaults.standard.data(forKey: feedbackSettingsKey),
              let settings = try? JSONDecoder().decode(GameFeedbackSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func saveFeedbackSettings(_ settings: GameFeedbackSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: feedbackSettingsKey)
    }

    func loadPlayerStats() -> PlayerStats {
        guard let data = UserDefaults.standard.data(forKey: playerStatsKey),
              let stats = try? JSONDecoder().decode(PlayerStats.self, from: data) else {
            return .empty
        }
        return stats
    }

    func savePlayerStats(_ stats: PlayerStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        UserDefaults.standard.set(data, forKey: playerStatsKey)
    }

    func loadGamePreferences() -> GamePreferences {
        guard let data = UserDefaults.standard.data(forKey: gamePreferencesKey),
              let preferences = try? JSONDecoder().decode(GamePreferences.self, from: data) else {
            return .default
        }
        return preferences
    }

    func saveGamePreferences(_ preferences: GamePreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        UserDefaults.standard.set(data, forKey: gamePreferencesKey)
    }

    func loadDailyProgress() -> GameProgress? {
        guard let data = UserDefaults.standard.data(forKey: dailyProgressKey) else { return nil }
        return try? JSONDecoder().decode(GameProgress.self, from: data)
    }

    func saveDailyProgress(_ progress: GameProgress?) {
        guard let progress else {
            UserDefaults.standard.removeObject(forKey: dailyProgressKey)
            return
        }
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: dailyProgressKey)
    }
}
