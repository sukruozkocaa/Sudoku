import SwiftUI

struct ContentView: View {
    @State private var coordinator = AppCoordinatorViewModel()

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeView(
                    hasSavedGame: coordinator.hasSavedGame,
                    savedLevel: coordinator.savedProgress?.puzzle.level,
                    savedDifficulty: coordinator.savedProgress?.puzzle.difficulty,
                    onStart: {
                        coordinator.requestNewGame()
                    },
                    onContinue: {
                        coordinator.continueGame()
                    }
                )
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .game:
                        if let puzzle = coordinator.activePuzzle {
                            GameView(
                                puzzle: puzzle,
                                onPuzzleUpdated: { updated in
                                    coordinator.updatePuzzle(updated)
                                },
                                onPuzzleCompleted: { completed in
                                    coordinator.handlePuzzleCompleted(completed)
                                }
                            )
                            .id(coordinator.gameSessionID)
                        }
                    }
                }
            }

            if coordinator.showSuccessOverlay, let puzzle = coordinator.activePuzzle {
                SuccessOverlay(
                    level: puzzle.level,
                    onNextLevel: {
                        coordinator.advanceToNextLevel()
                    },
                    onHome: {
                        coordinator.returnHome()
                    }
                )
                .zIndex(2)
            }

            if coordinator.showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: coordinator.showSplash)
        .sheet(isPresented: $coordinator.showDifficultySheet) {
            DifficultySheet { difficulty in
                coordinator.startGame(difficulty: difficulty)
            }
        }
        .onChange(of: coordinator.navigationPath.count) { _, count in
            if count == 0 {
                coordinator.handlePopToHome()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    coordinator.finishSplash()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
