import SwiftUI

extension AchievementID {
    var title: String {
        switch self {
        case .firstWin: L10n.achievementFirstWin
        case .tenWins: L10n.achievementTenWins
        case .streak7: L10n.achievementStreak7
        case .daily7: L10n.achievementDaily7
        case .hardWin: L10n.achievementHardWin
        case .speedster: L10n.achievementSpeedster
        }
    }

    var icon: String {
        switch self {
        case .firstWin: "star.fill"
        case .tenWins: "10.circle.fill"
        case .streak7: "flame.fill"
        case .daily7: "calendar.circle.fill"
        case .hardWin: "bolt.fill"
        case .speedster: "hare.fill"
        }
    }
}
