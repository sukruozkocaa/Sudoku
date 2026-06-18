import SwiftUI

struct DifficultySheet: View {
    let onSelect: (Difficulty) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 24)

            Text(L10n.selectDifficulty)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.bottom, 8)

            Text(L10n.difficultyProgressNote)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
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
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.accent.opacity(0.15), in: Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(difficulty.title)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)

                                Text(difficulty.subtitle)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppTheme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(AppTheme.cardBorder, lineWidth: 1)
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
            AppTheme.backgroundBottom
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
