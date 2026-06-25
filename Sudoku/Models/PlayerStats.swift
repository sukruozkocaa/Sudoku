import Foundation

struct PlayerStats: Codable, Equatable {
    var puzzlesCompleted: Int
    var dailyCompletedCount: Int
    var currentStreak: Int
    var bestStreak: Int
    var lastPlayedDate: String?
    var totalPlayTimeSeconds: Int
    var bestTimes: [String: Int]
    var unlockedAchievements: [String]
    var dailyLastCompletedDate: String?

    static let empty = PlayerStats(
        puzzlesCompleted: 0,
        dailyCompletedCount: 0,
        currentStreak: 0,
        bestStreak: 0,
        lastPlayedDate: nil,
        totalPlayTimeSeconds: 0,
        bestTimes: [:],
        unlockedAchievements: [],
        dailyLastCompletedDate: nil
    )
}

enum AchievementID: String, CaseIterable, Identifiable {
    case firstWin
    case tenWins
    case streak7
    case daily7
    case hardWin
    case speedster

    var id: String { rawValue }
}
