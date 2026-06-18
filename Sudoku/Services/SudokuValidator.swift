import Foundation

enum SudokuValidator {
    static func isValidMove(puzzle: SudokuPuzzle, row: Int, column: Int, value: Int) -> Bool {
        puzzle.solution[row][column] == value
    }

    static func conflictingPositions(puzzle: SudokuPuzzle, row: Int, column: Int, value: Int) -> Set<String> {
        let config = puzzle.gridConfig
        var conflicts = Set<String>()

        for columnIndex in 0..<config.size where columnIndex != column {
            if puzzle.userGrid[row][columnIndex] == value {
                conflicts.insert("\(row)-\(columnIndex)")
            }
        }

        for rowIndex in 0..<config.size where rowIndex != row {
            if puzzle.userGrid[rowIndex][column] == value {
                conflicts.insert("\(rowIndex)-\(column)")
            }
        }

        let origin = config.boxOrigin(for: config.boxIndex(row: row, column: column))
        for rowOffset in 0..<config.boxHeight {
            for columnOffset in 0..<config.boxWidth {
                let checkRow = origin.row + rowOffset
                let checkColumn = origin.column + columnOffset
                guard checkRow != row || checkColumn != column else { continue }
                if puzzle.userGrid[checkRow][checkColumn] == value {
                    conflicts.insert("\(checkRow)-\(checkColumn)")
                }
            }
        }

        return conflicts
    }
}
