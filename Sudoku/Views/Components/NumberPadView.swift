import SwiftUI

struct NumberPadView: View {
    let config: SudokuGridConfig
    @Binding var isPencilMode: Bool
    let onNumberTap: (Int) -> Void
    let onClear: () -> Void
    let onUndo: () -> Void

    @Environment(\.themePalette) private var theme

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
                pencilButton
                actionButton(title: L10n.delete, systemImage: "xmark", action: onClear)
                actionButton(title: L10n.undo, systemImage: "arrow.uturn.backward", action: onUndo)
            }
        }
    }

    private var pencilButton: some View {
        Button {
            isPencilMode.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isPencilMode ? "pencil.circle.fill" : "pencil.circle")
                    .font(.system(size: 15, weight: .semibold))
                Text(L10n.notes)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isPencilMode ? theme.accent : theme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isPencilMode ? theme.accent.opacity(0.12) : theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isPencilMode ? theme.accent.opacity(0.35) : theme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func numberButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
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
            .foregroundStyle(theme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackground)
        }
        .buttonStyle(.plain)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
    }
}

#Preview {
    @Previewable @State var pencilMode = true
    let themeStore = ThemeStore()

    NumberPadView(config: .mini, isPencilMode: $pencilMode, onNumberTap: { _ in }, onClear: {}, onUndo: {})
        .padding()
        .premiumBackground()
        .environment(themeStore)
        .themeAware(using: themeStore)
}
