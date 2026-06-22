import Foundation

enum AdConfiguration {
    /// Replace with your AdMob App ID from admob.google.com
    #if DEBUG
    static let appID = "ca-app-pub-3940256099942544~1458002511"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    static let appID = "ca-app-pub-3940256099942544~1458002511"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #endif

    /// Minimum time between any two full-screen ads.
    static let minimumSecondsBetweenAds: TimeInterval = 120

    /// Show a gameplay ad every N game screen entries (start, continue, next level).
    static let gameplayEntriesBetweenAds = 2
}
