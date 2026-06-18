import SwiftUI

private struct HowToPlayStep: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let message: String
}

struct HowToPlayView: View {
    let onFinish: () -> Void
    let onSkip: () -> Void

    @State private var currentStep = 0
    @State private var appear = false
    @State private var contentAppeared = false

    private var steps: [HowToPlayStep] {
        [
            HowToPlayStep(
                id: 0,
                icon: "square.grid.3x3.fill",
                title: L10n.howToPlayStep1Title,
                message: L10n.howToPlayStep1Body
            ),
            HowToPlayStep(
                id: 1,
                icon: "hand.tap.fill",
                title: L10n.howToPlayStep2Title,
                message: L10n.howToPlayStep2Body
            ),
            HowToPlayStep(
                id: 2,
                icon: "rectangle.split.3x3.fill",
                title: L10n.howToPlayStep3Title,
                message: L10n.howToPlayStep3Body
            ),
            HowToPlayStep(
                id: 3,
                icon: "checkmark.seal.fill",
                title: L10n.howToPlayStep4Title,
                message: L10n.howToPlayStep4Body
            ),
            HowToPlayStep(
                id: 4,
                icon: "arrow.up.circle.fill",
                title: L10n.howToPlayStep5Title,
                message: L10n.howToPlayStep5Body
            )
        ]
    }

    private var step: HowToPlayStep {
        steps[currentStep]
    }

    private var isLastStep: Bool {
        currentStep == steps.count - 1
    }

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.62 : 0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text(L10n.howToPlayTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Spacer()

                    Button(action: onSkip) {
                        Text(L10n.howToPlaySkip)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)

                stepIndicator
                    .padding(.bottom, 28)

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.accent.opacity(0.22),
                                        AppTheme.accentSecondary.opacity(0.08)
                                    ],
                                    center: .center,
                                    startRadius: 8,
                                    endRadius: 56
                                )
                            )
                            .frame(width: 112, height: 112)

                        Circle()
                            .stroke(AppTheme.accent.opacity(0.25), lineWidth: 1.5)
                            .frame(width: 112, height: 112)

                        Image(systemName: step.icon)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(AppTheme.accentGradient)
                            .symbolEffect(.bounce, value: currentStep)
                    }

                    VStack(spacing: 12) {
                        Text(step.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(step.message)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .id(currentStep)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 16)
                .padding(.bottom, 24)

                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button {
                            goToStep(currentStep - 1)
                        } label: {
                            Text(L10n.howToPlayBack)
                        }
                        .buttonStyle(PremiumButtonStyle(isSecondary: true))
                    }

                    Button {
                        if isLastStep {
                            onFinish()
                        } else {
                            goToStep(currentStep + 1)
                        }
                    } label: {
                        Text(isLastStep ? L10n.howToPlayFinish : L10n.howToPlayNext)
                    }
                    .buttonStyle(PremiumButtonStyle())
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.backgroundBottom)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: AppTheme.accent.opacity(0.12), radius: 30, y: 16)
            )
            .padding(.horizontal, 24)
            .scaleEffect(appear ? 1 : 0.92)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appear = true
            }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.84).delay(0.08)) {
                contentAppeared = true
            }
        }
    }

    private var stepIndicator: some View {
        VStack(spacing: 10) {
            Text(L10n.howToPlayStepProgress(current: currentStep + 1, total: steps.count))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 8) {
                ForEach(steps) { item in
                    Capsule()
                        .fill(
                            item.id <= currentStep
                                ? AnyShapeStyle(AppTheme.accentGradient)
                                : AnyShapeStyle(Color.white.opacity(0.12))
                        )
                        .frame(width: item.id == currentStep ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
                }
            }
        }
    }

    private func goToStep(_ step: Int) {
        withAnimation(.easeOut(duration: 0.15)) {
            contentAppeared = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            currentStep = step
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                contentAppeared = true
            }
        }
    }
}

#Preview {
    HowToPlayView(onFinish: {}, onSkip: {})
        .premiumBackground()
}
