import SwiftUI

struct HintPopupView: View {
    let puzzle: SudokuPuzzle
    let suggestion: HintSuggestion
    let onApply: () -> Void
    let onCancel: () -> Void

    @State private var appear = false

    private var config: SudokuGridConfig {
        puzzle.gridConfig
    }

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.58 : 0)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)

                    Text(L10n.hintPopupTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Spacer()
                }

                HintGridPreview(
                    puzzle: puzzle,
                    highlightedRow: suggestion.row,
                    highlightedColumn: suggestion.column
                )
                .frame(maxWidth: 220)

                VStack(spacing: 10) {
                    Text(L10n.hintSuggestedNumber)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("\(suggestion.value)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accentGradient)
                        .frame(width: 84, height: 84)
                        .background(
                            Circle()
                                .fill(AppTheme.accent.opacity(0.12))
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.accent.opacity(0.35), lineWidth: 1.5)
                                )
                        )
                }

                Text(suggestion.explanation)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(L10n.hintCancel)
                    }
                    .buttonStyle(PremiumButtonStyle(isSecondary: true))

                    Button(action: onApply) {
                        Text(L10n.hintApply)
                    }
                    .buttonStyle(PremiumButtonStyle())
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.backgroundBottom)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 28)
            .scaleEffect(appear ? 1 : 0.92)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                appear = true
            }
        }
    }
}

private struct HintGridPreview: View {
    let puzzle: SudokuPuzzle
    let highlightedRow: Int
    let highlightedColumn: Int

    private var config: SudokuGridConfig {
        puzzle.gridConfig
    }

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let cellSize = size / CGFloat(config.size)
                    let padding: CGFloat = 6
                    let boxIndex = config.boxIndex(row: highlightedRow, column: highlightedColumn)

                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppTheme.cardBorder, lineWidth: 1)
                            )

                        VStack(spacing: 0) {
                            ForEach(0..<config.size, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<config.size, id: \.self) { column in
                                        let isTarget = row == highlightedRow && column == highlightedColumn
                                        let isSameRow = row == highlightedRow
                                        let isSameColumn = column == highlightedColumn
                                        let isSameBox = config.boxIndex(row: row, column: column) == boxIndex
                                        let isPassive = puzzle.completedBoxes.contains(config.boxIndex(row: row, column: column))
                                            || puzzle.completedRows.contains(row)
                                            || puzzle.completedColumns.contains(column)

                                        SudokuCellView(
                                            value: puzzle.userGrid[row][column],
                                            isFixed: puzzle.initialGrid[row][column] != nil,
                                            isSelected: isTarget,
                                            isConflict: false,
                                            isPassive: isPassive,
                                            fontSize: config.size <= 6 ? 18 : 14,
                                            showRightBorder: column < config.size - 1,
                                            showBottomBorder: row < config.size - 1,
                                            showBoxRightBorder: config.isBoxRightBorder(column: column),
                                            showBoxBottomBorder: config.isBoxBottomBorder(row: row)
                                        )
                                        .background {
                                            if !isTarget && (isSameRow || isSameColumn || isSameBox) {
                                                Rectangle()
                                                    .fill(AppTheme.accent.opacity(0.08))
                                            }
                                        }
                                        .frame(width: cellSize, height: cellSize)
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(padding)
                    }
                }
            }
    }
}

#Preview {
    let puzzle = SudokuGenerator.generate(difficulty: .easy, level: 1)
    let suggestion = HintExplanationService.build(puzzle: puzzle, row: 0, column: 2)

    HintPopupView(
        puzzle: puzzle,
        suggestion: suggestion,
        onApply: {},
        onCancel: {}
    )
    .premiumBackground()
}
