import FirebaseRemoteConfig
import Foundation
import Observation

@Observable
@MainActor
final class RemoteConfigStore {
    static let shared = RemoteConfigStore()

    private(set) var config: AppRemoteConfig = .default
    private(set) var diagnostics = RemoteConfigDiagnostics(
        fetchResult: .idle,
        valueSource: .bundled,
        lastFetchDate: nil,
        rawJSON: "",
        matchesBundledDefaults: true
    )

    private let remoteConfig = RemoteConfig.remoteConfig()
    private let bundledDefaults: AppRemoteConfig
    private let bundledJSON: String

    private init() {
        bundledJSON = AppRemoteConfig.bundledDefaultJSONString()
        bundledDefaults = AppRemoteConfig.parse(jsonString: bundledJSON)

        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            RemoteConfigKey.appConfig: bundledJSON as NSString
        ])
        applyCurrentValues(source: .firebaseDefault)
    }

    func fetchAndActivate() async {
        await refresh()
    }

    func refresh() async {
        diagnostics.fetchResult = .fetching

        do {
            let status = try await remoteConfig.fetchAndActivate()
            let previousAdUnitID = config.interstitialAdUnitID
            applyCurrentValues(source: valueSource(for: status))

            switch status {
            case .successFetchedFromRemote:
                diagnostics.fetchResult = .fetchedFromRemote
                logFetchSuccess(source: "remote")
            case .successUsingPreFetchedData:
                diagnostics.fetchResult = .usedCached
                logFetchSuccess(source: "cached")
            case .error:
                diagnostics.fetchResult = .failed("Fetch başarısız")
                print("RemoteConfigStore: fetchAndActivate returned error status")
            @unknown default:
                diagnostics.fetchResult = .failed("Bilinmeyen durum")
            }

            diagnostics.lastFetchDate = Date()

            if config.interstitialAdUnitID != previousAdUnitID {
                InterstitialAdManager.shared.handleRemoteConfigUpdate()
            }
        } catch {
            diagnostics.fetchResult = .failed(error.localizedDescription)
            print("RemoteConfigStore fetch failed: \(error.localizedDescription)")
        }
    }

    private func applyCurrentValues(source: RemoteConfigValueSource) {
        let rawJSON = remoteConfig[RemoteConfigKey.appConfig].stringValue ?? bundledJSON
        config = AppRemoteConfig.parse(jsonString: rawJSON, fallback: bundledDefaults)
        diagnostics = RemoteConfigDiagnostics(
            fetchResult: diagnostics.fetchResult,
            valueSource: resolvedSource(for: source),
            lastFetchDate: diagnostics.lastFetchDate,
            rawJSON: rawJSON,
            matchesBundledDefaults: config == bundledDefaults
        )
    }

    private func resolvedSource(for source: RemoteConfigValueSource) -> RemoteConfigValueSource {
        switch remoteConfig[RemoteConfigKey.appConfig].source {
        case .remote:
            return .remote
        case .static:
            return .cached
        case .default:
            return source == .bundled ? .bundled : .firebaseDefault
        @unknown default:
            return source
        }
    }

    private func valueSource(for status: RemoteConfigFetchAndActivateStatus) -> RemoteConfigValueSource {
        switch status {
        case .successFetchedFromRemote:
            return .remote
        case .successUsingPreFetchedData:
            return .cached
        case .error:
            return diagnostics.valueSource
        @unknown default:
            return diagnostics.valueSource
        }
    }

    private func logFetchSuccess(source: String) {
        print(
            """
            RemoteConfigStore ✅ fetch OK [\(source)]
              source: \(diagnostics.valueSource.label)
              matches bundled defaults: \(diagnostics.matchesBundledDefaults)
              hints: \(config.hintsEnabled)
              ads: \(config.adsEnabled)
              ad unit: \(config.interstitialAdUnitID)
            """
        )
    }
}
