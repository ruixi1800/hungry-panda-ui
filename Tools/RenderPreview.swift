import SwiftUI
import AppKit

/// 离线渲染各状态截图（ImageRenderer），用于检查画面。
/// 用法：PREVIEW_OUT=/tmp/hp-preview ./render
@main
struct RenderPreview {
    static func main() async {
        await MainActor.run { renderAll() }
    }

    @MainActor
    static func renderAll() {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)

        let dir = ProcessInfo.processInfo.environment["PREVIEW_OUT"] ?? "/tmp/hp-preview"
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let cover = GameModel()
        snapshot(RootView().environmentObject(cover), "\(dir)/01-cover.png")

        let idle = GameModel()
        idle.phase = .idle
        snapshot(RootView().environmentObject(idle), "\(dir)/02-idle.png")

        let drag = GameModel()
        drag.phase = .dragging
        drag.dragKind = .strawberry
        drag.dragPoint = CGPoint(x: 560, y: 470)
        snapshot(RootView().environmentObject(drag), "\(dir)/03-drag.png")

        let eat = GameModel()
        eat.phase = .eating
        eat.chewing = true
        eat.bites = 6
        eat.foodKind = .watermelon
        eat.foodPoint = CGPoint(x: eat.pandaX, y: Theme.floorY - PandaMetrics.mouthHeight)
        snapshot(RootView().environmentObject(eat), "\(dir)/04-eating.png")

        let walk = GameModel()
        walk.phase = .walking
        walk.pandaX = 320
        walk.bob = true
        snapshot(RootView().environmentObject(walk), "\(dir)/05-walking.png")

        let sleep = GameModel()
        sleep.phase = .sleeping
        sleep.sleeping = true
        sleep.nightness = 1
        sleep.showZzz = true
        sleep.growth = 1.24
        sleep.eatenCount = 2
        snapshot(RootView().environmentObject(sleep), "\(dir)/06-sleeping.png")

        let enIdle = GameModel()
        enIdle.phase = .idle
        enIdle.language = .en
        enIdle.growth = 1.12
        enIdle.eatenCount = 1
        snapshot(RootView().environmentObject(enIdle), "\(dir)/08-idle-en.png")

        let enCover = GameModel()
        enCover.language = .en
        snapshot(RootView().environmentObject(enCover), "\(dir)/09-cover-en.png")

        let enSleep = GameModel()
        enSleep.phase = .sleeping
        enSleep.language = .en
        enSleep.sleeping = true
        enSleep.nightness = 1
        enSleep.showZzz = true
        enSleep.growth = 1.36
        enSleep.eatenCount = 3
        snapshot(RootView().environmentObject(enSleep), "\(dir)/10-sleeping-en.png")

        let grown = GameModel()
        grown.phase = .idle
        grown.growth = 1.6
        grown.eatenCount = 5
        snapshot(RootView().environmentObject(grown), "\(dir)/07-grown.png")
    }

    @MainActor
    static func snapshot<V: View>(_ view: V, _ path: String) {
        let renderer = ImageRenderer(content: view.frame(width: Theme.width, height: Theme.height))
        renderer.scale = 2
        guard let cg = renderer.cgImage else {
            print("render failed: \(path)")
            return
        }
        let rep = NSBitmapImageRep(cgImage: cg)
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: URL(fileURLWithPath: path))
        print("wrote \(path) \(cg.width)x\(cg.height)")
    }
}
