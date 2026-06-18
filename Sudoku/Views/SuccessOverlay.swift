import SwiftUI

struct SuccessOverlay: View {
    let level: Int
    let onNextLevel: () -> Void
    let onHome: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppTheme.success.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(AppTheme.success)
                        .symbolEffect(.bounce, value: level)
                }

                VStack(spacing: 8) {
                    Text(L10n.congratulations)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(L10n.levelCompleted(level))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(spacing: 12) {
                    Button(action: onNextLevel) {
                        Text(L10n.nextLevel)
                    }
                    .buttonStyle(PremiumButtonStyle())

                    Button(action: onHome) {
                        Text(L10n.home)
                    }
                    .buttonStyle(PremiumButtonStyle(isSecondary: true))
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.backgroundBottom)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
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
        }
    }
}

#Preview {
    SuccessOverlay(level: 3, onNextLevel: {}, onHome: {})
        .premiumBackground()
}
