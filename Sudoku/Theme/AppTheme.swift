import SwiftUI

struct ThemePalette: Equatable {
    let backgroundTop: Color
    let backgroundBottom: Color
    let cardBackground: Color
    let cardBorder: Color
    let accent: Color
    let accentSecondary: Color
    let success: Color
    let error: Color
    let textPrimary: Color
    let textSecondary: Color
    let fixedNumber: Color
    let userNumber: Color
    let passiveNumber: Color
    let cellBackground: Color
    let cellBorder: Color
    let gridLine: Color
    let gridLineBold: Color
    let overlayScrim: Color
    let logoCellBackground: Color
    let sheetBackground: Color

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static let dark = ThemePalette(
        backgroundTop: Color(red: 0.06, green: 0.07, blue: 0.14),
        backgroundBottom: Color(red: 0.10, green: 0.12, blue: 0.22),
        cardBackground: Color.white.opacity(0.08),
        cardBorder: Color.white.opacity(0.12),
        accent: Color(red: 0.42, green: 0.55, blue: 1.0),
        accentSecondary: Color(red: 0.58, green: 0.36, blue: 0.98),
        success: Color(red: 0.22, green: 0.84, blue: 0.55),
        error: Color(red: 1.0, green: 0.36, blue: 0.42),
        textPrimary: Color.white,
        textSecondary: Color.white.opacity(0.65),
        fixedNumber: Color.white,
        userNumber: Color(red: 0.72, green: 0.82, blue: 1.0),
        passiveNumber: Color.white.opacity(0.35),
        cellBackground: Color.white.opacity(0.03),
        cellBorder: Color.white.opacity(0.18),
        gridLine: Color.white.opacity(0.025),
        gridLineBold: Color.white.opacity(0.04),
        overlayScrim: Color.black.opacity(0.62),
        logoCellBackground: Color.white.opacity(0.06),
        sheetBackground: Color(red: 0.10, green: 0.12, blue: 0.22)
    )

    static let light = ThemePalette(
        backgroundTop: Color(red: 0.96, green: 0.97, blue: 0.99),
        backgroundBottom: Color(red: 0.90, green: 0.92, blue: 0.97),
        cardBackground: Color.black.opacity(0.05),
        cardBorder: Color.black.opacity(0.08),
        accent: Color(red: 0.32, green: 0.46, blue: 0.96),
        accentSecondary: Color(red: 0.50, green: 0.30, blue: 0.92),
        success: Color(red: 0.12, green: 0.68, blue: 0.44),
        error: Color(red: 0.88, green: 0.22, blue: 0.30),
        textPrimary: Color(red: 0.10, green: 0.12, blue: 0.20),
        textSecondary: Color(red: 0.36, green: 0.40, blue: 0.50),
        fixedNumber: Color(red: 0.10, green: 0.12, blue: 0.20),
        userNumber: Color(red: 0.24, green: 0.40, blue: 0.88),
        passiveNumber: Color.black.opacity(0.28),
        cellBackground: Color.black.opacity(0.035),
        cellBorder: Color.black.opacity(0.12),
        gridLine: Color.black.opacity(0.06),
        gridLineBold: Color.black.opacity(0.11),
        overlayScrim: Color.black.opacity(0.40),
        logoCellBackground: Color.black.opacity(0.05),
        sheetBackground: Color(red: 0.98, green: 0.98, blue: 1.0)
    )

    static func palette(for colorScheme: ColorScheme) -> ThemePalette {
        colorScheme == .dark ? .dark : .light
    }
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

    @Environment(\.themePalette) private var theme
    @State private var orbAOffset: CGSize = .zero
    @State private var orbBOffset: CGSize = .zero
    @State private var gridOpacity: Double = 0

    var body: some View {
        ZStack {
            theme.backgroundGradient

            RadialGradient(
                colors: [theme.accent.opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 420
            )

            RadialGradient(
                colors: [theme.accentSecondary.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 360
            )

            if animated {
                Circle()
                    .fill(theme.accent.opacity(0.1))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: 130 + orbAOffset.width, y: -280 + orbAOffset.height)

                Circle()
                    .fill(theme.accentSecondary.opacity(0.08))
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
    @Environment(\.themePalette) private var theme

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

                context.stroke(path, with: .color(theme.gridLine), lineWidth: 0.5)

                var boldPath = Path()
                for index in stride(from: 0, through: 9, by: 3) {
                    let position = cellSize * CGFloat(index)
                    boldPath.move(to: CGPoint(x: position, y: 0))
                    boldPath.addLine(to: CGPoint(x: position, y: size.height))
                    boldPath.move(to: CGPoint(x: 0, y: position))
                    boldPath.addLine(to: CGPoint(x: size.width, y: position))
                }

                context.stroke(boldPath, with: .color(theme.gridLineBold), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

struct PremiumButtonStyle: ButtonStyle {
    var isSecondary: Bool = false

    @Environment(\.themePalette) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 21, weight: .bold, design: .rounded))
            .foregroundStyle(isSecondary ? theme.textPrimary : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                if isSecondary {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(theme.cardBorder, lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(theme.accentGradient)
                        .shadow(color: theme.accent.opacity(0.35), radius: 16, y: 8)
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
