import SwiftUI

struct SudokuGridView: View {
    let viewModel: GameViewModel
    let onCellTap: (Int, Int) -> Void

    @State private var flashingRegions: Set<CompletedRegion> = []

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
                    let padding: CGFloat = 8
                    let gridSpan = cellSize * CGFloat(config.size)

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
                                        Button {
                                            onCellTap(row, column)
                                        } label: {
                                            SudokuCellView(
                                                value: viewModel.cellDisplayValue(row: row, column: column),
                                                isFixed: viewModel.isFixedCell(row: row, column: column),
                                                isSelected: viewModel.isSelected(row: row, column: column),
                                                isConflict: viewModel.isConflict(row: row, column: column),
                                                isPassive: viewModel.isCellPassive(row: row, column: column),
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
                        .padding(padding)

                        ForEach(Array(flashingRegions).sorted(by: regionSortOrder), id: \.self) { region in
                            RegionFlashOverlay(
                                region: region,
                                cellSize: cellSize,
                                gridSize: config.size,
                                config: config,
                                padding: padding
                            ) {
                                flashingRegions.remove(region)
                            }
                        }
                    }
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: 320)
            .onChange(of: viewModel.pendingCompletionFlashes) { _, flashes in
                guard !flashes.isEmpty else { return }
                flashingRegions.formUnion(flashes)
                viewModel.clearCompletionFlashes()
            }
    }

    private func regionSortOrder(_ lhs: CompletedRegion, _ rhs: CompletedRegion) -> Bool {
        String(describing: lhs) < String(describing: rhs)
    }
}

private struct RegionFlashOverlay: View {
    let region: CompletedRegion
    let cellSize: CGFloat
    let gridSize: Int
    let config: SudokuGridConfig
    let padding: CGFloat
    let onFinished: () -> Void

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.92

    var body: some View {
        let frame = regionFrame
        let position = regionPosition

        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(AppTheme.success.opacity(0.22))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.success, lineWidth: 3)
            )
            .frame(width: frame.width, height: frame.height)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(x: position.x, y: position.y)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    opacity = 1
                    scale = 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onFinished()
                    }
                }
            }
    }

    private var regionFrame: (width: CGFloat, height: CGFloat) {
        let gridSpan = cellSize * CGFloat(gridSize)

        switch region {
        case .box(let boxIndex):
            let boxWidth = cellSize * CGFloat(config.boxWidth)
            let boxHeight = cellSize * CGFloat(config.boxHeight)
            return (boxWidth - 4, boxHeight - 4)
        case .row:
            return (gridSpan - 4, cellSize - 4)
        case .column:
            return (cellSize - 4, gridSpan - 4)
        }
    }

    private var regionPosition: (x: CGFloat, y: CGFloat) {
        let gridSpan = cellSize * CGFloat(gridSize)
        let centerX = padding + gridSpan / 2
        let centerY = padding + gridSpan / 2

        switch region {
        case .box(let boxIndex):
            let origin = config.boxOrigin(for: boxIndex)
            let boxWidth = cellSize * CGFloat(config.boxWidth)
            let boxHeight = cellSize * CGFloat(config.boxHeight)
            let x = padding + CGFloat(origin.column) * cellSize + boxWidth / 2
            let y = padding + CGFloat(origin.row) * cellSize + boxHeight / 2
            return (x, y)
        case .row(let row):
            let y = padding + CGFloat(row) * cellSize + cellSize / 2
            return (centerX, y)
        case .column(let column):
            let x = padding + CGFloat(column) * cellSize + cellSize / 2
            return (x, centerY)
        }
    }
}

#Preview {
    let puzzle = SudokuGenerator.generate(difficulty: .easy, level: 1)
    SudokuGridView(viewModel: GameViewModel(puzzle: puzzle)) { _, _ in }
        .padding()
        .premiumBackground()
}
