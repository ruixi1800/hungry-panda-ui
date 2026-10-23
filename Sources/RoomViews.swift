import SwiftUI

/// 房间背景：白天 / 夜晚两套，用 nightness 交叉淡入。
struct RoomBackground: View {
    var nightness: Double

    var body: some View {
        ZStack {
            dayRoom.opacity(1 - nightness)
            nightRoom.opacity(nightness)
        }
    }

    private var dayRoom: some View {
        ZStack {
            LinearGradient(colors: [Theme.dayWall, Theme.dayWallDeep],
                           startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                Spacer()
                Rectangle().fill(Theme.dayFloor).frame(height: 124)
            }
            // 踢脚线
            Rectangle().fill(Color.white.opacity(0.5))
                .frame(height: 9)
                .offset(y: Theme.floorY - Theme.height / 2 + 4)
            // 地毯
            Ellipse().fill(Theme.dayRug)
                .frame(width: 400, height: 66)
                .position(x: 470, y: 642)
            WindowView(night: false)
                .position(x: 176, y: 250)
        }
    }

    private var nightRoom: some View {
        ZStack {
            LinearGradient(colors: [Theme.nightWall, Theme.nightWallDeep],
                           startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                Spacer()
                Rectangle().fill(Theme.nightFloor).frame(height: 124)
            }
            Rectangle().fill(Color.white.opacity(0.08))
                .frame(height: 9)
                .offset(y: Theme.floorY - Theme.height / 2 + 4)
            Ellipse().fill(Theme.nightRug)
                .frame(width: 400, height: 66)
                .position(x: 470, y: 642)
            WindowView(night: true)
                .position(x: 176, y: 250)
        }
    }
}

/// 白天的窗户 / 夜晚的窗户（带月亮和星星）。
struct WindowView: View {
    var night: Bool

    private var frameColor: Color { night ? Color(white: 0.80) : .white }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(frameColor)
                .frame(width: 266, height: 288)
                .shadow(color: .black.opacity(night ? 0.4 : 0.13), radius: 18, y: 12)

            sky
                .frame(width: 236, height: 258)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Rectangle().fill(frameColor).frame(width: 9, height: 258)
            Rectangle().fill(frameColor).frame(width: 236, height: 9)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(frameColor, lineWidth: 9)
                .frame(width: 236, height: 258)

            // 窗台
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(frameColor)
                .frame(width: 296, height: 16)
                .offset(y: 148)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
        }
        .frame(width: 300, height: 310)
    }

    private var sky: some View {
        ZStack {
            if night {
                LinearGradient(colors: [Color(red: 0.07, green: 0.10, blue: 0.24),
                                        Color(red: 0.15, green: 0.19, blue: 0.38)],
                               startPoint: .top, endPoint: .bottom)
                ForEach(Array(stars.enumerated()), id: \.offset) { _, point in
                    Circle().fill(Color.white.opacity(0.9))
                        .frame(width: point.size, height: point.size)
                        .position(x: point.x, y: point.y)
                }
                // 月亮
                Circle().fill(Color(red: 1.0, green: 0.96, blue: 0.82))
                    .frame(width: 54)
                    .shadow(color: Color(red: 1.0, green: 0.95, blue: 0.75).opacity(0.55), radius: 16)
                    .position(x: 168, y: 66)
                Circle().fill(Color(red: 0.11, green: 0.14, blue: 0.30).opacity(0.9))
                    .frame(width: 44)
                    .position(x: 152, y: 56)
            } else {
                LinearGradient(colors: [Color(red: 0.67, green: 0.86, blue: 0.98),
                                        Color(red: 0.88, green: 0.95, blue: 1.0)],
                               startPoint: .top, endPoint: .bottom)
                // 太阳
                Circle().fill(Color(red: 1.0, green: 0.85, blue: 0.36))
                    .frame(width: 52)
                    .shadow(color: Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.7), radius: 18)
                    .position(x: 172, y: 62)
                // 云
                cloud(width: 92).position(x: 84, y: 118)
                cloud(width: 66).position(x: 168, y: 168)
            }
        }
    }

    private func cloud(width: CGFloat) -> some View {
        ZStack {
            Capsule().fill(Color.white.opacity(0.95)).frame(width: width, height: width * 0.42)
            Circle().fill(Color.white.opacity(0.95)).frame(width: width * 0.46)
                .offset(x: -width * 0.18, y: -width * 0.14)
            Circle().fill(Color.white.opacity(0.95)).frame(width: width * 0.34)
                .offset(x: width * 0.16, y: -width * 0.08)
        }
    }

    private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat)] {
        [(36, 34, 3), (78, 22, 2), (112, 60, 2.4), (196, 30, 2.6),
         (214, 96, 2), (52, 96, 2.2), (146, 118, 2), (96, 150, 2.4),
         (196, 152, 2), (30, 150, 3)]
    }
}

/// 白色枕头。
struct PillowView: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color.black.opacity(0.10))
                .frame(width: 280, height: 40)
                .blur(radius: 12)
                .offset(y: 36)

            RoundedRectangle(cornerRadius: 54, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.996, green: 0.980, blue: 0.949),
                                 Color(red: 0.937, green: 0.902, blue: 0.843)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 54, style: .continuous)
                        .strokeBorder(Color(red: 0.87, green: 0.82, blue: 0.75).opacity(0.75), lineWidth: 2)
                )
                .frame(width: 252, height: 112)
                .rotationEffect(.degrees(-3))
                .shadow(color: Theme.brown.opacity(0.22), radius: 18, y: 10)

            // 中间的压痕
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 132, y: 0),
                                  control: CGPoint(x: 66, y: 30))
            }
            .stroke(Color(red: 0.90, green: 0.86, blue: 0.80).opacity(0.75),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 132, height: 30)
            .rotationEffect(.degrees(-3))
            .offset(x: 6, y: -6)

            // 高光
            Capsule().fill(Color.white.opacity(0.85))
                .frame(width: 150, height: 24)
                .blur(radius: 7)
                .rotationEffect(.degrees(-3))
                .offset(x: -18, y: -32)
        }
        .frame(width: 300, height: 150)
    }
}
