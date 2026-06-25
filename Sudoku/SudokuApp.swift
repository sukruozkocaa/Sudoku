import SwiftUI

@main
struct SudokuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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
                .environment(RemoteConfigStore.shared)
                .themeAware(using: themeStore)
                .task {
                    await RemoteConfigStore.shared.fetchAndActivate()
                }
                .onAppear {
                    GameFeedbackService.shared.prepare()
                }
        }
    }
}
