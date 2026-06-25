import SwiftUI

@Observable
@MainActor
final class StatsStore {
    private let persistence: PersistenceServiceProtocol

    private(set) var stats: PlayerStats
    var preferences: GamePreferences {
        didSet { persistence.saveGamePreferences(preferences) }
    }

    var pencilModeEnabledByDefault: Bool {
        get { preferences.pencilModeEnabledByDefault }
        set {
            preferences = GamePreferences(pencilModeEnabledByDefault: newValue)
        }
    }

    var isDailyCompletedToday: Bool {
        stats.dailyLastCompletedDate == DailyChallengeService.todayKey()
    }

    var hasDailyInProgress: Bool {
        guard let progress = persistence.loadDailyProgress() else { return false }
        return progress.hasActiveGame && !progress.puzzle.isComplete
    }

    init(persistence: PersistenceServiceProtocol = PersistenceService()) {
        self.persistence = persistence
        self.stats = persistence.loadPlayerStats()
        self.preferences = persistence.loadGamePreferences()
    }

    func recordCompletion(puzzle: SudokuPuzzle, elapsedSeconds: Int, isDaily: Bool) {
        _ = StatsRecorder.recordCompletion(
            stats: &stats,
            puzzle: puzzle,
            elapsedSeconds: elapsedSeconds,
            isDaily: isDaily
        )
        persistence.savePlayerStats(stats)

        if isDaily {
            persistence.saveDailyProgress(nil)
        }
    }

    func formattedBestTime(for difficulty: Difficulty) -> String? {
        guard let seconds = stats.bestTimes[difficulty.rawValue] else { return nil }
        return Self.formatDuration(seconds)
    }

    static func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%d:%02d", minutes, remaining)
    }

    static func formatDurationLong(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        }
        return String(format: "%dm", max(minutes, 1))
    }

    func isAchievementUnlocked(_ achievement: AchievementID) -> Bool {
        stats.unlockedAchievements.contains(achievement.rawValue)
    }
}
