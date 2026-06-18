import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringRotation: Double = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppTheme.accent.opacity(0.05),
                                    AppTheme.accent.opacity(0.6),
                                    AppTheme.accentSecondary.opacity(0.8),
                                    AppTheme.accent.opacity(0.05)
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(ringRotation))

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppTheme.cardBackground)
                        .frame(width: 110, height: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                        .overlay {
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    miniCell("5")
                                    miniCell("3")
                                    miniCell("")
                                }
                                HStack(spacing: 4) {
                                    miniCell("6")
                                    miniCell("")
                                    miniCell("")
                                }
                                HStack(spacing: 4) {
                                    miniCell("")
                                    miniCell("9")
                                    miniCell("8")
                                }
                            }
                        }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("SUDOKU")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .tracking(6)

                    Text(L10n.splashTagline)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1
                logoOpacity = 1
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
    }

    private func miniCell(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(value.isEmpty ? .clear : AppTheme.userNumber)
            .frame(width: 22, height: 22)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    SplashView()
}
