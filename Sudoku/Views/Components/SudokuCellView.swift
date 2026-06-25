import SwiftUI

struct SudokuCellView: View {
    let value: Int?
    let notes: [Int]
    let maxNumber: Int
    let isFixed: Bool
    let isSelected: Bool
    let isConflict: Bool
    let isPassive: Bool
    var fontSize: CGFloat = 22
    let showRightBorder: Bool
    let showBottomBorder: Bool
    let showBoxRightBorder: Bool
    let showBoxBottomBorder: Bool

    @Environment(\.themePalette) private var theme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)

            if let value {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: isFixed ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(numberColor)
            } else if !notes.isEmpty {
                notesGrid
            }
        }
        .overlay(alignment: .trailing) {
            if showRightBorder {
                Rectangle()
                    .fill(theme.cellBorder)
                    .frame(width: showBoxRightBorder ? 2 : 0.5)
            }
        }
        .overlay(alignment: .bottom) {
            if showBottomBorder {
                Rectangle()
                    .fill(theme.cellBorder)
                    .frame(height: showBoxBottomBorder ? 2 : 0.5)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(theme.accent, lineWidth: 2)
                    .padding(2)
            }
        }
        .overlay {
            if isConflict {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(theme.error.opacity(0.8), lineWidth: 2)
                    .padding(2)
            }
        }
    }

    private var notesGrid: some View {
        let columns = maxNumber <= 6 ? 3 : 3
        let rows = Int(ceil(Double(maxNumber) / Double(columns)))

        return VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { column in
                        let number = row * columns + column + 1
                        Text(notes.contains(number) ? "\(number)" : " ")
                            .font(.system(size: noteFontSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .padding(2)
    }

    private var noteFontSize: CGFloat {
        maxNumber <= 6 ? fontSize * 0.28 : fontSize * 0.24
    }

    private var backgroundColor: Color {
        if isSelected {
            return theme.accent.opacity(0.18)
        }
        return theme.cellBackground
    }

    private var numberColor: Color {
        if isPassive {
            return theme.passiveNumber
        }
        if isFixed {
            return theme.fixedNumber
        }
        return theme.userNumber
    }
}

#Preview {
    let themeStore = ThemeStore()

    HStack {
        SudokuCellView(
            value: nil,
            notes: [1, 3, 6],
            maxNumber: 6,
            isFixed: false,
            isSelected: true,
            isConflict: false,
            isPassive: false,
            showRightBorder: true,
            showBottomBorder: true,
            showBoxRightBorder: false,
            showBoxBottomBorder: false
        )
        SudokuCellView(
            value: 7,
            notes: [],
            maxNumber: 6,
            isFixed: false,
            isSelected: false,
            isConflict: false,
            isPassive: false,
            showRightBorder: false,
            showBottomBorder: true,
            showBoxRightBorder: false,
            showBoxBottomBorder: false
        )
    }
    .frame(height: 44)
    .premiumBackground()
    .environment(themeStore)
    .themeAware(using: themeStore)
}
