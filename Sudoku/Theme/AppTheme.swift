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
    var animated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                PremiumBackgroundLayer(animated: animated)
                    .ignoresSafeArea()
            )
    }
}

struct PremiumBackgroundLayer: View {
    var animated: Bool

    @State private var orbAOffset: CGSize = .zero
    @State private var orbBOffset: CGSize = .zero
    @State private var gridOpacity: Double = 0

    var body: some View {
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

            if animated {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: 130 + orbAOffset.width, y: -280 + orbAOffset.height)

                Circle()
                    .fill(AppTheme.accentSecondary.opacity(0.08))
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .offset(x: -140 + orbBOffset.width, y: 320 + orbBOffset.height)

                GridPatternOverlay()
                    .opacity(gridOpacity)
            }
        }
        .onAppear {
            guard animated else { return }

            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                orbAOffset = CGSize(width: 24, height: 36)
            }
            withAnimation(.easeInOut(duration: 7.5).repeatForever(autoreverses: true).delay(0.4)) {
                orbBOffset = CGSize(width: -20, height: -28)
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                gridOpacity = 1
            }
        }
    }
}

private struct GridPatternOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 9

            Canvas { context, size in
                var path = Path()

                for index in 0...9 {
                    let position = cellSize * CGFloat(index)
                    path.move(to: CGPoint(x: position, y: 0))
                    path.addLine(to: CGPoint(x: position, y: size.height))
                    path.move(to: CGPoint(x: 0, y: position))
                    path.addLine(to: CGPoint(x: size.width, y: position))
                }

                context.stroke(
                    path,
                    with: .color(.white.opacity(0.025)),
                    lineWidth: 0.5
                )

                var boldPath = Path()
                for index in stride(from: 0, through: 9, by: 3) {
                    let position = cellSize * CGFloat(index)
                    boldPath.move(to: CGPoint(x: position, y: 0))
                    boldPath.addLine(to: CGPoint(x: position, y: size.height))
                    boldPath.move(to: CGPoint(x: 0, y: position))
                    boldPath.addLine(to: CGPoint(x: size.width, y: position))
                }

                context.stroke(
                    boldPath,
                    with: .color(.white.opacity(0.04)),
                    lineWidth: 1
                )
            }
        }
        .allowsHitTesting(false)
    }
}

struct PremiumButtonStyle: ButtonStyle {
    var isSecondary: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 21, weight: .bold, design: .rounded))
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
    func premiumBackground(animated: Bool = false) -> some View {
        modifier(PremiumBackground(animated: animated))
    }
}
