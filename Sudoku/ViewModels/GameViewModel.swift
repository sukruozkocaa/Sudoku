import Foundation
import Observation

@Observable
@MainActor
final class GameViewModel {
    private(set) var puzzle: SudokuPuzzle
    var selectedRow: Int?
    var selectedColumn: Int?
    var conflictingCells: Set<String> = []
    var pendingCompletionFlashes: [CompletedRegion] = []
    var activeHint: HintSuggestion?
    var hintMessage: String?
    var isPencilMode: Bool
    private(set) var elapsedSeconds: Int

    var onPuzzleUpdated: ((SudokuPuzzle, Int, Bool) -> Void)?
    var onPuzzleCompleted: ((SudokuPuzzle, Int) -> Void)?

    private var moveHistory: [(row: Int, column: Int, previous: Int?)] = []
    private var timerTask: Task<Void, Never>?

    init(
        puzzle: SudokuPuzzle,
        elapsedSeconds: Int = 0,
        isPencilMode: Bool = true
    ) {
        self.puzzle = puzzle
        self.elapsedSeconds = elapsedSeconds
        self.isPencilMode = isPencilMode
        self.puzzle.refreshCompletedRegions()
    }

    func startTimerIfNeeded() {
        guard timerTask == nil else { return }
        startTimer()
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
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

    var formattedElapsedTime: String {
        StatsStore.formatDuration(elapsedSeconds)
    }

    func togglePencilMode() {
        isPencilMode.toggle()
        notifyUpdated()
    }

    func selectCell(row: Int, column: Int) {
        guard isCellEditable(row: row, column: column) else { return }

        selectedRow = row
        selectedColumn = column
        conflictingCells = []
        hintMessage = nil
        GameFeedbackService.shared.play(.cellSelect)
    }

    func enterNumber(_ number: Int) {
        guard let row = selectedRow, let column = selectedColumn else { return }
        guard isCellEditable(row: row, column: column) else { return }

        if isPencilMode {
            puzzle.toggleNote(at: row, column: column, number: number)
            GameFeedbackService.shared.play(.cellSelect)
            notifyUpdated()
            return
        }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        puzzle.userGrid[row][column] = number
        puzzle.clearNotes(at: row, column: column)
        applyMoveEffects(row: row, column: column)
    }

    func clearSelectedCell() {
        guard let row = selectedRow, let column = selectedColumn else { return }
        guard puzzle.initialGrid[row][column] == nil else { return }
        guard isCellEditable(row: row, column: column) else { return }

        if isPencilMode {
            puzzle.clearNotes(at: row, column: column)
            GameFeedbackService.shared.play(.numberClear)
            notifyUpdated()
            return
        }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        puzzle.userGrid[row][column] = nil
        conflictingCells = []
        hintMessage = nil
        GameFeedbackService.shared.play(.numberClear)
        notifyUpdated()
    }

    func undoLastMove() {
        purgeLockedMoveHistory()

        guard let lastMove = moveHistory.popLast() else { return }
        puzzle.userGrid[lastMove.row][lastMove.column] = lastMove.previous
        selectedRow = lastMove.row
        selectedColumn = lastMove.column
        conflictingCells = []
        hintMessage = nil
        puzzle.refreshCompletedRegions()
        purgeLockedMoveHistory()
        GameFeedbackService.shared.play(.undo)
        notifyUpdated()
    }

    func requestHint() {
        let target = hintTargetCell()
        guard let row = target?.row, let column = target?.column else {
            hintMessage = L10n.allCellsFilled
            return
        }

        let correctValue = puzzle.solution[row][column]
        guard puzzle.userGrid[row][column] != correctValue else { return }

        selectedRow = row
        selectedColumn = column
        hintMessage = nil
        activeHint = HintExplanationService.build(puzzle: puzzle, row: row, column: column)
    }

    func confirmHint() {
        guard let hint = activeHint else { return }

        let row = hint.row
        let column = hint.column
        let correctValue = hint.value
        guard puzzle.userGrid[row][column] != correctValue else {
            activeHint = nil
            return
        }

        moveHistory.append((row, column, puzzle.userGrid[row][column]))
        selectedRow = row
        selectedColumn = column
        puzzle.userGrid[row][column] = correctValue
        puzzle.clearNotes(at: row, column: column)
        activeHint = nil
        applyMoveEffects(row: row, column: column)
    }

    func cancelHint() {
        activeHint = nil
    }

    func useHint() {
        requestHint()
    }

    func isSelected(row: Int, column: Int) -> Bool {
        selectedRow == row && selectedColumn == column
    }

    func isConflict(row: Int, column: Int) -> Bool {
        conflictingCells.contains("\(row)-\(column)")
    }

    func isCellPassive(row: Int, column: Int) -> Bool {
        isRegionCompleted(row: row, column: column)
    }

    func clearCompletionFlashes() {
        pendingCompletionFlashes = []
    }

    func isCellEditable(row: Int, column: Int) -> Bool {
        puzzle.initialGrid[row][column] == nil && !isRegionCompleted(row: row, column: column)
    }

    func cellDisplayValue(row: Int, column: Int) -> Int? {
        puzzle.userGrid[row][column]
    }

    func cellNotes(row: Int, column: Int) -> [Int] {
        puzzle.notes(at: row, column: column)
    }

    func isFixedCell(row: Int, column: Int) -> Bool {
        puzzle.initialGrid[row][column] != nil
    }

    private func isRegionCompleted(row: Int, column: Int) -> Bool {
        let boxIndex = gridConfig.boxIndex(row: row, column: column)
        return puzzle.completedBoxes.contains(boxIndex)
            || puzzle.completedRows.contains(row)
            || puzzle.completedColumns.contains(column)
    }

    private func purgeLockedMoveHistory() {
        moveHistory.removeAll { move in
            isRegionCompleted(row: move.row, column: move.column)
        }
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
        let previousRows = puzzle.completedRows
        let previousColumns = puzzle.completedColumns
        puzzle.refreshCompletedRegions()
        purgeLockedMoveHistory()

        var flashes: [CompletedRegion] = []
        flashes += puzzle.completedBoxes.subtracting(previousBoxes).sorted().map { .box($0) }
        flashes += puzzle.completedRows.subtracting(previousRows).sorted().map { .row($0) }
        flashes += puzzle.completedColumns.subtracting(previousColumns).sorted().map { .column($0) }
        pendingCompletionFlashes = flashes

        if puzzle.isComplete {
            GameFeedbackService.shared.play(.puzzleComplete)
        } else if !conflictingCells.isEmpty {
            GameFeedbackService.shared.play(.conflict)
        } else if !flashes.isEmpty {
            GameFeedbackService.shared.play(.regionComplete)
        } else {
            GameFeedbackService.shared.play(.numberPlace)
        }

        notifyUpdated()

        if puzzle.isComplete {
            stopTimer()
            onPuzzleCompleted?(puzzle, elapsedSeconds)
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

    private func notifyUpdated() {
        onPuzzleUpdated?(puzzle, elapsedSeconds, isPencilMode)
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                elapsedSeconds += 1
                notifyUpdated()
            }
        }
    }
}
