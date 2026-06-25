import FirebaseAnalytics
import Foundation

enum AnalyticsService {
    static func logAppOpen(hasSavedGame: Bool, puzzlesCompleted: Int) {
        log(
            "app_open",
            [
                "has_saved_game": hasSavedGame,
                "puzzles_completed": puzzlesCompleted
            ]
        )
    }

    static func logGameStart(difficulty: Difficulty, level: Int, mode: GameMode) {
        log(
            "game_start",
            [
                "difficulty": difficulty.rawValue,
                "level": level,
                "game_mode": mode.rawValue
            ]
        )
    }

    static func logGameContinue(difficulty: Difficulty, level: Int) {
        log(
            "game_continue",
            [
                "difficulty": difficulty.rawValue,
                "level": level
            ]
        )
    }

    static func logPuzzleComplete(
        difficulty: Difficulty,
        level: Int,
        mode: GameMode,
        elapsedSeconds: Int
    ) {
        log(
            "puzzle_complete",
            [
                "difficulty": difficulty.rawValue,
                "level": level,
                "game_mode": mode.rawValue,
                "elapsed_seconds": elapsedSeconds
            ]
        )
    }

    static func logHintUsed(difficulty: Difficulty, level: Int, mode: GameMode) {
        log(
            "hint_used",
            [
                "difficulty": difficulty.rawValue,
                "level": level,
                "game_mode": mode.rawValue
            ]
        )
    }

    static func logNextLevel(difficulty: Difficulty, level: Int) {
        log(
            "next_level",
            [
                "difficulty": difficulty.rawValue,
                "level": level
            ]
        )
    }

    static func logSettingsOpen() {
        log("settings_open")
    }

    static func logHowToPlayOpen(source: String) {
        log("how_to_play_open", ["source": source])
    }

    private static func log(_ name: String, _ parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        #if DEBUG
        if let parameters, !parameters.isEmpty {
            print("Analytics ▶︎ \(name) \(parameters)")
        } else {
            print("Analytics ▶︎ \(name)")
        }
        #endif
    }
}
