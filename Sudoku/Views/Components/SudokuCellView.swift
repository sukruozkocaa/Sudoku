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
                    .fill(Color.white.opacity(0.18))
                    .frame(width: showBoxRightBorder ? 2 : 0.5)
            }
        }
        .overlay(alignment: .bottom) {
            if showBottomBorder {
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: showBoxBottomBorder ? 2 : 0.5)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.accent, lineWidth: 2)
                    .padding(2)
            }
        }
        .overlay {
            if isConflict {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.error.opacity(0.8), lineWidth: 2)
                    .padding(2)
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return AppTheme.accent.opacity(0.18)
        }
        return Color.white.opacity(0.03)
    }

    private var numberColor: Color {
        if isPassive {
            return AppTheme.passiveNumber
        }
        if isFixed {
            return AppTheme.fixedNumber
        }
        return AppTheme.userNumber
    }
}

#Preview {
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
}
