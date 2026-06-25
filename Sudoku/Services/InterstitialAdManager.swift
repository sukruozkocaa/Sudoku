import GoogleMobileAds
import UIKit

enum AdTrigger {
    case gameplayEntry
    case hint
    case nextLevel
}

@MainActor
final class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    private var interstitial: InterstitialAd?
    private var isLoading = false
    private var lastShownAt: Date?
    private var gameplayEntryCount = 0
    private var pendingCompletion: (() -> Void)?
    private var pendingLoadCompletions: [(Bool) -> Void] = []
    private var activeTrigger: AdTrigger?
    private(set) var isPresentingAd = false

    private override init() {
        super.init()
    }

    func configure() {
        MobileAds.shared.start { [weak self] _ in
            Task { @MainActor in
                self?.preload()
            }
        }
    }

    func preload() {
        loadAd { _ in }
    }

    func handleRemoteConfigUpdate() {
        interstitial = nil
        preload()
    }

    func showAdIfAppropriate(for trigger: AdTrigger, completion: @escaping () -> Void) {
        let config = RemoteConfigStore.shared.config

        guard config.adsEnabled else {
            completion()
            return
        }

        switch trigger {
        case .gameplayEntry:
            guard config.adsOnGameplayEntry else {
                completion()
                return
            }
            gameplayEntryCount += 1
            guard shouldShowGameplayAd(using: config) else {
                completion()
                return
            }
        case .hint:
            guard config.adsOnHint else {
                completion()
                return
            }
        case .nextLevel:
            guard config.adsOnNextLevel else {
                completion()
                return
            }
        }

        attemptPresent(for: trigger, completion: completion)
    }

    private func shouldShowGameplayAd(using config: AppRemoteConfig) -> Bool {
        gameplayEntryCount == 1
            || gameplayEntryCount % config.gameplayEntriesBetweenAds == 0
    }

    private func respectsCooldown(_ trigger: AdTrigger) -> Bool {
        switch trigger {
        case .gameplayEntry:
            return true
        case .hint, .nextLevel:
            return false
        }
    }

    private var canShowAnotherAd: Bool {
        guard let lastShownAt else { return true }
        return Date().timeIntervalSince(lastShownAt) >= RemoteConfigStore.shared.config.minimumSecondsBetweenAds
    }

    private func loadAd(completion: @escaping (Bool) -> Void) {
        if interstitial != nil {
            completion(true)
            return
        }

        pendingLoadCompletions.append(completion)

        guard !isLoading else { return }

        isLoading = true
        InterstitialAd.load(
            with: RemoteConfigStore.shared.config.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    print("InterstitialAdManager preload failed: \(error.localizedDescription)")
                    self.finishPendingLoads(success: false)
                    return
                }

                self.interstitial = ad
                ad?.fullScreenContentDelegate = self
                self.finishPendingLoads(success: true)
            }
        }
    }

    private func finishPendingLoads(success: Bool) {
        let completions = pendingLoadCompletions
        pendingLoadCompletions.removeAll()
        completions.forEach { $0(success) }
    }

    private func attemptPresent(for trigger: AdTrigger, completion: @escaping () -> Void) {
        if respectsCooldown(trigger), !canShowAnotherAd {
            print("InterstitialAdManager: skipped \(trigger) due to cooldown.")
            completion()
            return
        }

        if interstitial != nil {
            presentLoadedAd(for: trigger, completion: completion)
            return
        }

        loadAd { [weak self] success in
            guard let self else {
                completion()
                return
            }

            if success, self.interstitial != nil {
                self.presentLoadedAd(for: trigger, completion: completion)
            } else {
                print("InterstitialAdManager: skipped \(trigger) because ad is unavailable.")
                completion()
            }
        }
    }

    private func presentLoadedAd(for trigger: AdTrigger, completion: @escaping () -> Void) {
        if respectsCooldown(trigger), !canShowAnotherAd {
            completion()
            return
        }

        guard let interstitial else {
            completion()
            preload()
            return
        }

        guard let presenter = Self.presentationViewController else {
            print("InterstitialAdManager: skipped \(trigger) because presenter is unavailable.")
            completion()
            preload()
            return
        }

        activeTrigger = trigger
        pendingCompletion = completion
        self.interstitial = nil
        isPresentingAd = true
        interstitial.present(from: presenter)
    }

    private func finishPresentation() {
        isPresentingAd = false
        let completion = pendingCompletion
        pendingCompletion = nil
        activeTrigger = nil
        preload()
        completion?()
    }

    private static var presentationViewController: UIViewController? {
        if let anchor = AdPresentationAnchor.viewController {
            return anchor.topMostPresentedController()
        }

        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }

        for scene in scenes {
            guard let window = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first(where: { !$0.isHidden }),
                  let root = window.rootViewController else {
                continue
            }
            return root.topMostPresentedController()
        }

        return nil
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    nonisolated func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            lastShownAt = Date()
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            finishPresentation()
        }
    }

    nonisolated func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        Task { @MainActor in
            print("InterstitialAdManager present failed: \(error.localizedDescription)")
            finishPresentation()
        }
    }
}

private extension UIViewController {
    func topMostPresentedController() -> UIViewController {
        presentedViewController?.topMostPresentedController() ?? self
    }
}
