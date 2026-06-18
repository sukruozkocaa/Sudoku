import SwiftUI

struct HomeView: View {
    let hasSavedGame: Bool
    let savedLevel: Int?
    let savedDifficulty: Difficulty?
    let onStart: () -> Void
    let onContinue: () -> Void
    let onShowHowToPlay: () -> Void

    @State private var heroAppeared = false
    @State private var titleAppeared = false
    @State private var taglineAppeared = false
    @State private var buttonsAppeared = false
    @State private var floatOffset: CGFloat = 0
    @State private var buttonGlow = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
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
                            .foregroundStyle(AppTheme.accentGradient)
                            .shadow(color: AppTheme.accent.opacity(0.35), radius: 18, y: 6)

                        Text(L10n.homeTagline)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
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
                                .stroke(AppTheme.accent.opacity(buttonGlow ? 0.45 : 0.15), lineWidth: 1.5)
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

            Button(action: onShowHowToPlay) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.howToPlayTitle)
            .padding(.top, 8)
            .padding(.trailing, 24)
            .opacity(buttonsAppeared ? 1 : 0)
        }
        .premiumBackground(animated: true)
        .onAppear {
            runEntranceAnimations()
        }
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
    HomeView(
        hasSavedGame: true,
        savedLevel: 3,
        savedDifficulty: .medium,
        onStart: {},
        onContinue: {},
        onShowHowToPlay: {}
    )
}
