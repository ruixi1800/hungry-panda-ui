import Foundation
import AVFoundation

/// 简单的音效播放器：一次只播一首，`play` 返回时长（找不到文件时返回 0）。
@MainActor
final class SoundPlayer {
    private var player: AVAudioPlayer?

    @discardableResult
    func play(_ name: String) -> TimeInterval {
        player?.stop()
        player = nil

        guard let url = audioURL(name) else {
            NSLog("HungryPanda: missing audio \(name).mp3")
            return 0
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            if ProcessInfo.processInfo.environment["HUNGRYPANDA_MUTE"] == "1" {
                p.volume = 0
            }
            p.prepareToPlay()
            p.play()
            player = p
            return p.duration
        } catch {
            NSLog("HungryPanda: cannot play \(name).mp3 — \(error)")
            return 0
        }
    }

    private func audioURL(_ name: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "audio") {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            return url
        }
        if let dir = ProcessInfo.processInfo.environment["HUNGRYPANDA_RESOURCES"] {
            let candidate = "\(dir)/audio/\(name).mp3"
            if FileManager.default.fileExists(atPath: candidate) {
                return URL(fileURLWithPath: candidate)
            }
        }
        return nil
    }

    var isPlaying: Bool { player?.isPlaying ?? false }

    func stop() {
        player?.stop()
        player = nil
    }
}
