import SwiftUI

struct SudokuGridView: View {
    let viewModel: GameViewModel
    let onCellTap: (Int, Int) -> Void

    private var config: SudokuGridConfig {
        viewModel.gridConfig
    }

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let cellSize = size / CGFloat(config.size)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(AppTheme.cardBorder, lineWidth: 1)
                            )

                        VStack(spacing: 0) {
                            ForEach(0..<config.size, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<config.size, id: \.self) { column in
                                        let boxIndex = config.boxIndex(row: row, column: column)
                                        let isPassive = viewModel.isBoxCompleted(boxIndex)

                                        Button {
                                            onCellTap(row, column)
                                        } label: {
                                            SudokuCellView(
                                                value: viewModel.cellDisplayValue(row: row, column: column),
                                                isFixed: viewModel.isFixedCell(row: row, column: column),
                                                isSelected: viewModel.isSelected(row: row, column: column),
                                                isConflict: viewModel.isConflict(row: row, column: column),
                                                isPassive: isPassive,
                                                fontSize: 26,
                                                showRightBorder: column < config.size - 1,
                                                showBottomBorder: row < config.size - 1,
                                                showBoxRightBorder: config.isBoxRightBorder(column: column),
                                                showBoxBottomBorder: config.isBoxBottomBorder(row: row)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!viewModel.isCellEditable(row: row, column: column) && !viewModel.isFixedCell(row: row, column: column))
                                        .frame(width: cellSize, height: cellSize)
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(8)

                        ForEach(0..<config.boxCount, id: \.self) { boxIndex in
                            if viewModel.isBoxCompleted(boxIndex) {
                                completedBoxOverlay(boxIndex: boxIndex, cellSize: cellSize)
                            }
                        }
                    }
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: 320)
    }

    @ViewBuilder
    private func completedBoxOverlay(boxIndex: Int, cellSize: CGFloat) -> some View {
        let origin = config.boxOrigin(for: boxIndex)
        let padding: CGFloat = 8
        let x = padding + CGFloat(origin.column) * cellSize
        let y = padding + CGFloat(origin.row) * cellSize
        let boxWidth = cellSize * CGFloat(config.boxWidth)
        let boxHeight = cellSize * CGFloat(config.boxHeight)

        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(AppTheme.success, lineWidth: 3)
            .frame(width: boxWidth - 4, height: boxHeight - 4)
            .position(x: x + boxWidth / 2, y: y + boxHeight / 2)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.45, dampingFraction: 0.7), value: viewModel.isBoxCompleted(boxIndex))
    }
}

#Preview {
    let puzzle = SudokuGenerator.generate(difficulty: .easy, level: 1)
    SudokuGridView(viewModel: GameViewModel(puzzle: puzzle)) { _, _ in }
        .padding()
        .premiumBackground()
}
