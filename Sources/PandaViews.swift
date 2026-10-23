import SwiftUI
import AppKit

/// 站着的熊猫（饿了 / 吃东西两种姿态）。
struct PandaView: View {
    var armsUp: Bool = false
    var chewing: Bool = false

    var body: some View {
        ZStack {
            // 腿
            Capsule().fill(Theme.ink)
                .frame(width: 92, height: 56)
                .rotationEffect(.degrees(-6))
                .position(x: 98, y: 318)
            Capsule().fill(Theme.ink)
                .frame(width: 92, height: 56)
                .rotationEffect(.degrees(6))
                .position(x: 202, y: 318)

            // 身体
            Ellipse().fill(Color.white)
                .frame(width: 190, height: 140)
                .position(x: 150, y: 256)

            // 垂着的手臂
            if !armsUp {
                arm(x: 64, y: 246, angle: -30)
                arm(x: 236, y: 246, angle: 30)
            }

            head

            // 抓水果的手臂画在最上层，水果会盖在它上面
            if armsUp {
                arm(x: 106, y: 214, angle: -48)
                arm(x: 194, y: 214, angle: 48)
            }
        }
        .frame(width: PandaMetrics.width, height: PandaMetrics.height)
    }

    private func arm(x: CGFloat, y: CGFloat, angle: Double) -> some View {
        Capsule().fill(Theme.ink)
            .frame(width: 76, height: 46)
            .rotationEffect(.degrees(angle))
            .position(x: x, y: y)
    }

    private var head: some View {
        ZStack {
            // 耳朵
            Circle().fill(Theme.ink).frame(width: 64).offset(x: -56, y: -62)
            Circle().fill(Theme.ink).frame(width: 64).offset(x: 56, y: -62)

            // 脸
            Circle().fill(Color.white).frame(width: 178)

            // 眼罩
            Ellipse().fill(Theme.ink)
                .frame(width: 54, height: 64)
                .rotationEffect(.degrees(-14))
                .offset(x: -38, y: -6)
            Ellipse().fill(Theme.ink)
                .frame(width: 54, height: 64)
                .rotationEffect(.degrees(14))
                .offset(x: 38, y: -6)

            eye(x: -37)
            eye(x: 37)

            // 腮红
            Ellipse().fill(Theme.blush.opacity(0.55))
                .frame(width: 30, height: 15)
                .offset(x: -70, y: 26)
            Ellipse().fill(Theme.blush.opacity(0.55))
                .frame(width: 30, height: 15)
                .offset(x: 70, y: 26)

            // 鼻子
            ZStack {
                Ellipse().fill(Theme.ink).frame(width: 23, height: 16)
                Ellipse().fill(Color.white.opacity(0.45)).frame(width: 8, height: 5).offset(x: -3, y: -3)
            }
            .offset(y: 24)

            mouth.offset(y: 44)
        }
        .frame(width: 178, height: 178)
        .position(x: 150, y: 146)
    }

    private func eye(x: CGFloat) -> some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 27)
            Circle().fill(Theme.ink).frame(width: 16).offset(x: x < 0 ? 2.5 : -2.5, y: 2)
            Circle().fill(Color.white.opacity(0.9)).frame(width: 5).offset(x: x < 0 ? 5 : -5, y: -3)
        }
        .offset(x: x, y: -7)
    }

    @ViewBuilder
    private var mouth: some View {
        if chewing {
            ZStack {
                Ellipse().fill(Theme.ink).frame(width: 36, height: 28)
                Ellipse().fill(Theme.tongue).frame(width: 22, height: 14).offset(y: 6)
            }
        } else {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: 9))
            }
            .stroke(Theme.ink, style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
            .frame(width: 20, height: 9)
        }
    }
}

/// 躺在枕头上睡觉的熊猫。
struct SleepingPandaView: View {
    var body: some View {
        ZStack {
            // 身体
            Ellipse().fill(Color.white)
                .frame(width: 208, height: 126)
                .position(x: 214, y: 150)
                .shadow(color: Color.black.opacity(0.10), radius: 8, y: 3)

            // 后腿
            Capsule().fill(Theme.ink)
                .frame(width: 60, height: 40)
                .rotationEffect(.degrees(-40))
                .position(x: 300, y: 150)

            // 前爪垫在下巴下面
            Capsule().fill(Theme.ink)
                .frame(width: 74, height: 42)
                .rotationEffect(.degrees(12))
                .position(x: 152, y: 180)
            Capsule().fill(Theme.ink)
                .frame(width: 66, height: 38)
                .rotationEffect(.degrees(-6))
                .position(x: 238, y: 184)

            // 头
            ZStack {
                Circle().fill(Theme.ink).frame(width: 54).offset(x: -40, y: -50)
                Circle().fill(Theme.ink).frame(width: 54).offset(x: 46, y: -54)
                Circle().fill(Color.white).frame(width: 134)

                Ellipse().fill(Theme.ink)
                    .frame(width: 44, height: 26)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -14, y: 0)
                Ellipse().fill(Theme.ink)
                    .frame(width: 44, height: 26)
                    .rotationEffect(.degrees(10))
                    .offset(x: 34, y: -2)

                ClosedEye().offset(x: -15, y: 2)
                ClosedEye().offset(x: 33, y: 0)

                Ellipse().fill(Theme.ink)
                    .frame(width: 18, height: 12)
                    .offset(x: 8, y: 26)

                Ellipse().fill(Theme.blush.opacity(0.5))
                    .frame(width: 26, height: 13)
                    .offset(x: -50, y: 26)
                Ellipse().fill(Theme.blush.opacity(0.5))
                    .frame(width: 26, height: 13)
                    .offset(x: 46, y: 22)
            }
            .frame(width: 134, height: 134)
            .position(x: 100, y: 118)
            .shadow(color: Color.black.opacity(0.10), radius: 8, y: 4)
        }
        .frame(width: 340, height: 210)
    }
}

private struct ClosedEye: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 4))
            path.addQuadCurve(to: CGPoint(x: 22, y: 4), control: CGPoint(x: 11, y: 15))
        }
        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .frame(width: 22, height: 16)
    }
}

/// 睡觉时飘出来的 Zzz
struct ZzzBadge: View {
    var night: Bool = false
    @State private var floating = false

    private var textColor: Color { night ? Color.white.opacity(0.92) : Theme.brown }

    var body: some View {
        ZStack {
            Text("z").font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(textColor.opacity(0.75))
                .offset(x: -22, y: 12)
            Text("z").font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(textColor.opacity(0.85))
                .offset(x: 0, y: -6)
            Text("Z").font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(textColor)
                .offset(x: 26, y: -28)
        }
        .opacity(floating ? 1 : 0.55)
        .offset(y: floating ? -6 : 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }
}
