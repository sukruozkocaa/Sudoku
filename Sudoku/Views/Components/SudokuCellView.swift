import SwiftUI

struct SudokuCellView: View {
    let value: Int?
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
            value: 5,
            isFixed: true,
            isSelected: false,
            isConflict: false,
            isPassive: false,
            showRightBorder: true,
            showBottomBorder: true,
            showBoxRightBorder: false,
            showBoxBottomBorder: false
        )
        SudokuCellView(
            value: 7,
            isFixed: false,
            isSelected: true,
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
