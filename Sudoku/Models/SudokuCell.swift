import Foundation

struct SudokuCell: Identifiable, Equatable, Codable {
    let row: Int
    let column: Int
    var value: Int?
    let isFixed: Bool

    var id: String { "\(row)-\(column)" }

    var boxIndex: Int {
        (row / 3) * 3 + (column / 3)
    }

    init(row: Int, column: Int, value: Int?, isFixed: Bool) {
        self.row = row
        self.column = column
        self.value = value
        self.isFixed = isFixed
    }
}
