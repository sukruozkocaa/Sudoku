import SwiftUI

@main
struct SudokuApp: App {
    @State private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeStore)
                .themeAware(using: themeStore)
        }
    }
}
