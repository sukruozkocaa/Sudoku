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
    @State private var showSettings = false
    @State private var heroAppeared = false
    @State private var titleAppeared = false
    @State private var taglineAppeared = false
    @State private var buttonsAppeared = false
    @State private var floatOffset: CGFloat = 0
    @State private var buttonGlow = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    SudokuLogoView(size: 118, showRing: true, animateCells: true, animateRing: true)
                        .offset(y: floatOffset)
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
                            .offset(y: taglineAppeared ? 0 : 14)
                    }
                    .opacity(titleAppeared ? 1 : 0)
                    .offset(y: titleAppeared ? 0 : 22)
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
        withAnimation(.spring(response: 0.8, dampingFraction: 0.74).delay(0.05)) {
            heroAppeared = true
        }

        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true).delay(0.7)) {
            floatOffset = -7
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.28)) {
            titleAppeared = true
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.82).delay(0.42)) {
            taglineAppeared = true
        }

        withAnimation(.spring(response: 0.75, dampingFraction: 0.78).delay(0.58)) {
            buttonsAppeared = true
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.9)) {
            buttonGlow = true
        }
    }
}

#Preview {
    let themeStore = ThemeStore()

    HomeView(
        hasSavedGame: true,
        savedLevel: 3,
        savedDifficulty: .medium,
        onStart: {},
        onContinue: {},
        onShowHowToPlay: {}
    )
    .environment(themeStore)
    .themeAware(using: themeStore)
}
