import SwiftUI
import AppKit

/// 水果贴图 + 已咬出的半圆缺口。
struct FruitSprite: View {
    let kind: FruitKind
    var bites: Int = 0
    var size: CGFloat = 110

    private var aspect: CGFloat {
        let s = kind.image.size
        guard s.width > 0, s.height > 0 else { return 1 }
        return s.width / s.height
    }

    var body: some View {
        let fitW = aspect >= 1 ? size : size * aspect
        let fitH = aspect >= 1 ? size / aspect : size

        ZStack {
            Image(nsImage: kind.image)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: size, height: size)
            BiteOverlay(bites: bites, width: fitW, height: fitH)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .scaleEffect(1 - 0.018 * CGFloat(min(bites, 10)))
    }
}

private struct BiteOverlay: View {
    var bites: Int
    var width: CGFloat
    var height: CGFloat

    /// 咬痕位置（相对水果外接矩形），从上沿开始，顺时针分布
    private static let spots: [CGPoint] = [
        CGPoint(x: -0.20, y: -0.36), CGPoint(x: 0.06, y: -0.40), CGPoint(x: 0.28, y: -0.30),
        CGPoint(x: -0.34, y: -0.10), CGPoint(x: 0.36, y: -0.08),
        CGPoint(x: -0.26, y: 0.16), CGPoint(x: 0.28, y: 0.16),
        CGPoint(x: -0.02, y: 0.32), CGPoint(x: 0.12, y: 0.00),
    ]

    var body: some View {
        ZStack {
            ForEach(Array(Self.spots.enumerated()), id: \.offset) { index, spot in
                if index < bites {
                    Circle()
                        .fill(Color.black)
                        .frame(width: width * 0.27, height: width * 0.27)
                        .offset(x: spot.x * width, y: spot.y * height)
                        .blendMode(.destinationOut)
                }
            }
        }
        .frame(width: width, height: height)
        .animation(.spring(response: 0.34, dampingFraction: 0.6), value: bites)
    }
}

/// 主场景：房间 + 熊猫 + 水果篮 + 拖拽。
struct SceneView: View {
    @EnvironmentObject var game: GameModel

    var body: some View {
        ZStack {
            RoomBackground(nightness: game.nightness)

            // 熊猫脚下的影子
            Ellipse()
                .fill(Color.black.opacity(game.nightness > 0.5 ? 0.28 : 0.10))
                .frame(width: 210 * game.growth, height: 36 * game.growth)
                .blur(radius: 10)
                .position(x: game.sleeping ? 250 : game.pandaX, y: Theme.floorY - 4)

            PillowView().position(Theme.pillowCenter)
            panda
            if game.showZzz {
                ZzzBadge(night: game.nightness > 0.5)
                    .position(x: 250 - 70 * game.growth + 52, y: Theme.floorY - 186 * game.growth)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
            TrayView()
            dragLayer
            mouthHint
            // 夜晚把整个房间压暗一层
            Color(red: 0.05, green: 0.07, blue: 0.20)
                .opacity(0.20 * game.nightness)
                .allowsHitTesting(false)
            HUD()
        }
        .frame(width: Theme.width, height: Theme.height)
    }

    @ViewBuilder
    private var panda: some View {
        Group {
            if game.sleeping {
                SleepingPandaView()
                    .frame(width: 340, height: 210)
                    .scaleEffect(game.growth, anchor: .bottom)
                    .position(x: 250, y: Theme.floorY - 105)
                    .transition(.opacity)
            } else {
                PandaView(armsUp: game.phase == .eating, chewing: game.chewing)
                    .scaleEffect(game.growth, anchor: .bottom)
                    .offset(y: game.bob ? -9 : 0)
                    .animation(.easeInOut(duration: 0.22), value: game.bob)
                    .position(x: game.pandaX, y: Theme.floorY - PandaMetrics.height / 2)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: game.sleeping)
    }

    @ViewBuilder
    private var dragLayer: some View {
        if let kind = game.dragKind {
            FruitSprite(kind: kind, bites: 0, size: 116)
                .rotationEffect(.degrees(6))
                .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
                .position(game.dragPoint)
                .zIndex(20)
        }
        if let kind = game.foodKind {
            FruitSprite(kind: kind, bites: game.bites, size: 118 * game.growth)
                .rotationEffect(.degrees(5))
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
                .opacity(game.foodOpacity)
                .position(game.foodPoint)
                .zIndex(15)
        }
    }

    @ViewBuilder
    private var mouthHint: some View {
        if game.isDragNearMouth {
            ZStack {
                Circle()
                    .stroke(Theme.brown.opacity(0.45),
                            style: StrokeStyle(lineWidth: 3, dash: [9, 7]))
                    .frame(width: 156, height: 156)
                Text(game.l.mouthOpen)
                    .font(Theme.rounded(15, .heavy))
                    .foregroundStyle(Theme.brown)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.85)))
                    .offset(y: -104)
            }
            .position(game.mouthPoint)
            .transition(.opacity)
            .allowsHitTesting(false)
        }
    }
}

/// 右侧水果篮：2×2 卡片，每张都可以拖。
struct TrayView: View {
    @EnvironmentObject var game: GameModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(game.nightness > 0.5 ? 0.16 : 0.58))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(Color.white.opacity(game.nightness > 0.5 ? 0.25 : 0.85), lineWidth: 2)
                )
                .shadow(color: Theme.brown.opacity(0.12), radius: 22, y: 12)
                .frame(width: TrayLayout.panel.width, height: TrayLayout.panel.height)
                .position(TrayLayout.center)

            VStack(spacing: 1) {
                Text(game.l.trayTitle)
                    .font(Theme.rounded(18, .heavy))
                    .foregroundStyle(game.nightness > 0.5 ? Color.white.opacity(0.85) : Theme.brown)
                Text(game.l.traySubtitle)
                    .font(Theme.rounded(11, .medium))
                    .foregroundStyle(game.nightness > 0.5 ? Color.white.opacity(0.5) : Theme.brownSoft)
            }
            .position(x: TrayLayout.center.x, y: TrayLayout.center.y - 119)

            ForEach(Array(FruitKind.allCases.enumerated()), id: \.element) { index, kind in
                FruitCard(kind: kind, index: index)
                    .position(TrayLayout.cellCenter(index))
            }
        }
        .frame(width: Theme.width, height: Theme.height)
        .opacity(1 - 0.18 * game.nightness)
    }
}

private struct FruitCard: View {
    @EnvironmentObject var game: GameModel
    let kind: FruitKind
    let index: Int

    private var center: CGPoint { TrayLayout.cellCenter(index) }
    private var filled: Bool { game.tray.first(where: { $0.kind == kind })?.filled ?? false }
    private var isSource: Bool { game.dragKind == kind }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(filled ? 0.95 : 0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            Theme.brownSoft.opacity(filled ? 0.12 : 0.35),
                            style: StrokeStyle(lineWidth: 2, dash: filled ? [] : [7, 6])
                        )
                )
                .shadow(color: Theme.brown.opacity(filled ? 0.14 : 0), radius: 9, y: 5)

            if filled {
                FruitSprite(kind: kind, bites: 0, size: 84)
                    .offset(y: -7)
                    .opacity(isSource ? 0 : 1)
                Text(game.l.fruitName(kind))
                    .font(Theme.rounded(11, .semibold))
                    .foregroundStyle(Theme.brownSoft)
                    .offset(y: 40)
            } else {
                Image(systemName: "mouth.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.brownSoft.opacity(0.3))
                    .offset(y: -6)
                Text(game.l.slotEmpty)
                    .font(Theme.rounded(11, .semibold))
                    .foregroundStyle(Theme.brownSoft.opacity(0.45))
                    .offset(y: 16)
            }
        }
        .frame(width: TrayLayout.cell, height: TrayLayout.cell)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .gesture(dragGesture)
        .allowsHitTesting(filled && (game.phase == .idle || isSource))
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("scene"))
            .onChanged { value in
                guard filled else { return }
                let point = CGPoint(x: center.x + value.translation.width,
                                    y: center.y + value.translation.height)
                if game.phase == .idle {
                    game.beginDrag(kind, at: point)
                } else if game.phase == .dragging, game.dragKind == kind {
                    game.dragMoved(kind, to: point)
                }
            }
            .onEnded { value in
                guard game.dragKind == kind else { return }
                let point = CGPoint(x: center.x + value.translation.width,
                                    y: center.y + value.translation.height)
                game.endDrag(kind, at: point)
            }
    }
}

/// 中 / EN 切换开关
struct LanguageToggle: View {
    @EnvironmentObject var game: GameModel
    var dark: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Language.allCases) { lang in
                let selected = game.language == lang
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { game.setLanguage(lang) }
                } label: {
                    Text(lang.shortLabel)
                        .font(Theme.rounded(11, .heavy))
                        .foregroundStyle(selected ? Color.white : (dark ? Color.white.opacity(0.75) : Theme.brown))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(selected ? Theme.ink : Color.clear))
                }
                .buttonStyle(.plain)
                .help(lang.fullLabel)
            }
        }
        .padding(3)
        .background(Capsule().fill(Color.white.opacity(dark ? 0.16 : 0.6)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(dark ? 0.2 : 0.8), lineWidth: 1))
    }
}

/// 顶部信息与底部提示。
struct HUD: View {
    @EnvironmentObject var game: GameModel

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("hungry Panda UI")
                        .font(Theme.rounded(20, .heavy))
                        .foregroundStyle(inkColor)
                    Text(game.l.appSubtitle)
                        .font(Theme.rounded(11, .medium))
                        .foregroundStyle(inkColor.opacity(0.55))
                }
                Spacer()
                HStack(spacing: 10) {
                    statPill(game.l.eaten(game.eatenCount))
                    statPill(game.l.size(Int((game.growth * 100).rounded())))
                    LanguageToggle(dark: game.nightness > 0.5)
                }
            }
            .padding(.leading, 96)
            .padding(.trailing, 28)
            .padding(.top, 16)

            Spacer()

            Text(game.hint)
                .font(Theme.rounded(14, .semibold))
                .foregroundStyle(inkColor.opacity(0.75))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule().fill(Color.white.opacity(game.nightness > 0.5 ? 0.14 : 0.55))
                )
                .padding(.bottom, 18)
                .opacity(game.hint.isEmpty ? 0 : 1)
        }
        .allowsHitTesting(false)
    }

    private var inkColor: Color {
        game.nightness > 0.5 ? Color.white.opacity(0.9) : Theme.brown
    }

    private func statPill(_ text: String) -> some View {
        Text(text)
            .font(Theme.rounded(12, .semibold))
            .foregroundStyle(inkColor.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(game.nightness > 0.5 ? 0.12 : 0.5)))
    }
}
