import SwiftUI

@main
struct SudokuApp: App {
    @State private var themeStore = ThemeStore()
    @State private var feedbackStore = FeedbackStore()

    init() {
        InterstitialAdManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeStore)
                .environment(feedbackStore)
                .themeAware(using: themeStore)
                .onAppear {
                    GameFeedbackService.shared.prepare()
                }
        }
    }
}
