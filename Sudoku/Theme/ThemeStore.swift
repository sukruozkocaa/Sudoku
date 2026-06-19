import SwiftUI

@Observable
@MainActor
final class ThemeStore {
    private let persistence: PersistenceServiceProtocol

    var appearance: AppAppearance {
        didSet {
            persistence.saveAppearance(appearance)
        }
    }

    init(persistence: PersistenceServiceProtocol = PersistenceService()) {
        self.persistence = persistence
        self.appearance = persistence.loadAppearance()
    }
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.dark
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}

struct ThemeAwareModifier: ViewModifier {
    var themeStore: ThemeStore
    @Environment(\.colorScheme) private var systemColorScheme

    private var resolvedScheme: ColorScheme {
        switch themeStore.appearance {
        case .system:
            systemColorScheme
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.themePalette, ThemePalette.palette(for: resolvedScheme))
            .preferredColorScheme(themeStore.appearance.preferredColorScheme)
    }
}

extension View {
    func themeAware(using themeStore: ThemeStore) -> some View {
        modifier(ThemeAwareModifier(themeStore: themeStore))
    }
}
