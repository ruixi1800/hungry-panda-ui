import Foundation
import AppKit
import SwiftUI

/// 端到端跑一遍状态机（静音模式），确认 拖拽 → 咀嚼 → 睡觉 → 长大 → 白天 的时序。
@main
struct FlowTest {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.prohibited)

        Task { @MainActor in
            await scenario()
            exit(0)
        }
        app.run()
    }

    @MainActor
    static func scenario() async {
        let started = Date()
        let game = GameModel()
        game.startGame()
        print(String(format: "[%5.1fs] start -> %@", Date().timeIntervalSince(started), "\(game.phase)"))

        let mouth = game.mouthPoint
        game.beginDrag(.strawberry, at: CGPoint(x: mouth.x + 260, y: mouth.y + 180))
        print(String(format: "[%5.1fs] drag -> %@", Date().timeIntervalSince(started), "\(game.phase)"))
        game.endDrag(.strawberry, at: CGPoint(x: mouth.x + 5, y: mouth.y + 5))
        print(String(format: "[%5.1fs] drop -> %@ (max bites %d)", Date().timeIntervalSince(started), "\(game.phase)", game.bitesMax))

        var lastPhase = game.phase
        var lastBites = 0
        var growth = game.growth
        while true {
            try? await Task.sleep(nanoseconds: 250_000_000)
            if game.phase != lastPhase {
                print(String(format: "[%5.1fs] phase -> %@  growth=%.2f bites=%d eaten=%d",
                             Date().timeIntervalSince(started), "\(game.phase)", game.growth, game.bites, game.eatenCount))
                lastPhase = game.phase
            }
            if game.bites != lastBites {
                lastBites = game.bites
                print(String(format: "[%5.1fs]   bite %d", Date().timeIntervalSince(started), game.bites))
            }
            if game.growth != growth {
                growth = game.growth
                print(String(format: "[%5.1fs]   grew to %.2f", Date().timeIntervalSince(started), growth))
            }
            if game.phase == .idle && Date().timeIntervalSince(started) > 3 {
                print(String(format: "[%5.1fs] cycle finished, growth=%.2f eaten=%d trayFilled=%@",
                             Date().timeIntervalSince(started), game.growth, game.eatenCount,
                             "\(game.tray.map(\.filled))"))
                break
            }
            if Date().timeIntervalSince(started) > 180 {
                print("TIMEOUT in phase \(game.phase)")
                break
            }
        }
    }
}
