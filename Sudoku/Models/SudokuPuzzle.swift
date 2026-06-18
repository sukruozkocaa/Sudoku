import Foundation

struct SudokuPuzzle: Equatable, Codable {
    let solution: [[Int]]
    let initialGrid: [[Int?]]
    var userGrid: [[Int?]]
    let difficulty: Difficulty
    let level: Int
    var completedBoxes: Set<Int>

    var gridConfig: SudokuGridConfig {
        difficulty.gridConfig
    }

    init(
        solution: [[Int]],
        initialGrid: [[Int?]],
        difficulty: Difficulty,
        level: Int,
        userGrid: [[Int?]]? = nil,
        completedBoxes: Set<Int> = []
    ) {
        self.solution = solution
        self.initialGrid = initialGrid
        self.userGrid = userGrid ?? initialGrid
        self.difficulty = difficulty
        self.level = level
        self.completedBoxes = completedBoxes
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

    mutating func refreshCompletedBoxes() {
        completedBoxes = Set((0..<gridConfig.boxCount).filter(isBoxComplete))
    }
}
