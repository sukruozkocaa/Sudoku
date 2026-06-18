import Foundation

enum CompletedRegion: Equatable, Hashable {
    case box(Int)
    case row(Int)
    case column(Int)
}

struct SudokuPuzzle: Equatable, Codable {
    let solution: [[Int]]
    let initialGrid: [[Int?]]
    var userGrid: [[Int?]]
    let difficulty: Difficulty
    let level: Int
    var completedBoxes: Set<Int>
    var completedRows: Set<Int>
    var completedColumns: Set<Int>

    var gridConfig: SudokuGridConfig {
        difficulty.gridConfig
    }

    init(
        solution: [[Int]],
        initialGrid: [[Int?]],
        difficulty: Difficulty,
        level: Int,
        userGrid: [[Int?]]? = nil,
        completedBoxes: Set<Int> = [],
        completedRows: Set<Int> = [],
        completedColumns: Set<Int> = []
    ) {
        self.solution = solution
        self.initialGrid = initialGrid
        self.userGrid = userGrid ?? initialGrid
        self.difficulty = difficulty
        self.level = level
        self.completedBoxes = completedBoxes
        self.completedRows = completedRows
        self.completedColumns = completedColumns
    }

    private enum CodingKeys: String, CodingKey {
        case solution
        case initialGrid
        case userGrid
        case difficulty
        case level
        case completedBoxes
        case completedRows
        case completedColumns
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        solution = try container.decode([[Int]].self, forKey: .solution)
        initialGrid = try container.decode([[Int?]].self, forKey: .initialGrid)
        userGrid = try container.decode([[Int?]].self, forKey: .userGrid)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        level = try container.decode(Int.self, forKey: .level)
        completedBoxes = try container.decode(Set<Int>.self, forKey: .completedBoxes)
        completedRows = try container.decodeIfPresent(Set<Int>.self, forKey: .completedRows) ?? []
        completedColumns = try container.decodeIfPresent(Set<Int>.self, forKey: .completedColumns) ?? []
        refreshCompletedRegions()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(solution, forKey: .solution)
        try container.encode(initialGrid, forKey: .initialGrid)
        try container.encode(userGrid, forKey: .userGrid)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(level, forKey: .level)
        try container.encode(completedBoxes, forKey: .completedBoxes)
        try container.encode(completedRows, forKey: .completedRows)
        try container.encode(completedColumns, forKey: .completedColumns)
    }

    var isComplete: Bool {
        let size = gridConfig.size
        for row in 0..<size {
            for column in 0..<size {
                guard userGrid[row][column] == solution[row][column] else { return false }
            }
        }
        return true
    }

    func cell(at row: Int, column: Int) -> SudokuCell {
        let fixed = initialGrid[row][column] != nil
        return SudokuCell(
            row: row,
            column: column,
            value: userGrid[row][column],
            isFixed: fixed
        )
    }

    func boxHasEditableCells(_ boxIndex: Int) -> Bool {
        let config = gridConfig
        let origin = config.boxOrigin(for: boxIndex)

        for row in origin.row..<(origin.row + config.boxHeight) {
            for column in origin.column..<(origin.column + config.boxWidth) {
                if initialGrid[row][column] == nil {
                    return true
                }
            }
        }
        return false
    }

    func rowHasEditableCells(_ row: Int) -> Bool {
        (0..<gridConfig.size).contains { initialGrid[row][$0] == nil }
    }

    func columnHasEditableCells(_ column: Int) -> Bool {
        (0..<gridConfig.size).contains { initialGrid[$0][column] == nil }
    }

    func isRowComplete(_ row: Int) -> Bool {
        guard rowHasEditableCells(row) else { return false }

        let size = gridConfig.size
        var seen = Set<Int>()

        for column in 0..<size {
            guard let value = userGrid[row][column] else { return false }
            guard value == solution[row][column] else { return false }
            guard seen.insert(value).inserted else { return false }
        }
        return true
    }

    func isColumnComplete(_ column: Int) -> Bool {
        guard columnHasEditableCells(column) else { return false }

        let size = gridConfig.size
        var seen = Set<Int>()

        for row in 0..<size {
            guard let value = userGrid[row][column] else { return false }
            guard value == solution[row][column] else { return false }
            guard seen.insert(value).inserted else { return false }
        }
        return true
    }

    func isBoxComplete(_ boxIndex: Int) -> Bool {
        guard boxHasEditableCells(boxIndex) else { return false }

        let config = gridConfig
        let origin = config.boxOrigin(for: boxIndex)
        var seen = Set<Int>()

        for row in origin.row..<(origin.row + config.boxHeight) {
            for column in origin.column..<(origin.column + config.boxWidth) {
                guard let value = userGrid[row][column] else { return false }
                guard value == solution[row][column] else { return false }
                guard seen.insert(value).inserted else { return false }
            }
        }
        return true
    }

    mutating func refreshCompletedRegions() {
        let config = gridConfig
        completedBoxes = Set((0..<config.boxCount).filter(isBoxComplete))
        completedRows = Set((0..<config.size).filter(isRowComplete))
        completedColumns = Set((0..<config.size).filter(isColumnComplete))
    }

    mutating func refreshCompletedBoxes() {
        refreshCompletedRegions()
    }
}
