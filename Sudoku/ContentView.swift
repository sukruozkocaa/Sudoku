import SwiftUI

struct ContentView: View {
    @State private var coordinator: AppCoordinatorViewModel

    init(statsStore: StatsStore) {
        _coordinator = State(initialValue: AppCoordinatorViewModel(statsStore: statsStore))
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeView(
                    hasSavedGame: coordinator.hasSavedGame,
                    savedLevel: coordinator.resumeLevel,
                    savedDifficulty: coordinator.resumeDifficulty,
                    onStart: {
                        coordinator.requestNewGame()
                    },
                    onContinue: {
                        coordinator.continueGame()
                    },
                    onShowHowToPlay: {
                        coordinator.openHowToPlay()
                    },
                    onDailyChallenge: {
                        coordinator.startDailyChallenge()
                    }
                )
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .game:
                        if let puzzle = coordinator.activePuzzle {
                            GameView(
                                puzzle: puzzle,
                                elapsedSeconds: coordinator.activeElapsedSeconds,
                                isPencilMode: coordinator.activeIsPencilMode,
                                gameMode: coordinator.activeGameMode,
                                onPuzzleUpdated: { updated, elapsed, pencilMode in
                                    coordinator.updatePuzzle(updated, elapsedSeconds: elapsed, isPencilMode: pencilMode)
                                },
                                onPuzzleCompleted: { completed, elapsed in
                                    coordinator.handlePuzzleCompleted(completed, elapsedSeconds: elapsed)
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
                    completionTime: coordinator.lastCompletionSeconds,
                    isDaily: coordinator.activeGameMode == .daily,
                    showsNextLevel: coordinator.activeGameMode == .campaign,
                    onNextLevel: {
                        coordinator.showSuccessOverlay = false
                        DispatchQueue.main.async {
                            InterstitialAdManager.shared.showAdIfAppropriate(for: .nextLevel) {
                                coordinator.advanceToNextLevel()
                            }
                        }
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

            if coordinator.showHowToPlay && coordinator.navigationPath.isEmpty {
                HowToPlayView(
                    onFinish: {
                        coordinator.closeHowToPlay(markSeen: true)
                    },
                    onSkip: {
                        coordinator.closeHowToPlay(markSeen: true)
                    }
                )
                .transition(.opacity)
                .zIndex(4)
            }
        }
        .background {
            AdPresentationAnchorView()
                .frame(width: 0, height: 0)
        }
        .animation(.easeInOut(duration: 0.5), value: coordinator.showSplash)
        .animation(.easeInOut(duration: 0.3), value: coordinator.showHowToPlay)
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
    let themeStore = ThemeStore()
    let feedbackStore = FeedbackStore()
    let statsStore = StatsStore()

    ContentView(statsStore: statsStore)
        .environment(themeStore)
        .environment(feedbackStore)
        .environment(statsStore)
        .themeAware(using: themeStore)
}
