import SwiftUI

struct SudokuLogoView: View {
    var size: CGFloat = 110
    var showRing: Bool = true
    var animateCells: Bool = false
    var animateRing: Bool = true

    @Environment(\.themePalette) private var theme

    private let cellValues: [[String]] = [
        ["5", "3", ""],
        ["6", "", ""],
        ["", "9", "8"]
    ]

    @State private var scale: CGFloat = 0.72
    @State private var opacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var visibleCellCount = 9
    @State private var glowPulse: CGFloat = 0.85

    private var ringSize: CGFloat { size * 1.27 }
    private var cornerRadius: CGFloat { size * 0.255 }

    var body: some View {
        ZStack {
            if showRing {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                theme.accent.opacity(0.14 * glowPulse),
                                .clear
                            ],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: ringSize * 0.55
                        )
                    )
                    .frame(width: ringSize * 1.15, height: ringSize * 1.15)

                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                theme.accent.opacity(0.04),
                                theme.accent.opacity(0.55),
                                theme.accentSecondary.opacity(0.75),
                                theme.accent.opacity(0.04)
                            ],
                            center: .center
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(ringRotation))
            }

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(theme.cardBackground)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: theme.accent.opacity(0.2), radius: 20, y: 10)
                .overlay {
                    VStack(spacing: size * 0.036) {
                        ForEach(0..<3, id: \.self) { row in
                            HStack(spacing: size * 0.036) {
                                ForEach(0..<3, id: \.self) { column in
                                    let index = row * 3 + column
                                    let value = cellValues[row][column]

                                    miniCell(value)
                                        .opacity(cellOpacity(for: index))
                                        .scaleEffect(cellScale(for: index))
                                }
                            }
                        }
                    }
                }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.85, dampingFraction: 0.72)) {
                scale = 1
                opacity = 1
            }

            if animateRing {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
            }

            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                glowPulse = 1.15
            }

            if animateCells {
                visibleCellCount = 0
                for index in 0..<9 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45 + Double(index) * 0.08) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                            visibleCellCount = index + 1
                        }
                    }
                }
            }
        }
    }

    private func miniCell(_ value: String) -> some View {
        Text(value)
            .font(.system(size: size * 0.1, weight: .bold, design: .rounded))
            .foregroundStyle(value.isEmpty ? .clear : theme.userNumber)
            .frame(width: size * 0.2, height: size * 0.2)
            .background(theme.logoCellBackground, in: RoundedRectangle(cornerRadius: size * 0.055, style: .continuous))
    }

    private func cellOpacity(for index: Int) -> Double {
        animateCells ? (index < visibleCellCount ? 1 : 0) : 1
    }

    private func cellScale(for index: Int) -> CGFloat {
        animateCells ? (index < visibleCellCount ? 1 : 0.6) : 1
    }
}

#Preview {
    let themeStore = ThemeStore()

    ZStack {
        PremiumBackgroundLayer(animated: false)
        SudokuLogoView(size: 120, animateCells: true)
    }
    .environment(themeStore)
    .themeAware(using: themeStore)
}
