import Foundation
import AVFoundation

/// Speaks Chinese text using the on-device TTS engine.
/// Uses zh-CN voice; falls back gracefully if unavailable.
@MainActor
final class AudioService: ObservableObject {

    static let shared = AudioService()

    private let synthesizer = AVSpeechSynthesizer()
    private var preferredVoice: AVSpeechSynthesisVoice?

    private init() {
        preferredVoice = AVSpeechSynthesisVoice(language: "zh-CN")
            ?? AVSpeechSynthesisVoice(language: "zh-TW")
    }

    /// Speak the given Chinese text aloud.
    func speak(_ text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredVoice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    /// Speak at a slower rate — useful for beginners parsing tones.
    func speakSlowly(_ text: String) {
        speak(text, rate: AVSpeechUtteranceMinimumSpeechRate + 0.1)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
