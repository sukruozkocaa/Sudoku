import Foundation

struct GameProgress: Codable, Equatable {
    var puzzle: SudokuPuzzle
    var hasActiveGame: Bool
    var elapsedSeconds: Int
    var gameMode: GameMode
    var isPencilMode: Bool

    init(
        puzzle: SudokuPuzzle,
        hasActiveGame: Bool,
        elapsedSeconds: Int = 0,
        gameMode: GameMode = .campaign,
        isPencilMode: Bool = true
    ) {
        self.puzzle = puzzle
        self.hasActiveGame = hasActiveGame
        self.elapsedSeconds = elapsedSeconds
        self.gameMode = gameMode
        self.isPencilMode = isPencilMode
    }

    private enum CodingKeys: String, CodingKey {
        case puzzle
        case hasActiveGame
        case elapsedSeconds
        case gameMode
        case isPencilMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        puzzle = try container.decode(SudokuPuzzle.self, forKey: .puzzle)
        hasActiveGame = try container.decode(Bool.self, forKey: .hasActiveGame)
        elapsedSeconds = try container.decodeIfPresent(Int.self, forKey: .elapsedSeconds) ?? 0
        gameMode = try container.decodeIfPresent(GameMode.self, forKey: .gameMode) ?? .campaign
        isPencilMode = try container.decodeIfPresent(Bool.self, forKey: .isPencilMode) ?? true
    }

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
