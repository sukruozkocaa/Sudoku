import SwiftUI

struct NumberPadView: View {
    let config: SudokuGridConfig
    let onNumberTap: (Int) -> Void
    let onClear: () -> Void
    let onUndo: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...config.maxNumber, id: \.self) { number in
                    numberButton("\(number)") {
                        onNumberTap(number)
                    }
                }
            }

            HStack(spacing: 10) {
                actionButton(title: L10n.delete, systemImage: "xmark", action: onClear)
                actionButton(title: L10n.undo, systemImage: "arrow.uturn.backward", action: onUndo)
            }
        }
    }

    private func numberButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(buttonBackground)
        }
        .buttonStyle(.plain)
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackground)
        }
        .buttonStyle(.plain)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
    }
}

#Preview {
    NumberPadView(config: .mini, onNumberTap: { _ in }, onClear: {}, onUndo: {})
        .padding()
        .premiumBackground()
}
