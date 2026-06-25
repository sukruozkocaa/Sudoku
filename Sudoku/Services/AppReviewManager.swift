import Foundation

@MainActor
enum AppReviewManager {
    private static let completedLevelsKey = "sudoku.review.completedLevels"
    private static let lastPromptDateKey = "sudoku.review.lastPromptDate"

    /// Show the system review prompt after these many completed puzzles.
    private static let promptMilestones: Set<Int> = [1, 10, 25]
    private static let minimumDaysBetweenPrompts = 60

    /// Records a completed level and returns whether the system review prompt should be shown.
    static func registerLevelCompletion() -> Bool {
        let defaults = UserDefaults.standard
        let completionCount = defaults.integer(forKey: completedLevelsKey) + 1
        defaults.set(completionCount, forKey: completedLevelsKey)

        guard promptMilestones.contains(completionCount) else { return false }
        guard enoughTimeHasPassedSinceLastPrompt() else { return false }

        defaults.set(Date(), forKey: lastPromptDateKey)
        return true
    }

    private static func enoughTimeHasPassedSinceLastPrompt() -> Bool {
        guard let lastPrompt = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date else {
            return true
        }

        let days = Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0
        return days >= minimumDaysBetweenPrompts
    }
}
