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
    var notes: [[[Int]]]

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
        completedColumns: Set<Int> = [],
        notes: [[[Int]]]? = nil
    ) {
        self.solution = solution
        self.initialGrid = initialGrid
        self.userGrid = userGrid ?? initialGrid
        self.difficulty = difficulty
        self.level = level
        self.completedBoxes = completedBoxes
        self.completedRows = completedRows
        self.completedColumns = completedColumns
        self.notes = Self.normalizedNotes(notes, size: difficulty.gridConfig.size)
    }

    static func emptyNotes(size: Int) -> [[[Int]]] {
        Array(repeating: Array(repeating: [], count: size), count: size)
    }

    static func normalizedNotes(_ notes: [[[Int]]]?, size: Int) -> [[[Int]]] {
        guard let notes, notes.count == size else {
            return emptyNotes(size: size)
        }
        return notes.map { row in
            guard row.count == size else { return Array(repeating: [Int](), count: size) }
            return row.map { noteList in
                noteList.filter { $0 >= 1 }.sorted()
            }
        }
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
        case notes
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
        notes = Self.normalizedNotes(
            try container.decodeIfPresent([[[Int]]].self, forKey: .notes),
            size: difficulty.gridConfig.size
        )
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
        try container.encode(notes, forKey: .notes)
    }

    mutating func clearNotes(at row: Int, column: Int) {
        guard notes.indices.contains(row), notes[row].indices.contains(column) else { return }
        notes[row][column] = []
    }

    mutating func toggleNote(at row: Int, column: Int, number: Int) {
        guard notes.indices.contains(row), notes[row].indices.contains(column) else { return }
        if notes[row][column].contains(number) {
            notes[row][column].removeAll { $0 == number }
        } else {
            notes[row][column].append(number)
            notes[row][column].sort()
        }
    }

    func notes(at row: Int, column: Int) -> [Int] {
        guard notes.indices.contains(row), notes[row].indices.contains(column) else { return [] }
        return notes[row][column]
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
