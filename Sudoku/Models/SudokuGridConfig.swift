import Foundation

struct SudokuGridConfig: Equatable, Codable {
    let size: Int
    let maxNumber: Int
    let boxHeight: Int
    let boxWidth: Int

    var boxCount: Int {
        (size / boxHeight) * (size / boxWidth)
    }

    var cellCount: Int {
        size * size
    }

    var boxesPerRow: Int {
        size / boxWidth
    }

    static let mini = SudokuGridConfig(size: 6, maxNumber: 6, boxHeight: 2, boxWidth: 3)
    static let standard = SudokuGridConfig(size: 9, maxNumber: 9, boxHeight: 3, boxWidth: 3)

    func boxIndex(row: Int, column: Int) -> Int {
        let boxRow = row / boxHeight
        let boxColumn = column / boxWidth
        return boxRow * boxesPerRow + boxColumn
    }

    func boxOrigin(for boxIndex: Int) -> (row: Int, column: Int) {
        let boxRow = boxIndex / boxesPerRow
        let boxColumn = boxIndex % boxesPerRow
        return (boxRow * boxHeight, boxColumn * boxWidth)
    }

    func isBoxRightBorder(column: Int) -> Bool {
        (column + 1) % boxWidth == 0 && column < size - 1
    }

    func isBoxBottomBorder(row: Int) -> Bool {
        (row + 1) % boxHeight == 0 && row < size - 1
    }
}
