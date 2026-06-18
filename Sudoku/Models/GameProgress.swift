import Foundation

struct GameProgress: Codable, Equatable {
    var puzzle: SudokuPuzzle
    var hasActiveGame: Bool

    static let empty = GameProgress(
        puzzle: SudokuPuzzle(
            solution: Array(repeating: Array(repeating: 0, count: 9), count: 9),
            initialGrid: Array(repeating: Array(repeating: nil, count: 9), count: 9),
            difficulty: .easy,
            level: 1
        ),
        hasActiveGame: false
    )
}
