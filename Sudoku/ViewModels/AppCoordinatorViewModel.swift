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
    var showHowToPlay = false
    var activeGameMode: GameMode = .campaign
    var lastCompletionSeconds = 0

    private let persistence: PersistenceServiceProtocol
    private let statsStore: StatsStore
    private(set) var savedProgress: GameProgress?

    init(
        persistence: PersistenceServiceProtocol = PersistenceService(),
        statsStore: StatsStore
    ) {
        self.persistence = persistence
        self.statsStore = statsStore
        self.savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    var resumeLevel: Int? {
        guard let progress = savedProgress, progress.hasActiveGame, progress.gameMode == .campaign else { return nil }
        return progress.puzzle.level
    }

    var resumeDifficulty: Difficulty? {
        guard let progress = savedProgress, progress.hasActiveGame, progress.gameMode == .campaign else { return nil }
        return progress.puzzle.difficulty
    }

    var hasSavedGame: Bool {
        savedProgress?.hasActiveGame == true && savedProgress?.gameMode == .campaign
    }

    var activeElapsedSeconds: Int {
        if activeGameMode == .daily {
            return persistence.loadDailyProgress()?.elapsedSeconds ?? 0
        }
        return persistence.loadProgress()?.elapsedSeconds ?? savedProgress?.elapsedSeconds ?? 0
    }

    var activeIsPencilMode: Bool {
        if activeGameMode == .daily {
            return persistence.loadDailyProgress()?.isPencilMode ?? statsStore.preferences.pencilModeEnabledByDefault
        }
        return savedProgress?.isPencilMode ?? statsStore.preferences.pencilModeEnabledByDefault
    }

    func finishSplash() {
        showSplash = false
        if !persistence.hasSeenHowToPlay {
            showHowToPlay = true
            AnalyticsService.logHowToPlayOpen(source: "first_launch")
        }
    }

    func openHowToPlay() {
        showHowToPlay = true
        AnalyticsService.logHowToPlayOpen(source: "home")
    }

    func closeHowToPlay(markSeen: Bool) {
        showHowToPlay = false
        if markSeen {
            persistence.markHowToPlaySeen()
        }
    }

    func requestNewGame() {
        showDifficultySheet = true
    }

    func startGame(difficulty: Difficulty) {
        showDifficultySheet = false
        activeGameMode = .campaign
        let puzzle = SudokuGenerator.generate(difficulty: difficulty, level: 1)
        activePuzzle = puzzle
        gameSessionID = UUID()
        saveCurrentProgress(isPencilMode: statsStore.preferences.pencilModeEnabledByDefault)
        AnalyticsService.logGameStart(difficulty: difficulty, level: puzzle.level, mode: .campaign)
        navigationPath.append(AppDestination.game)
    }

    func startDailyChallenge() {
        guard !statsStore.isDailyCompletedToday else { return }

        activeGameMode = .daily

        if let progress = persistence.loadDailyProgress(), progress.hasActiveGame {
            activePuzzle = progress.puzzle
        } else {
            activePuzzle = DailyChallengeService.generate()
            saveCurrentProgress(isPencilMode: statsStore.preferences.pencilModeEnabledByDefault)
        }

        gameSessionID = UUID()
        if let puzzle = activePuzzle {
            AnalyticsService.logGameStart(difficulty: puzzle.difficulty, level: puzzle.level, mode: .daily)
        }
        navigationPath.append(AppDestination.game)
    }

    func continueGame() {
        normalizeSavedProgressIfNeeded()
        savedProgress = persistence.loadProgress()
        guard let progress = savedProgress, progress.hasActiveGame else { return }
        activeGameMode = progress.gameMode
        activePuzzle = progress.puzzle
        gameSessionID = UUID()
        AnalyticsService.logGameContinue(
            difficulty: progress.puzzle.difficulty,
            level: progress.puzzle.level
        )
        navigationPath.append(AppDestination.game)
    }

    func updatePuzzle(_ puzzle: SudokuPuzzle, elapsedSeconds: Int, isPencilMode: Bool) {
        activePuzzle = puzzle
        saveCurrentProgress(elapsedSeconds: elapsedSeconds, isPencilMode: isPencilMode)
    }

    func handlePuzzleCompleted(_ puzzle: SudokuPuzzle, elapsedSeconds: Int) {
        activePuzzle = puzzle
        lastCompletionSeconds = elapsedSeconds
        statsStore.recordCompletion(
            puzzle: puzzle,
            elapsedSeconds: elapsedSeconds,
            isDaily: activeGameMode == .daily
        )
        AnalyticsService.logPuzzleComplete(
            difficulty: puzzle.difficulty,
            level: puzzle.level,
            mode: activeGameMode,
            elapsedSeconds: elapsedSeconds
        )
        showSuccessOverlay = true
    }

    func advanceToNextLevel() {
        guard activeGameMode == .campaign, let current = activePuzzle else { return }
        showSuccessOverlay = false
        let nextLevel = current.level + 1
        let nextPuzzle = SudokuGenerator.generate(difficulty: current.difficulty, level: nextLevel)
        activePuzzle = nextPuzzle
        gameSessionID = UUID()
        AnalyticsService.logNextLevel(difficulty: current.difficulty, level: nextLevel)
        saveCurrentProgress(isPencilMode: statsStore.preferences.pencilModeEnabledByDefault)
    }

    func returnHome() {
        navigationPath = NavigationPath()
        activePuzzle = nil
        showSuccessOverlay = false
        activeGameMode = .campaign
        savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    func handlePopToHome() {
        activePuzzle = nil
        showSuccessOverlay = false
        activeGameMode = .campaign
        savedProgress = persistence.loadProgress()
        normalizeSavedProgressIfNeeded()
    }

    func clearSavedGame() {
        persistence.clearProgress()
        savedProgress = nil
    }

    private func saveCurrentProgress(
        elapsedSeconds: Int = 0,
        isPencilMode: Bool? = nil
    ) {
        guard let puzzle = activePuzzle else { return }

        let pencilMode = isPencilMode ?? statsStore.preferences.pencilModeEnabledByDefault
        let progress = GameProgress(
            puzzle: puzzle,
            hasActiveGame: true,
            elapsedSeconds: elapsedSeconds,
            gameMode: activeGameMode,
            isPencilMode: pencilMode
        )

        if activeGameMode == .daily {
            persistence.saveDailyProgress(progress)
        } else {
            persistence.saveProgress(progress)
            savedProgress = progress
        }
    }

    private func normalizeSavedProgressIfNeeded() {
        guard var progress = savedProgress, progress.hasActiveGame else { return }
        guard progress.puzzle.isComplete else { return }
        guard progress.gameMode == .campaign else { return }

        let nextPuzzle = SudokuGenerator.generate(
            difficulty: progress.puzzle.difficulty,
            level: progress.puzzle.level + 1
        )
        progress = GameProgress(
            puzzle: nextPuzzle,
            hasActiveGame: true,
            elapsedSeconds: 0,
            gameMode: .campaign,
            isPencilMode: progress.isPencilMode
        )
        persistence.saveProgress(progress)
        savedProgress = progress
    }
}
