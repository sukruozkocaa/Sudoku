import Foundation
import Observation

@Observable
@MainActor
final class GameViewModel {
    private(set) var puzzle: SudokuPuzzle
    var selectedRow: Int?
    var selectedColumn: Int?
    var conflictingCells: Set<String> = []
    var lastCompletedBox: Int?
    var hintMessage: String?

    var onPuzzleUpdated: ((SudokuPuzzle) -> Void)?
    var onPuzzleCompleted: ((SudokuPuzzle) -> Void)?

    private var moveHistory: [(row: Int, column: Int, previous: Int?)] = []

    init(puzzle: SudokuPuzzle) {
        self.puzzle = puzzle
        self.puzzle.refreshCompletedBoxes()
    }

    var gridConfig: SudokuGridConfig {
        puzzle.gridConfig
    }

    var levelText: String {
        L10n.level(puzzle.level)
    }

    var difficultyText: String {
        puzzle.difficulty.title
    }

    var showsHint: Bool {
        puzzle.difficulty.showsHint
    }

    func selectCell(row: Int, column: Int) {
        let boxIndex = gridConfig.boxIndex(row: row, column: column)
        guard !puzzle.completedBoxes.contains(boxIndex) else { return }
        guard puzzle.initialGrid[row][column] == nil else { return }

        selectedRow = row
        selectedColumn = column
        conflictingCells = []
        hintMessage = nil
    }

    func enterNumber(_ number: Int) {
        guard let row = selectedRow, let column = selectedColumn else { return }

        let boxIndex = gridConfig.boxIndex(row: row, column: column)
        guard !puzzle.completedBoxes.contains(boxIndex) else { return }
        guard puzzle.initialGrid[row][column] == nil else { return }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        puzzle.userGrid[row][column] = number
        applyMoveEffects(row: row, column: column)
    }

    func clearSelectedCell() {
        guard let row = selectedRow, let column = selectedColumn else { return }
        guard puzzle.initialGrid[row][column] == nil else { return }

        let boxIndex = gridConfig.boxIndex(row: row, column: column)
        guard !puzzle.completedBoxes.contains(boxIndex) else { return }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        puzzle.userGrid[row][column] = nil
        conflictingCells = []
        hintMessage = nil
        onPuzzleUpdated?(puzzle)
    }

    func undoLastMove() {
        guard let lastMove = moveHistory.popLast() else { return }
        puzzle.userGrid[lastMove.row][lastMove.column] = lastMove.previous
        selectedRow = lastMove.row
        selectedColumn = lastMove.column
        conflictingCells = []
        hintMessage = nil
        puzzle.refreshCompletedBoxes()
        onPuzzleUpdated?(puzzle)
    }

    func useHint() {
        guard showsHint else { return }

        let target = hintTargetCell()
        guard let row = target?.row, let column = target?.column else {
            hintMessage = L10n.allCellsFilled
            return
        }

        let correctValue = puzzle.solution[row][column]
        guard puzzle.userGrid[row][column] != correctValue else { return }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        selectedRow = row
        selectedColumn = column
        puzzle.userGrid[row][column] = correctValue
        hintMessage = nil
        applyMoveEffects(row: row, column: column)
    }

    func isSelected(row: Int, column: Int) -> Bool {
        selectedRow == row && selectedColumn == column
    }

    func isConflict(row: Int, column: Int) -> Bool {
        conflictingCells.contains("\(row)-\(column)")
    }

    func isBoxCompleted(_ boxIndex: Int) -> Bool {
        puzzle.completedBoxes.contains(boxIndex)
    }

    func isCellEditable(row: Int, column: Int) -> Bool {
        let boxIndex = gridConfig.boxIndex(row: row, column: column)
        return puzzle.initialGrid[row][column] == nil && !puzzle.completedBoxes.contains(boxIndex)
    }

    func cellDisplayValue(row: Int, column: Int) -> Int? {
        puzzle.userGrid[row][column]
    }

    func isFixedCell(row: Int, column: Int) -> Bool {
        puzzle.initialGrid[row][column] != nil
    }

    private func applyMoveEffects(row: Int, column: Int) {
        let value = puzzle.userGrid[row][column] ?? 0
        conflictingCells = SudokuValidator.conflictingPositions(
            puzzle: puzzle,
            row: row,
            column: column,
            value: value
        )

        let previousBoxes = puzzle.completedBoxes
        puzzle.refreshCompletedBoxes()
        let newlyCompleted = puzzle.completedBoxes.subtracting(previousBoxes)
        lastCompletedBox = newlyCompleted.first

        onPuzzleUpdated?(puzzle)

        if puzzle.isComplete {
            onPuzzleCompleted?(puzzle)
        }
    }

    private func hintTargetCell() -> (row: Int, column: Int)? {
        if let row = selectedRow, let column = selectedColumn, isCellEditable(row: row, column: column) {
            return (row, column)
        }

        let size = gridConfig.size
        for row in 0..<size {
            for column in 0..<size where isCellEditable(row: row, column: column) {
                if puzzle.userGrid[row][column] != puzzle.solution[row][column] {
                    return (row, column)
                }
            }
        }
        return nil
    }
}
