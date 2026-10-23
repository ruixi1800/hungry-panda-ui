import SwiftUI
import AppKit

enum FruitKind: String, CaseIterable, Identifiable {
    case strawberry, avocado, watermelon, pineapple

    var id: String { rawValue }

    /// 对应的咀嚼音效（素材文件的前四个）
    var audioName: String { rawValue }

    var image: NSImage { Assets.image(rawValue) }
}

struct TraySlot: Identifiable {
    let kind: FruitKind
    var filled: Bool
    var id: FruitKind { kind }
}

/// 游戏状态机。整个流程都是串行的：拖拽 → 咀嚼 → 走到枕头 → 入睡 → 长大 → 醒来 → 白天。
@MainActor
final class GameModel: ObservableObject {
    enum Phase: Equatable {
        case cover      // 封面
        case idle       // 白天，等用户拖水果
        case dragging   // 水果被拖起
        case eating     // 正在嚼
        case walking    // 走向枕头
        case sleeping   // 躺在枕头上睡
        case waking     // 醒来、回到白天
    }

    // MARK: 状态

    @Published var phase: Phase = .cover
    @Published var growth: CGFloat = 1.0          // 熊猫体型倍率
    @Published var nightness: Double = 0          // 0 白天 → 1 夜晚
    @Published var eatenCount = 0
    @Published var bites = 0
    @Published var bitesMax = 6
    @Published var tray: [TraySlot] = FruitKind.allCases.map { TraySlot(kind: $0, filled: true) }

    // 拖拽中的水果
    @Published var dragKind: FruitKind?
    @Published var dragPoint: CGPoint = .zero

    // 嘴里的水果
    @Published var foodKind: FruitKind?
    @Published var foodPoint: CGPoint = .zero
    @Published var foodOpacity: Double = 1

    // 熊猫动作
    @Published var pandaX: CGFloat = Theme.pandaCenterX
    @Published var sleeping = false
    @Published var bob = false
    @Published var chewing = false
    @Published var showZzz = false

    @Published var language: Language

    let sound = SoundPlayer()
    private var job: Task<Void, Never>?

    init() {
        let stored = UserDefaults.standard.string(forKey: "hungryPanda.language") ?? Language.zh.rawValue
        language = Language(rawValue: stored) ?? .zh
    }

    /// 当前语言的全部文案
    var l: L10n { L10n(lang: language) }

    func setLanguage(_ lang: Language) {
        guard lang != language else { return }
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "hungryPanda.language")
    }

    static let growthStep: CGFloat = 0.12
    static let growthMax: CGFloat = 1.80

    // MARK: 派生值

    /// 熊猫嘴巴在场景坐标里的位置（会随体型变化）
    var mouthPoint: CGPoint {
        CGPoint(x: pandaX, y: Theme.floorY - PandaMetrics.mouthHeight * growth)
    }

    var hint: String {
        switch phase {
        case .cover: return ""
        case .idle: return l.hintIdle
        case .dragging: return l.hintDragging
        case .eating: return l.hintEating
        case .walking: return l.hintWalking
        case .sleeping: return l.hintSleeping
        case .waking: return l.hintWaking
        }
    }

    // MARK: 流程控制

    func startGame() {
        guard phase == .cover else { return }
        refillTray()
        withAnimation(.easeInOut(duration: 0.5)) { phase = .idle }
    }

    func reset() {
        job?.cancel()
        job = nil
        sound.stop()
        growth = 1.0
        nightness = 0
        eatenCount = 0
        bites = 0
        bitesMax = 6
        dragKind = nil
        foodKind = nil
        foodOpacity = 1
        pandaX = Theme.pandaCenterX
        sleeping = false
        bob = false
        chewing = false
        showZzz = false
        refillTray()
        withAnimation(.easeInOut(duration: 0.4)) { phase = .idle }
    }

    // MARK: 拖拽

    func beginDrag(_ kind: FruitKind, at point: CGPoint) {
        guard phase == .idle,
              tray.first(where: { $0.kind == kind })?.filled == true else { return }
        dragKind = kind
        dragPoint = point
        phase = .dragging
    }

    func dragMoved(_ kind: FruitKind, to point: CGPoint) {
        guard phase == .dragging, dragKind == kind else { return }
        dragPoint = point
    }

    func endDrag(_ kind: FruitKind, at point: CGPoint) {
        guard phase == .dragging, dragKind == kind else { return }
        let target = mouthPoint
        let distance = hypot(point.x - target.x, point.y - target.y)
        dragKind = nil
        if distance < 155 {
            startEating(kind, from: point)
        } else {
            withAnimation(.easeInOut(duration: 0.22)) { phase = .idle }
        }
    }

    /// 拖到嘴边时用于高亮提示
    var isDragNearMouth: Bool {
        guard phase == .dragging else { return false }
        return hypot(dragPoint.x - mouthPoint.x, dragPoint.y - mouthPoint.y) < 155
    }

    // MARK: 吃水果

    private func startEating(_ kind: FruitKind, from point: CGPoint) {
        if let index = tray.firstIndex(where: { $0.kind == kind }) {
            withAnimation(.easeInOut(duration: 0.2)) { tray[index].filled = false }
        }
        phase = .eating
        bites = 0
        foodKind = kind
        foodPoint = point
        foodOpacity = 1
        job?.cancel()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            foodPoint = mouthPoint
        }
        job = Task { [weak self] in
            await self?.runEating(kind)
        }
    }

    private func runEating(_ kind: FruitKind) async {
        let duration = sound.play(kind.audioName)
        let realDuration = duration > 0 ? duration : 6.0

        // 咬几口：按音频长度决定，2~9 口
        bitesMax = min(9, max(4, Int(realDuration / 1.1)))
        let interval = max(0.42, min(1.05, realDuration / Double(bitesMax + 1)))

        for i in 1...bitesMax {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            if Task.isCancelled { return }
            withAnimation(.spring(response: 0.32, dampingFraction: 0.62)) { bites = i }
            withAnimation(.easeInOut(duration: 0.16)) { chewing.toggle() }
            NSLog("HungryPanda: bite \(i)/\(bitesMax) of \(kind.rawValue)")
        }

        // 一直嚼到音频结束
        var waited = interval * Double(bitesMax)
        while sound.isPlaying && waited < realDuration + 3 {
            try? await Task.sleep(nanoseconds: 55_000_000)
            if Task.isCancelled { return }
            waited += 0.055
            if Int(waited / 0.55) % 2 == 0 { withAnimation(.easeInOut(duration: 0.2)) { chewing.toggle() } }
        }

        // 吃完：水果消失
        withAnimation(.easeOut(duration: 0.32)) { foodOpacity = 0 }
        try? await Task.sleep(nanoseconds: 380_000_000)
        if Task.isCancelled { return }
        foodKind = nil
        chewing = false
        eatenCount += 1
        sound.stop()

        await walkToPillow()
    }

    // MARK: 走路、睡觉、长大、醒来

    private func walkToPillow() async {
        phase = .walking
        withAnimation(.easeInOut(duration: 1.9)) { pandaX = 268 }

        for _ in 0..<8 {
            try? await Task.sleep(nanoseconds: 235_000_000)
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.24)) { bob.toggle() }
        }
        withAnimation(.easeInOut(duration: 0.24)) { bob = false }

        // 躺下
        withAnimation(.easeInOut(duration: 0.5)) { sleeping = true }
        try? await Task.sleep(nanoseconds: 620_000_000)
        if Task.isCancelled { return }

        // 入夜
        phase = .sleeping
        withAnimation(.easeInOut(duration: 1.5)) { nightness = 1 }
        try? await Task.sleep(nanoseconds: 1_600_000_000)
        if Task.isCancelled { return }
        showZzz = true

        // 呼噜声 + 长大
        let nightDuration = sound.play("night")
        withAnimation(.easeInOut(duration: 5.5)) {
            growth = min(Self.growthMax, growth + Self.growthStep)
        }

        let sleepSeconds = nightDuration > 0 ? nightDuration : 4.0
        var elapsed: TimeInterval = 0
        while sound.isPlaying && elapsed < sleepSeconds + 4 {
            try? await Task.sleep(nanoseconds: 120_000_000)
            if Task.isCancelled { return }
            elapsed += 0.12
        }
        sound.stop()

        // 睁眼
        withAnimation(.easeInOut(duration: 0.7)) { sleeping = false }
        showZzz = false
        try? await Task.sleep(nanoseconds: 850_000_000)
        if Task.isCancelled { return }

        // 回到白天
        phase = .waking
        withAnimation(.easeInOut(duration: 1.7)) { nightness = 0 }
        try? await Task.sleep(nanoseconds: 900_000_000)
        if Task.isCancelled { return }

        // 走回中间
        withAnimation(.easeInOut(duration: 1.9)) { pandaX = Theme.pandaCenterX }
        for _ in 0..<8 {
            try? await Task.sleep(nanoseconds: 235_000_000)
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.24)) { bob.toggle() }
        }
        withAnimation(.easeInOut(duration: 0.24)) { bob = false }
        try? await Task.sleep(nanoseconds: 600_000_000)
        if Task.isCancelled { return }

        refillTray()
        withAnimation(.easeInOut(duration: 0.4)) { phase = .idle }
    }

    private func refillTray() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            for index in tray.indices where !tray[index].filled {
                tray[index].filled = true
            }
        }
    }
}
