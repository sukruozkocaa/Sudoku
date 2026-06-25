import Foundation

struct AppRemoteConfig: Equatable {
    struct Ads: Equatable {
        var enabled: Bool
        var interstitialAdUnitID: String
        var minimumSecondsBetweenAds: TimeInterval
        var gameplayEntriesBetweenAds: Int
        var onGameplayEntry: Bool
        var onHint: Bool
        var onNextLevel: Bool
    }

    struct Features: Equatable {
        var hints: Bool
        var dailyChallenge: Bool
        var pencilNotes: Bool
        var stats: Bool
        var achievements: Bool
    }

    var ads: Ads
    var features: Features

    static let `default` = AppRemoteConfig(
        ads: Ads(
            enabled: AdConfiguration.defaultAdsEnabled,
            interstitialAdUnitID: AdConfiguration.defaultInterstitialAdUnitID,
            minimumSecondsBetweenAds: AdConfiguration.defaultMinimumSecondsBetweenAds,
            gameplayEntriesBetweenAds: AdConfiguration.defaultGameplayEntriesBetweenAds,
            onGameplayEntry: AdConfiguration.defaultAdsOnGameplayEntry,
            onHint: AdConfiguration.defaultAdsOnHint,
            onNextLevel: AdConfiguration.defaultAdsOnNextLevel
        ),
        features: Features(
            hints: true,
            dailyChallenge: true,
            pencilNotes: true,
            stats: true,
            achievements: true
        )
    )

    var adsEnabled: Bool { ads.enabled }
    var interstitialAdUnitID: String { ads.interstitialAdUnitID }
    var minimumSecondsBetweenAds: TimeInterval { ads.minimumSecondsBetweenAds }
    var gameplayEntriesBetweenAds: Int { ads.gameplayEntriesBetweenAds }
    var adsOnGameplayEntry: Bool { ads.onGameplayEntry }
    var adsOnHint: Bool { ads.onHint }
    var adsOnNextLevel: Bool { ads.onNextLevel }
    var hintsEnabled: Bool { features.hints }
    var dailyChallengeEnabled: Bool { features.dailyChallenge }
    var pencilNotesEnabled: Bool { features.pencilNotes }
    var statsEnabled: Bool { features.stats }
    var achievementsEnabled: Bool { features.achievements }
}

private struct AppRemoteConfigPayload: Decodable {
    struct AdsPayload: Decodable {
        var enabled: Bool?
        var interstitialAdUnitID: String?
        var minimumSecondsBetweenAds: Double?
        var gameplayEntriesBetweenAds: Int?
        var onGameplayEntry: Bool?
        var onHint: Bool?
        var onNextLevel: Bool?

        enum CodingKeys: String, CodingKey {
            case enabled
            case interstitialAdUnitID = "interstitial_ad_unit_id"
            case minimumSecondsBetweenAds = "minimum_seconds_between_ads"
            case gameplayEntriesBetweenAds = "gameplay_entries_between_ads"
            case onGameplayEntry = "on_gameplay_entry"
            case onHint = "on_hint"
            case onNextLevel = "on_next_level"
        }
    }

    struct FeaturesPayload: Decodable {
        var hints: Bool?
        var dailyChallenge: Bool?
        var pencilNotes: Bool?
        var stats: Bool?
        var achievements: Bool?

        enum CodingKeys: String, CodingKey {
            case hints
            case dailyChallenge = "daily_challenge"
            case pencilNotes = "pencil_notes"
            case stats
            case achievements
        }
    }

    var ads: AdsPayload?
    var features: FeaturesPayload?
}

extension AppRemoteConfig {
    static func parse(jsonString: String?, fallback: AppRemoteConfig = .default) -> AppRemoteConfig {
        guard
            let jsonString,
            !jsonString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let data = jsonString.data(using: .utf8)
        else {
            return fallback
        }

        return parse(data: data, fallback: fallback)
    }

    static func parse(data: Data, fallback: AppRemoteConfig = .default) -> AppRemoteConfig {
        guard let payload = try? JSONDecoder().decode(AppRemoteConfigPayload.self, from: data) else {
            print("AppRemoteConfig: invalid JSON, using defaults.")
            return fallback
        }

        return AppRemoteConfig(
            ads: Ads(
                enabled: payload.ads?.enabled ?? fallback.ads.enabled,
                interstitialAdUnitID: sanitizedAdUnitID(
                    payload.ads?.interstitialAdUnitID,
                    fallback: fallback.ads.interstitialAdUnitID
                ),
                minimumSecondsBetweenAds: sanitizedInterval(
                    payload.ads?.minimumSecondsBetweenAds,
                    fallback: fallback.ads.minimumSecondsBetweenAds
                ),
                gameplayEntriesBetweenAds: sanitizedEntryCount(
                    payload.ads?.gameplayEntriesBetweenAds,
                    fallback: fallback.ads.gameplayEntriesBetweenAds
                ),
                onGameplayEntry: payload.ads?.onGameplayEntry ?? fallback.ads.onGameplayEntry,
                onHint: payload.ads?.onHint ?? fallback.ads.onHint,
                onNextLevel: payload.ads?.onNextLevel ?? fallback.ads.onNextLevel
            ),
            features: Features(
                hints: payload.features?.hints ?? fallback.features.hints,
                dailyChallenge: payload.features?.dailyChallenge ?? fallback.features.dailyChallenge,
                pencilNotes: payload.features?.pencilNotes ?? fallback.features.pencilNotes,
                stats: payload.features?.stats ?? fallback.features.stats,
                achievements: payload.features?.achievements ?? fallback.features.achievements
            )
        )
    }

    static func bundledDefaultJSONString() -> String {
        guard
            let url = Bundle.main.url(forResource: "RemoteConfigDefaults", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = String(data: data, encoding: .utf8)
        else {
            return fallbackJSONString()
        }
        return json
    }

    private static func fallbackJSONString() -> String {
        """
        {"ads":{"enabled":true,"interstitial_ad_unit_id":"\(AdConfiguration.defaultInterstitialAdUnitID)","minimum_seconds_between_ads":120,"gameplay_entries_between_ads":2,"on_gameplay_entry":true,"on_hint":true,"on_next_level":true},"features":{"hints":true,"daily_challenge":true,"pencil_notes":true,"stats":true,"achievements":true}}
        """
    }

    private static func sanitizedAdUnitID(_ value: String?, fallback: String) -> String {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallback
        }
        return value
    }

    private static func sanitizedInterval(_ value: Double?, fallback: TimeInterval) -> TimeInterval {
        guard let value, value > 0 else { return fallback }
        return value
    }

    private static func sanitizedEntryCount(_ value: Int?, fallback: Int) -> Int {
        guard let value, value > 0 else { return fallback }
        return value
    }
}

enum RemoteConfigKey {
    static let appConfig = "app_config"
}
