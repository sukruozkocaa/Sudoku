import AVFoundation
import UIKit

enum GameFeedbackEvent {
    case cellSelect
    case numberPlace
    case numberClear
    case conflict
    case regionComplete
    case puzzleComplete
    case undo
}

@MainActor
final class GameFeedbackService {
    static let shared = GameFeedbackService()

    var hapticsEnabled = true
    var soundsEnabled = true

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var isAudioSessionConfigured = false

    private init() {}

    func prepare() {
        selectionGenerator.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        notificationGenerator.prepare()
        configureAudioSessionIfNeeded()
    }

    func applySettings(_ settings: GameFeedbackSettings) {
        hapticsEnabled = settings.hapticsEnabled
        soundsEnabled = settings.soundsEnabled
    }

    func play(_ event: GameFeedbackEvent) {
        playHaptic(for: event)
        playSound(for: event)
    }

    private func playHaptic(for event: GameFeedbackEvent) {
        guard hapticsEnabled else { return }

        switch event {
        case .cellSelect:
            selectionGenerator.selectionChanged()
        case .numberPlace:
            lightImpact.impactOccurred(intensity: 0.75)
        case .numberClear, .undo:
            lightImpact.impactOccurred(intensity: 0.5)
        case .conflict:
            notificationGenerator.notificationOccurred(.error)
        case .regionComplete:
            mediumImpact.impactOccurred(intensity: 0.85)
        case .puzzleComplete:
            notificationGenerator.notificationOccurred(.success)
        }
    }

    private func playSound(for event: GameFeedbackEvent) {
        guard soundsEnabled else { return }

        let resource: String? = switch event {
        case .cellSelect: "select"
        case .numberPlace: "place"
        case .numberClear, .undo: "clear"
        case .conflict: "error"
        case .regionComplete: "region"
        case .puzzleComplete: "complete"
        }

        guard let resource else { return }
        playSound(named: resource)
    }

    private func playSound(named name: String) {
        configureAudioSessionIfNeeded()

        if let player = soundPlayers[name] {
            player.currentTime = 0
            player.play()
            return
        }

        guard let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }

        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.prepareToPlay()
        player.volume = 1
        soundPlayers[name] = player
        player.play()
    }

    private func configureAudioSessionIfNeeded() {
        guard !isAudioSessionConfigured else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        isAudioSessionConfigured = true
    }
}
