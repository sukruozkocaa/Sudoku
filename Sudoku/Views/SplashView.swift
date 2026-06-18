import SwiftUI

struct SplashView: View {
    @State private var logoAppeared = false
    @State private var titleAppeared = false
    @State private var taglineAppeared = false
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            PremiumBackgroundLayer(animated: true)

            VStack(spacing: 32) {
                SudokuLogoView(size: 118, showRing: true, animateCells: true, animateRing: true)
                    .opacity(logoAppeared ? 1 : 0)
                    .scaleEffect(logoAppeared ? 1 : 0.75)

                VStack(spacing: 10) {
                    Text(L10n.appName.uppercased())
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accentGradient)
                        .tracking(7)
                        .opacity(titleAppeared ? 1 : 0)
                        .offset(y: titleAppeared ? 0 : 16)

                    Text(L10n.splashTagline)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .opacity(taglineAppeared ? 1 : 0)
                        .offset(y: taglineAppeared ? 0 : 10)
                }

                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 120, height: 4)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.accentGradient)
                            .frame(width: 120 * progress, height: 4)
                    }
                    .opacity(taglineAppeared ? 1 : 0)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.85, dampingFraction: 0.72)) {
                logoAppeared = true
            }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.25)) {
                titleAppeared = true
            }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.82).delay(0.42)) {
                taglineAppeared = true
            }

            withAnimation(.easeInOut(duration: 1.8)) {
                progress = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
