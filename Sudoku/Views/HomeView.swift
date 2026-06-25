import SwiftUI

struct HomeView: View {
    let hasSavedGame: Bool
    let savedLevel: Int?
    let savedDifficulty: Difficulty?
    let onStart: () -> Void
    let onContinue: () -> Void
    let onShowHowToPlay: () -> Void
    let onDailyChallenge: () -> Void

    @Environment(\.themePalette) private var theme
    @Environment(ThemeStore.self) private var themeStore
    @Environment(FeedbackStore.self) private var feedbackStore
    @Environment(StatsStore.self) private var statsStore
    @State private var showSettings = false
    @State private var heroAppeared = false
    @State private var titleAppeared = false
    @State private var taglineAppeared = false
    @State private var buttonsAppeared = false
    @State private var buttonGlow = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 28) {
                    SudokuLogoView(size: 118, showRing: true, animateCells: false, animateRing: true, animateGlow: false)
                        .opacity(heroAppeared ? 1 : 0)
                        .scaleEffect(heroAppeared ? 1 : 0.82)

                    VStack(spacing: 14) {
                        Text(L10n.appName)
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.accentGradient)
                            .shadow(color: theme.accent.opacity(0.35), radius: 18, y: 6)

                        Text(L10n.homeTagline)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(taglineAppeared ? 1 : 0)
                    }
                    .opacity(titleAppeared ? 1 : 0)
                }

                Spacer(minLength: 32)

                VStack(spacing: 16) {
                    if statsStore.stats.currentStreak > 0 {
                        streakBadge
                            .opacity(buttonsAppeared ? 1 : 0)
                    }

                    dailyChallengeCard
                        .padding(.horizontal, 28)
                        .opacity(buttonsAppeared ? 1 : 0)

                    VStack(spacing: 14) {
                        if hasSavedGame {
                            Button(action: onContinue) {
                                VStack(spacing: 4) {
                                    Text(L10n.continueGame)
                                    if let savedLevel, let savedDifficulty {
                                        Text(L10n.savedProgress(level: savedLevel, difficulty: savedDifficulty.title))
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .opacity(0.85)
                                    }
                                }
                            }
                            .buttonStyle(PremiumButtonStyle())
                        }

                        Button(action: onStart) {
                            Text(hasSavedGame ? L10n.newGame : L10n.start)
                        }
                        .buttonStyle(PremiumButtonStyle(isSecondary: hasSavedGame))
                        .overlay {
                            if !hasSavedGame {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(theme.accent.opacity(buttonGlow ? 0.45 : 0.15), lineWidth: 1.5)
                                    .scaleEffect(buttonGlow ? 1.04 : 1)
                                    .blur(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .opacity(buttonsAppeared ? 1 : 0)
                }
                .padding(.bottom, 48)
            }

            VStack {
                HStack {
                    iconButton(systemName: "gearshape.fill", accessibility: L10n.settingsTitle) {
                        showSettings = true
                    }

                    Spacer()

                    iconButton(systemName: "info.circle.fill", accessibility: L10n.howToPlayTitle) {
                        onShowHowToPlay()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .opacity(buttonsAppeared ? 1 : 0)

                Spacer()
            }
        }
        .premiumBackground(animated: true)
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .environment(themeStore)
                .environment(feedbackStore)
                .environment(statsStore)
        }
        .onAppear {
            runEntranceAnimations()
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text(L10n.streakDays(statsStore.stats.currentStreak))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(theme.cardBackground, in: Capsule())
        .overlay(
            Capsule()
                .stroke(theme.cardBorder, lineWidth: 1)
        )
    }

    private var dailyChallengeCard: some View {
        Button(action: onDailyChallenge) {
            HStack(spacing: 16) {
                Image(systemName: statsStore.isDailyCompletedToday ? "checkmark.seal.fill" : "calendar")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(statsStore.isDailyCompletedToday ? theme.success : theme.accent)
                    .frame(width: 52, height: 52)
                    .background(theme.accent.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.dailyChallengeTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)

                    Text(dailySubtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                if !statsStore.isDailyCompletedToday {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(statsStore.isDailyCompletedToday)
    }

    private var dailySubtitle: String {
        if statsStore.isDailyCompletedToday {
            return L10n.dailyChallengeDone
        }
        if statsStore.hasDailyInProgress {
            return L10n.dailyChallengeContinue
        }
        return L10n.dailyChallengeSubtitle
    }

    private func iconButton(systemName: String, accessibility: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(theme.cardBackground)
                        .overlay(
                            Circle()
                                .stroke(theme.cardBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
    }

    private func runEntranceAnimations() {
        withAnimation(.easeOut(duration: 0.55).delay(0.05)) {
            heroAppeared = true
        }

        withAnimation(.easeOut(duration: 0.45).delay(0.2)) {
            titleAppeared = true
        }

        withAnimation(.easeOut(duration: 0.45).delay(0.32)) {
            taglineAppeared = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.44)) {
            buttonsAppeared = true
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.9)) {
            buttonGlow = true
        }
    }
}

#Preview {
    let themeStore = ThemeStore()
    let feedbackStore = FeedbackStore()
    let statsStore = StatsStore()

    HomeView(
        hasSavedGame: true,
        savedLevel: 3,
        savedDifficulty: .medium,
        onStart: {},
        onContinue: {},
        onShowHowToPlay: {},
        onDailyChallenge: {}
    )
    .environment(themeStore)
    .environment(feedbackStore)
    .environment(statsStore)
    .themeAware(using: themeStore)
}
