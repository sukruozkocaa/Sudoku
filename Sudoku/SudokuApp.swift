import SwiftUI

@main
struct SudokuApp: App {
    @State private var themeStore = ThemeStore()

    init() {
        InterstitialAdManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeStore)
                .themeAware(using: themeStore)
        }
    }
}
