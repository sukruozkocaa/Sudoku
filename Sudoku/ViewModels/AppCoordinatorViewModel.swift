import Foundation
import Observation
import SwiftUI

enum AppDestination: Hashable {
    case game
}

@Observable
@MainActor
final class AppCoordinatorViewModel {
    var showSplash = true
    var navigationPath = NavigationPath()
    var activePuzzle: SudokuPuzzle?
    var gameSessionID = UUID()
    var showDifficultySheet = false
    var showSuccessOverlay = false

    private let persistence: PersistenceServiceProtocol
    private(set) var savedProgress: GameProgress?

    init(persistence: PersistenceServiceProtocol = PersistenceService()) {
        self.persistence = persistence
        self.savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    var resumeLevel: Int? {
        guard let progress = savedProgress, progress.hasActiveGame else { return nil }
        return progress.puzzle.level
    }

    var resumeDifficulty: Difficulty? {
        guard let progress = savedProgress, progress.hasActiveGame else { return nil }
        return progress.puzzle.difficulty
    }

    var hasSavedGame: Bool {
        savedProgress?.hasActiveGame == true
    }

    func finishSplash() {
        showSplash = false
    }

    func requestNewGame() {
        showDifficultySheet = true
    }

    func startGame(difficulty: Difficulty) {
        showDifficultySheet = false
        let puzzle = SudokuGenerator.generate(difficulty: difficulty, level: 1)
        activePuzzle = puzzle
        gameSessionID = UUID()
        saveCurrentProgress()
        navigationPath.append(AppDestination.game)
    }

    func continueGame() {
        normalizeSavedProgressIfNeeded()
        guard let progress = savedProgress, progress.hasActiveGame else { return }
        activePuzzle = progress.puzzle
        gameSessionID = UUID()
        navigationPath.append(AppDestination.game)
    }

    func updatePuzzle(_ puzzle: SudokuPuzzle) {
        activePuzzle = puzzle
        saveCurrentProgress()
    }

    func handlePuzzleCompleted(_ puzzle: SudokuPuzzle) {
        activePuzzle = puzzle
        showSuccessOverlay = true
    }

    func advanceToNextLevel() {
        guard let current = activePuzzle else { return }
        showSuccessOverlay = false
        let nextLevel = current.level + 1
        let nextPuzzle = SudokuGenerator.generate(difficulty: current.difficulty, level: nextLevel)
        activePuzzle = nextPuzzle
        gameSessionID = UUID()
        saveCurrentProgress()
    }

    func returnHome() {
        navigationPath = NavigationPath()
        activePuzzle = nil
        showSuccessOverlay = false
        savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    func handlePopToHome() {
        activePuzzle = nil
        showSuccessOverlay = false
        savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    func clearSavedGame() {
        persistence.clearProgress()
        savedProgress = nil
    }

    private func saveCurrentProgress() {
        guard let puzzle = activePuzzle else { return }
        let progress = GameProgress(puzzle: puzzle, hasActiveGame: true)
        persistence.saveProgress(progress)
        savedProgress = progress
    }

    private func normalizeSavedProgressIfNeeded() {
        guard var progress = savedProgress, progress.hasActiveGame else { return }
        guard progress.puzzle.isComplete else { return }

        let nextPuzzle = SudokuGenerator.generate(
            difficulty: progress.puzzle.difficulty,
            level: progress.puzzle.level + 1
        )
        progress = GameProgress(puzzle: nextPuzzle, hasActiveGame: true)
        persistence.saveProgress(progress)
        savedProgress = progress
    }
}
