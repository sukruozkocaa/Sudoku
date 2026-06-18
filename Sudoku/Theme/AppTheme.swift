import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(red: 0.06, green: 0.07, blue: 0.14)
    static let backgroundBottom = Color(red: 0.10, green: 0.12, blue: 0.22)
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.12)
    static let accent = Color(red: 0.42, green: 0.55, blue: 1.0)
    static let accentSecondary = Color(red: 0.58, green: 0.36, blue: 0.98)
    static let success = Color(red: 0.22, green: 0.84, blue: 0.55)
    static let error = Color(red: 1.0, green: 0.36, blue: 0.42)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)
    static let fixedNumber = Color.white
    static let userNumber = Color(red: 0.72, green: 0.82, blue: 1.0)
    static let passiveNumber = Color.white.opacity(0.35)

    static let backgroundGradient = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct PremiumBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    AppTheme.backgroundGradient
                    RadialGradient(
                        colors: [AppTheme.accent.opacity(0.18), .clear],
                        center: .topTrailing,
                        startRadius: 40,
                        endRadius: 420
                    )
                    RadialGradient(
                        colors: [AppTheme.accentSecondary.opacity(0.12), .clear],
                        center: .bottomLeading,
                        startRadius: 20,
                        endRadius: 360
                    )
                }
                .ignoresSafeArea()
            )
    }
}

struct PremiumButtonStyle: ButtonStyle {
    var isSecondary: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(isSecondary ? AppTheme.textPrimary : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                if isSecondary {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.accentGradient)
                        .shadow(color: AppTheme.accent.opacity(0.35), radius: 16, y: 8)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

extension View {
    func premiumBackground() -> some View {
        modifier(PremiumBackground())
    }
}
