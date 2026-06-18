import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GameViewModel
    let onPuzzleUpdated: (SudokuPuzzle) -> Void
    let onPuzzleCompleted: (SudokuPuzzle) -> Void

    init(
        puzzle: SudokuPuzzle,
        onPuzzleUpdated: @escaping (SudokuPuzzle) -> Void,
        onPuzzleCompleted: @escaping (SudokuPuzzle) -> Void
    ) {
        _viewModel = State(initialValue: GameViewModel(puzzle: puzzle))
        self.onPuzzleUpdated = onPuzzleUpdated
        self.onPuzzleCompleted = onPuzzleCompleted
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 20)

            SudokuGridView(viewModel: viewModel) { row, column in
                viewModel.selectCell(row: row, column: column)
            }
            .padding(.horizontal, 40)

            if viewModel.showsHint {
                hintBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }

            Spacer(minLength: 20)

            NumberPadView(
                config: viewModel.gridConfig,
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
            viewModel.onPuzzleUpdated = onPuzzleUpdated
            viewModel.onPuzzleCompleted = onPuzzleCompleted
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBackground, in: Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(viewModel.levelText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(viewModel.difficultyText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private var hintBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.useHint()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(L10n.hint)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppTheme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppTheme.accent.opacity(0.25), lineWidth: 1)
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
            onPuzzleUpdated: { _ in },
            onPuzzleCompleted: { _ in }
        )
    }
}
