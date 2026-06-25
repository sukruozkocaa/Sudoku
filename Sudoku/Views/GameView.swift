import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme
    @Environment(RemoteConfigStore.self) private var remoteConfigStore

    @State private var viewModel: GameViewModel
    let gameMode: GameMode
    let onPuzzleUpdated: (SudokuPuzzle, Int, Bool) -> Void
    let onPuzzleCompleted: (SudokuPuzzle, Int) -> Void

    init(
        puzzle: SudokuPuzzle,
        elapsedSeconds: Int = 0,
        isPencilMode: Bool = true,
        gameMode: GameMode = .campaign,
        onPuzzleUpdated: @escaping (SudokuPuzzle, Int, Bool) -> Void,
        onPuzzleCompleted: @escaping (SudokuPuzzle, Int) -> Void
    ) {
        _viewModel = State(
            initialValue: GameViewModel(
                puzzle: puzzle,
                elapsedSeconds: elapsedSeconds,
                isPencilMode: isPencilMode
            )
        )
        self.gameMode = gameMode
        self.onPuzzleUpdated = onPuzzleUpdated
        self.onPuzzleCompleted = onPuzzleCompleted
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            timerBar
                .padding(.top, 8)
                .padding(.bottom, 4)

            Spacer(minLength: 16)

            SudokuGridView(viewModel: viewModel) { row, column in
                viewModel.selectCell(row: row, column: column)
            }
            .padding(.horizontal, 40)

            if remoteConfigStore.config.hintsEnabled {
                hintBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }

            Spacer(minLength: 20)

            NumberPadView(
                config: viewModel.gridConfig,
                isPencilMode: Bindable(viewModel).isPencilMode,
                showPencilNotes: remoteConfigStore.config.pencilNotesEnabled,
                onNumberTap: { number in
                    viewModel.enterNumber(number)
                },
                onClear: {
                    viewModel.clearSelectedCell()
                },
                onUndo: {
                    viewModel.undoLastMove()
                }
            )
            .padding(.horizontal, 28)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .premiumBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !remoteConfigStore.config.pencilNotesEnabled {
                viewModel.isPencilMode = false
            }
            viewModel.onPuzzleUpdated = onPuzzleUpdated
            viewModel.onPuzzleCompleted = onPuzzleCompleted

            DispatchQueue.main.async {
                InterstitialAdManager.shared.showAdIfAppropriate(for: .gameplayEntry) {
                    viewModel.startTimerIfNeeded()
                }
            }
        }
        .onChange(of: viewModel.isPencilMode) { _, _ in
            viewModel.onPuzzleUpdated?(viewModel.puzzle, viewModel.elapsedSeconds, viewModel.isPencilMode)
        }
        .onDisappear {
            persistProgress()
            guard !InterstitialAdManager.shared.isPresentingAd else { return }
            viewModel.stopTimer()
        }
        .overlay {
            if let hint = viewModel.activeHint {
                HintPopupView(
                    puzzle: viewModel.puzzle,
                    suggestion: hint,
                    onApply: {
                        AnalyticsService.logHintUsed(
                            difficulty: viewModel.puzzle.difficulty,
                            level: viewModel.puzzle.level,
                            mode: gameMode
                        )
                        viewModel.confirmHint()
                    },
                    onCancel: {
                        viewModel.cancelHint()
                    }
                )
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.activeHint != nil)
    }

    private func persistProgress() {
        onPuzzleUpdated(viewModel.puzzle, viewModel.elapsedSeconds, viewModel.isPencilMode)
    }

    private var header: some View {
        HStack {
            Button {
                persistProgress()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(theme.cardBackground, in: Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(gameMode == .daily ? L10n.dailyChallengeTitle : viewModel.levelText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                Text(gameMode == .daily ? L10n.dailyChallengeSubtitle : viewModel.difficultyText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private var timerBar: some View {
        Text(viewModel.formattedElapsedTime)
            .font(.system(size: 18, weight: .semibold, design: .monospaced))
            .foregroundStyle(theme.accent)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(theme.cardBackground, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
            .frame(maxWidth: .infinity)
    }

    private var hintBar: some View {
        HStack(spacing: 12) {
            Button {
                InterstitialAdManager.shared.showAdIfAppropriate(for: .hint) {
                    viewModel.requestHint()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(L10n.hint)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(theme.accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(theme.accent.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        GameView(
            puzzle: SudokuGenerator.generate(difficulty: .easy, level: 1),
            onPuzzleUpdated: { _, _, _ in },
            onPuzzleCompleted: { _, _ in }
        )
        .environment(RemoteConfigStore.shared)
    }
}
