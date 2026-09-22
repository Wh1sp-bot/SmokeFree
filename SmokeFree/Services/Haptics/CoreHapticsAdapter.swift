import CoreHaptics
import UIKit

/// **Патерн Adapter (структурний).**
/// Складний низькорівневий API CoreHaptics (`CHHapticEngine`, патерни, криві)
/// приховано за простим доменним інтерфейсом `HapticsProviding`. Якщо пристрій не
/// підтримує тактильний двигун — методи мовчки нічого не роблять.
final class CoreHapticsAdapter: HapticsProviding {
    private var engine: CHHapticEngine?
    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    func prepare() {
        guard supportsHaptics, engine == nil else { return }
        do {
            let newEngine = try CHHapticEngine()
            newEngine.isAutoShutdownEnabled = true
            newEngine.resetHandler = { [weak self] in
                do { try self?.engine?.start() } catch { self?.engine = nil }
            }
            try newEngine.start()
            engine = newEngine
        } catch {
            Log.haptics.error("CoreHaptics недоступний: \(error.localizedDescription)")
            engine = nil
        }
    }

    func play(_ cue: HapticCue) {
        if case .completed = cue {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        guard let engine else { return }
        do {
            try engine.start() // безпечно, якщо двигун уже працює
            let pattern = try makePattern(for: cue)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            Log.haptics.error("Не вдалося відтворити вібрацію: \(error.localizedDescription)")
        }
    }

    func stop() {
        engine?.stop(completionHandler: nil)
        engine = nil
    }

    // MARK: - Побудова патернів

    private func makePattern(for cue: HapticCue) throws -> CHHapticPattern {
        switch cue {
        case .inhale(let duration):
            return try ramp(duration: duration, from: 0.15, to: 1.0)   // наростає
        case .exhale(let duration):
            return try ramp(duration: duration, from: 1.0, to: 0.1)    // згасає
        case .hold, .completed:
            let tap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            )
            return try CHHapticPattern(events: [tap], parameters: [])
        }
    }

    /// Безперервна вібрація, інтенсивність якої плавно змінюється від `start` до `end`.
    private func ramp(duration: TimeInterval, from start: Float, to end: Float) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ],
            relativeTime: 0,
            duration: duration
        )
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: start),
                CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: end)
            ],
            relativeTime: 0
        )
        return try CHHapticPattern(events: [event], parameterCurves: [curve])
    }
}
