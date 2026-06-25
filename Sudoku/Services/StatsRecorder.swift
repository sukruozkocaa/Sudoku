import Foundation

enum StatsRecorder {
    static func recordCompletion(
        stats: inout PlayerStats,
        puzzle: SudokuPuzzle,
        elapsedSeconds: Int,
        isDaily: Bool,
        todayKey: String = DailyChallengeService.todayKey()
    ) -> [AchievementID] {
        stats.puzzlesCompleted += 1
        stats.totalPlayTimeSeconds += max(elapsedSeconds, 0)
        updateStreak(stats: &stats, todayKey: todayKey)

        if isDaily {
            stats.dailyCompletedCount += 1
            stats.dailyLastCompletedDate = todayKey
        }

        let difficultyKey = puzzle.difficulty.rawValue
        if let existingBest = stats.bestTimes[difficultyKey] {
            stats.bestTimes[difficultyKey] = min(existingBest, elapsedSeconds)
        } else {
            stats.bestTimes[difficultyKey] = elapsedSeconds
        }

        return unlockAchievements(stats: &stats, puzzle: puzzle, elapsedSeconds: elapsedSeconds, isDaily: isDaily)
    }

    private static func updateStreak(stats: inout PlayerStats, todayKey: String) {
        guard stats.lastPlayedDate != todayKey else { return }

        if let lastDate = stats.lastPlayedDate,
           isYesterday(lastDate, relativeTo: todayKey) {
            stats.currentStreak += 1
        } else {
            stats.currentStreak = 1
        }

        stats.lastPlayedDate = todayKey
        stats.bestStreak = max(stats.bestStreak, stats.currentStreak)
    }

    private static func isYesterday(_ dateKey: String, relativeTo todayKey: String) -> Bool {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"

        guard let today = formatter.date(from: todayKey),
              let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else {
            return false
        }

        return formatter.string(from: yesterday) == dateKey
    }

    private static func unlockAchievements(
        stats: inout PlayerStats,
        puzzle: SudokuPuzzle,
        elapsedSeconds: Int,
        isDaily: Bool
    ) -> [AchievementID] {
        var newlyUnlocked: [AchievementID] = []

        func unlock(_ achievement: AchievementID) {
            guard !stats.unlockedAchievements.contains(achievement.rawValue) else { return }
            stats.unlockedAchievements.append(achievement.rawValue)
            newlyUnlocked.append(achievement)
        }

        if stats.puzzlesCompleted >= 1 { unlock(.firstWin) }
        if stats.puzzlesCompleted >= 10 { unlock(.tenWins) }
        if stats.currentStreak >= 7 { unlock(.streak7) }
        if stats.dailyCompletedCount >= 7 { unlock(.daily7) }
        if puzzle.difficulty == .hard { unlock(.hardWin) }
        if elapsedSeconds > 0, elapsedSeconds <= 180, puzzle.gridConfig.size <= 6 { unlock(.speedster) }

        return newlyUnlocked
    }
}
