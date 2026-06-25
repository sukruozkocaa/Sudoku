import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(ThemeStore.self) private var themeStore
    @Environment(FeedbackStore.self) private var feedbackStore
    @Environment(StatsStore.self) private var statsStore
    @Environment(RemoteConfigStore.self) private var remoteConfigStore
    @Environment(\.themePalette) private var theme

    var body: some View {
        ScrollView {
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
                    .padding(.bottom, 20)

                VStack(spacing: 12) {
                    ForEach(AppAppearance.allCases) { appearance in
                        appearanceButton(for: appearance)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                Text(L10n.settingsFeedbackNote)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                VStack(spacing: 12) {
                    feedbackToggle(
                        icon: "iphone.radiowaves.left.and.right",
                        title: L10n.settingsHaptics,
                        subtitle: L10n.settingsHapticsSubtitle,
                        isOn: Bindable(feedbackStore).hapticsEnabled
                    )

                    feedbackToggle(
                        icon: "speaker.wave.2.fill",
                        title: L10n.settingsSounds,
                        subtitle: L10n.settingsSoundsSubtitle,
                        isOn: Bindable(feedbackStore).soundsEnabled
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                if remoteConfigStore.config.pencilNotesEnabled {
                    Text(L10n.settingsGameplayNote)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        feedbackToggle(
                            icon: "pencil.and.outline",
                            title: L10n.settingsPencilDefault,
                            subtitle: L10n.settingsPencilDefaultSubtitle,
                            isOn: Bindable(statsStore).pencilModeEnabledByDefault
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                if remoteConfigStore.config.statsEnabled {
                    Text(L10n.settingsStatsNote)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        statRow(icon: "checkmark.circle.fill", title: L10n.statPuzzlesCompleted, value: "\(statsStore.stats.puzzlesCompleted)")
                        statRow(icon: "flame.fill", title: L10n.statBestStreak, value: "\(max(statsStore.stats.bestStreak, statsStore.stats.currentStreak))")
                        statRow(icon: "clock.fill", title: L10n.statPlayTime, value: StatsStore.formatDurationLong(statsStore.stats.totalPlayTimeSeconds))
                        statRow(icon: "calendar.circle.fill", title: L10n.statDailyCompleted, value: "\(statsStore.stats.dailyCompletedCount)")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                if remoteConfigStore.config.achievementsEnabled {
                    Text(L10n.settingsAchievements)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        ForEach(AchievementID.allCases) { achievement in
                            achievementRow(achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                rateAppButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                #if DEBUG
                RemoteConfigDebugPanel()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                #endif

                Text(AppInfo.versionLabel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary.opacity(0.7))
                    .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.large])
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

    private func feedbackToggle(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 44, height: 44)
                .background(theme.accent.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(theme.accent)
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

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 44, height: 44)
                .background(theme.accent.opacity(0.15), in: Circle())

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accent)
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

    private func achievementRow(_ achievement: AchievementID) -> some View {
        let unlocked = statsStore.isAchievementUnlocked(achievement)

        return HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(unlocked ? theme.accent : theme.textSecondary.opacity(0.45))
                .frame(width: 44, height: 44)
                .background((unlocked ? theme.accent : theme.textSecondary).opacity(0.12), in: Circle())

            Text(achievement.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(unlocked ? theme.textPrimary : theme.textSecondary)

            Spacer()

            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(unlocked ? theme.success : theme.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(unlocked ? theme.success.opacity(0.35) : theme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var rateAppButton: some View {
        Button {
            openURL(AppInfo.appStoreReviewURL)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 44, height: 44)
                    .background(theme.accent.opacity(0.15), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.settingsRateApp)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)

                    Text(L10n.settingsRateAppSubtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
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
    let feedbackStore = FeedbackStore()
    let statsStore = StatsStore()

    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            SettingsSheet()
                .environment(themeStore)
                .environment(feedbackStore)
                .environment(statsStore)
                .environment(RemoteConfigStore.shared)
        }
        .environment(themeStore)
        .environment(feedbackStore)
        .environment(statsStore)
        .environment(RemoteConfigStore.shared)
        .themeAware(using: themeStore)
}
