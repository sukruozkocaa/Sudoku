import Foundation

enum L10n {
    static var appName: String { String(localized: "app_name") }
    static var homeTagline: String { String(localized: "home_tagline") }
    static var continueGame: String { String(localized: "continue_game") }
    static var newGame: String { String(localized: "new_game") }
    static var start: String { String(localized: "start") }
    static var splashTagline: String { String(localized: "splash_tagline") }
    static var selectDifficulty: String { String(localized: "select_difficulty") }
    static var difficultyProgressNote: String { String(localized: "difficulty_progress_note") }
    static var hint: String { String(localized: "hint") }
    static var delete: String { String(localized: "delete") }
    static var undo: String { String(localized: "undo") }
    static var congratulations: String { String(localized: "congratulations") }
    static var nextLevel: String { String(localized: "next_level") }
    static var home: String { String(localized: "home") }
    static var allCellsFilled: String { String(localized: "all_cells_filled") }

    static var difficultyEasy: String { String(localized: "difficulty_easy") }
    static var difficultyMedium: String { String(localized: "difficulty_medium") }
    static var difficultyHard: String { String(localized: "difficulty_hard") }
    static var difficultyEasySubtitle: String { String(localized: "difficulty_easy_subtitle") }
    static var difficultyMediumSubtitle: String { String(localized: "difficulty_medium_subtitle") }
    static var difficultyHardSubtitle: String { String(localized: "difficulty_hard_subtitle") }

    static func level(_ level: Int) -> String {
        String(format: String(localized: "level_format"), level)
    }

    static func savedProgress(level: Int, difficulty: String) -> String {
        String(format: String(localized: "saved_progress_format"), level, difficulty)
    }

    static func levelCompleted(_ level: Int) -> String {
        String(format: String(localized: "level_completed_format"), level)
    }
}
