import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(theme.textSecondary.opacity(0.35))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 24)

            Text(L10n.settingsTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .padding(.bottom, 8)

            Text(L10n.settingsAppearanceNote)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

            VStack(spacing: 12) {
                ForEach(AppAppearance.allCases) { appearance in
                    appearanceButton(for: appearance)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 16)

            Text(AppInfo.versionLabel)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary.opacity(0.7))
                .padding(.bottom, 12)
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

    private func appearanceButton(for appearance: AppAppearance) -> some View {
        let isSelected = themeStore.appearance == appearance

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                themeStore.appearance = appearance
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon(for: appearance))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 44, height: 44)
                    .background(theme.accent.opacity(0.15), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: appearance))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)

                    Text(subtitle(for: appearance))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(theme.accent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected ? theme.accent.opacity(0.5) : theme.cardBorder, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func icon(for appearance: AppAppearance) -> String {
        switch appearance {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    private func title(for appearance: AppAppearance) -> String {
        switch appearance {
        case .system: L10n.appearanceSystem
        case .light: L10n.appearanceLight
        case .dark: L10n.appearanceDark
        }
    }

    private func subtitle(for appearance: AppAppearance) -> String {
        switch appearance {
        case .system: L10n.appearanceSystemSubtitle
        case .light: L10n.appearanceLightSubtitle
        case .dark: L10n.appearanceDarkSubtitle
        }
    }
}

#Preview {
    let themeStore = ThemeStore()

    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            SettingsSheet()
                .environment(themeStore)
        }
        .environment(themeStore)
        .themeAware(using: themeStore)
}
