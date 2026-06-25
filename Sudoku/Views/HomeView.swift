import SwiftUI

struct HomeView: View {
    let hasSavedGame: Bool
    let savedLevel: Int?
    let savedDifficulty: Difficulty?
    let onStart: () -> Void
    let onContinue: () -> Void
    let onShowHowToPlay: () -> Void

    @Environment(\.themePalette) private var theme
    @Environment(ThemeStore.self) private var themeStore
    @Environment(FeedbackStore.self) private var feedbackStore
    @State private var showSettings = false
    @State private var heroAppeared = false
    @State private var titleAppeared = false
    @State private var taglineAppeared = false
    @State private var buttonsAppeared = false
    @State private var buttonGlow = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

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

                Spacer()

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
                        .opacity(buttonsAppeared ? 1 : 0)
                        .offset(y: buttonsAppeared ? 0 : 24)
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
                    .opacity(buttonsAppeared ? 1 : 0)
                    .offset(y: buttonsAppeared ? 0 : 28)
                }
                .padding(.horizontal, 28)
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
        }
        .onAppear {
            runEntranceAnimations()
        }
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

    HomeView(
        hasSavedGame: true,
        savedLevel: 3,
        savedDifficulty: .medium,
        onStart: {},
        onContinue: {},
        onShowHowToPlay: {}
    )
    .environment(themeStore)
    .environment(feedbackStore)
    .themeAware(using: themeStore)
}
