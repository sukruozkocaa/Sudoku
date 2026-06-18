import SwiftUI

struct HomeView: View {
    let hasSavedGame: Bool
    let savedLevel: Int?
    let savedDifficulty: Difficulty?
    let onStart: () -> Void
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text(L10n.appName)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(L10n.homeTagline)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)

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
                }

                Button(action: onStart) {
                    Text(hasSavedGame ? L10n.newGame : L10n.start)
                }
                .buttonStyle(PremiumButtonStyle(isSecondary: hasSavedGame))
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
        }
        .premiumBackground()
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

#Preview {
    HomeView(
        hasSavedGame: true,
        savedLevel: 3,
        savedDifficulty: .medium,
        onStart: {},
        onContinue: {}
    )
}
