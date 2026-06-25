import StoreKit
import SwiftUI

struct SuccessOverlay: View {
    let level: Int
    let completionTime: Int
    let isDaily: Bool
    let showsNextLevel: Bool
    let onNextLevel: () -> Void
    let onHome: () -> Void

    @Environment(\.requestReview) private var requestReview
    @Environment(StatsStore.self) private var statsStore
    @Environment(\.themePalette) private var theme
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            theme.overlayScrim
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(theme.success.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(theme.success)
                        .symbolEffect(.bounce, value: level)
                }

                VStack(spacing: 8) {
                    Text(L10n.congratulations)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)

                    Text(subtitleText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)

                    if completionTime > 0 {
                        Text(L10n.completionTime(StatsStore.formatDuration(completionTime)))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.accent)
                    }

                    if statsStore.stats.currentStreak > 1 {
                        Text(L10n.streakDays(statsStore.stats.currentStreak))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                VStack(spacing: 12) {
                    if showsNextLevel {
                        Button(action: onNextLevel) {
                            Text(L10n.nextLevel)
                        }
                        .buttonStyle(PremiumButtonStyle())
                    }

                    Button(action: onHome) {
                        Text(L10n.home)
                    }
                    .buttonStyle(PremiumButtonStyle(isSecondary: showsNextLevel))
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(theme.sheetBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                scale = 1
                opacity = 1
            }

            if AppReviewManager.registerLevelCompletion() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    requestReview()
                }
            }
        }
    }

    private var subtitleText: String {
        if isDaily {
            return L10n.dailyChallengeCompleted
        }
        return L10n.levelCompleted(level)
    }
}

#Preview {
    let statsStore = StatsStore()

    SuccessOverlay(
        level: 3,
        completionTime: 245,
        isDaily: false,
        showsNextLevel: true,
        onNextLevel: {},
        onHome: {}
    )
    .environment(statsStore)
    .premiumBackground()
}
