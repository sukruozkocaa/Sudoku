import Foundation

enum RemoteConfigFetchResult: Equatable {
    case idle
    case fetching
    case fetchedFromRemote
    case usedCached
    case failed(String)

    var label: String {
        switch self {
        case .idle: "Bekliyor"
        case .fetching: "Yükleniyor..."
        case .fetchedFromRemote: "Sunucudan geldi"
        case .usedCached: "Önbellek kullanıldı"
        case .failed(let message): "Hata: \(message)"
        }
    }

    var isSuccess: Bool {
        switch self {
        case .fetchedFromRemote, .usedCached: true
        default: false
        }
    }
}

enum RemoteConfigValueSource: Equatable {
    case bundled
    case firebaseDefault
    case remote
    case cached

    var label: String {
        switch self {
        case .bundled: "Bundle JSON"
        case .firebaseDefault: "Firebase varsayılan"
        case .remote: "Firebase Remote"
        case .cached: "Firebase önbellek"
        }
    }
}

struct RemoteConfigDiagnostics: Equatable {
    var fetchResult: RemoteConfigFetchResult
    var valueSource: RemoteConfigValueSource
    var lastFetchDate: Date?
    var rawJSON: String
    var matchesBundledDefaults: Bool
}
