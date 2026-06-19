import SwiftUI

struct DifficultySheet: View {
    let onSelect: (Difficulty) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(theme.textSecondary.opacity(0.35))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 24)

            Text(L10n.selectDifficulty)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .padding(.bottom, 8)

            Text(L10n.difficultyProgressNote)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

            VStack(spacing: 12) {
                ForEach(Difficulty.allCases) { difficulty in
                    Button {
                        onSelect(difficulty)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: difficulty.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(theme.accent)
                                .frame(width: 44, height: 44)
                                .background(theme.accent.opacity(0.15), in: Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(difficulty.title)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary)

                                Text(difficulty.subtitle)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(theme.textSecondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(theme.cardBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
        .presentationBackground {
            theme.sheetBackground
                .ignoresSafeArea()
        }
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            DifficultySheet(onSelect: { _ in })
        }
}
