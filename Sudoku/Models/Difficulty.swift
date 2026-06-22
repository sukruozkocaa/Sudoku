import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: L10n.difficultyEasy
        case .medium: L10n.difficultyMedium
        case .hard: L10n.difficultyHard
        }
    }

    var subtitle: String {
        switch self {
        case .easy: L10n.difficultyEasySubtitle
        case .medium: L10n.difficultyMediumSubtitle
        case .hard: L10n.difficultyHardSubtitle
        }
    }

    var icon: String {
        switch self {
        case .easy: "leaf.fill"
        case .medium: "flame.fill"
        case .hard: "bolt.fill"
        }
    }

    var gridConfig: SudokuGridConfig {
        switch self {
        case .easy, .medium:
            .mini
        case .hard:
            .standard
        }
    }

    var showsHint: Bool {
        self == .easy
    }

    func baseClueCount(for level: Int) -> Int {
        let base: Int
        let minimum: Int

        switch self {
        case .easy:
            base = 30
            minimum = 22
        case .medium:
            base = 26
            minimum = 18
        case .hard:
            base = 29
            minimum = 21
        }

        let reduction = max(0, level - 1)
        return max(minimum, base - reduction)
    }
}
