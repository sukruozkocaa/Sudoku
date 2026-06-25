import Foundation

enum AdConfiguration {
    /// Replace with your AdMob App ID from admob.google.com
    #if DEBUG
    static let appID = "ca-app-pub-8217658595396953~2752643659"
    static let interstitialAdUnitID = "ca-app-pub-8217658595396953/5783955503"
    #else
    static let appID = "ca-app-pub-8217658595396953~2752643659"
    static let interstitialAdUnitID = "ca-app-pub-8217658595396953/5783955503"
    #endif

    /// Minimum time between any two full-screen ads.
    static let minimumSecondsBetweenAds: TimeInterval = 120

    /// Show a gameplay ad every N game screen entries (start, continue, next level).
    static let gameplayEntriesBetweenAds = 2
}
