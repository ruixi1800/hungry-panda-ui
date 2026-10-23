import SwiftUI

/// 全局配色与布局常量。所有坐标都基于 960 × 720 的设计画布。
enum Theme {
    static let width: CGFloat = 960
    static let height: CGFloat = 720

    /// 地板线的 y 坐标
    static let floorY: CGFloat = 596
    /// 熊猫默认站位（画面正中）
    static let pandaCenterX: CGFloat = 470
    /// 白色枕头中心
    static let pillowCenter = CGPoint(x: 212, y: 592)

    // 墨色与文字
    static let ink = Color(red: 0.11, green: 0.10, blue: 0.10)
    static let brown = Color(red: 0.40, green: 0.26, blue: 0.14)
    static let brownSoft = Color(red: 0.55, green: 0.39, blue: 0.25)
    static let blush = Color(red: 1.0, green: 0.63, blue: 0.64)
    static let tongue = Color(red: 0.93, green: 0.44, blue: 0.45)

    // 白天
    static let dayWall = Color(red: 1.0, green: 0.890, blue: 0.714)
    static let dayWallDeep = Color(red: 0.980, green: 0.816, blue: 0.588)
    static let dayFloor = Color(red: 0.957, green: 0.757, blue: 0.502)
    static let dayRug = Color(red: 0.988, green: 0.855, blue: 0.647)

    // 夜晚
    static let nightWall = Color(red: 0.137, green: 0.157, blue: 0.310)
    static let nightWallDeep = Color(red: 0.082, green: 0.098, blue: 0.212)
    static let nightFloor = Color(red: 0.106, green: 0.122, blue: 0.259)
    static let nightRug = Color(red: 0.169, green: 0.188, blue: 0.361)

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// 水果篮 2×2 网格的几何，拖拽判定与卡片位置共用一套数字。
enum TrayLayout {
    static let center = CGPoint(x: 810, y: 344)
    static let panel = CGSize(width: 276, height: 308)
    static let cell: CGFloat = 112
    static let gap: CGFloat = 12

    static func cellCenter(_ index: Int) -> CGPoint {
        let col = CGFloat(index % 2)
        let row = CGFloat(index / 2)
        return CGPoint(
            x: center.x - (cell + gap) / 2 + col * (cell + gap),
            y: center.y - 44 + row * (cell + gap)
        )
    }

    static func cellCenter(for kind: FruitKind) -> CGPoint {
        cellCenter(FruitKind.allCases.firstIndex(of: kind) ?? 0)
    }
}

/// 熊猫的尺寸与嘴巴位置
enum PandaMetrics {
    static let width: CGFloat = 300
    static let height: CGFloat = 340
    /// 嘴巴相对脚底的高度（未缩放）
    static let mouthHeight: CGFloat = 148
}
