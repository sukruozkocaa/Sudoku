import Foundation

enum HintExplanationService {
    static func build(puzzle: SudokuPuzzle, row: Int, column: Int) -> HintSuggestion {
        let value = puzzle.solution[row][column]
        let explanation = makeExplanation(puzzle: puzzle, row: row, column: column, value: value)

        return HintSuggestion(
            row: row,
            column: column,
            value: value,
            explanation: explanation
        )
    }

    private static func makeExplanation(
        puzzle: SudokuPuzzle,
        row: Int,
        column: Int,
        value: Int
    ) -> String {
        let config = puzzle.gridConfig
        let usedInRow = usedNumbers(in: puzzle, row: row, column: nil)
        let usedInColumn = usedNumbers(in: puzzle, row: nil, column: column)
        let usedInBox = usedNumbers(in: puzzle, row: row, column: column, boxOnly: true)

        let missingInRow = missingNumbers(maxNumber: config.maxNumber, used: usedInRow)
        let missingInColumn = missingNumbers(maxNumber: config.maxNumber, used: usedInColumn)
        let missingInBox = missingNumbers(maxNumber: config.maxNumber, used: usedInBox)
        let candidates = validCandidates(
            maxNumber: config.maxNumber,
            usedInRow: usedInRow,
            usedInColumn: usedInColumn,
            usedInBox: usedInBox
        )

        if missingInRow == [value] {
            return L10n.hintExplanationRowOnly(value: value, row: row + 1)
        }

        if missingInColumn == [value] {
            return L10n.hintExplanationColumnOnly(value: value, column: column + 1)
        }

        if missingInBox == [value] {
            return L10n.hintExplanationBoxOnly(
                value: value,
                boxHeight: config.boxHeight,
                boxWidth: config.boxWidth
            )
        }

        if candidates == [value] {
            return L10n.hintExplanationElimination(
                value: value,
                rowNumbers: formatList(Array(usedInRow)),
                columnNumbers: formatList(Array(usedInColumn)),
                boxNumbers: formatList(Array(usedInBox))
            )
        }

        return L10n.hintExplanationFallback(value: value)
    }

    private static func usedNumbers(
        in puzzle: SudokuPuzzle,
        row: Int?,
        column: Int?,
        boxOnly: Bool = false
    ) -> Set<Int> {
        let config = puzzle.gridConfig
        var used = Set<Int>()

        if boxOnly, let row, let column {
            let origin = config.boxOrigin(for: config.boxIndex(row: row, column: column))
            for rowIndex in origin.row..<(origin.row + config.boxHeight) {
                for columnIndex in origin.column..<(origin.column + config.boxWidth) {
                    if let value = puzzle.userGrid[rowIndex][columnIndex] {
                        used.insert(value)
                    }
                }
            }
            return used
        }

        if let row {
            for columnIndex in 0..<config.size {
                if let value = puzzle.userGrid[row][columnIndex] {
                    used.insert(value)
                }
            }
        }

        if let column {
            for rowIndex in 0..<config.size {
                if let value = puzzle.userGrid[rowIndex][column] {
                    used.insert(value)
                }
            }
        }

        return used
    }

    private static func missingNumbers(maxNumber: Int, used: Set<Int>) -> [Int] {
        (1...maxNumber).filter { !used.contains($0) }
    }

    private static func validCandidates(
        maxNumber: Int,
        usedInRow: Set<Int>,
        usedInColumn: Set<Int>,
        usedInBox: Set<Int>
    ) -> [Int] {
        (1...maxNumber).filter {
            !usedInRow.contains($0) && !usedInColumn.contains($0) && !usedInBox.contains($0)
        }
    }

    private static func formatList(_ numbers: [Int]) -> String {
        guard !numbers.isEmpty else { return L10n.hintNoNumbers }
        return numbers.sorted().map(String.init).joined(separator: ", ")
    }
}
