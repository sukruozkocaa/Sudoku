import SwiftUI

@main
struct SudokuApp: App {
    @State private var themeStore = ThemeStore()
    @State private var feedbackStore = FeedbackStore()
    @State private var statsStore = StatsStore()

    init() {
        InterstitialAdManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(statsStore: statsStore)
                .environment(themeStore)
                .environment(feedbackStore)
                .environment(statsStore)
                .themeAware(using: themeStore)
                .onAppear {
                    GameFeedbackService.shared.prepare()
                }
        }
    }
}
