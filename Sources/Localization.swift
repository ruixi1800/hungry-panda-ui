import Foundation

/// App 内可切换的语言。
enum Language: String, CaseIterable, Identifiable {
    case zh
    case en

    var id: String { rawValue }

    /// 切换按钮上的短标签
    var shortLabel: String { self == .zh ? "中" : "EN" }

    var fullLabel: String { self == .zh ? "中文" : "English" }
}

/// 全部界面文案。中文是主版本，英文是一一对应的翻译。
struct L10n {
    let lang: Language

    private var zh: Bool { lang == .zh }

    // 通用
    var appTitle: String { "hungry Panda UI" }
    var appSubtitle: String { zh ? "吃饱了就睡，睡醒就长大" : "Eat, nap, grow, repeat" }

    // 封面
    var coverTagline: String { zh ? "一只永远吃不饱的熊猫" : "A panda that is never full" }
    var coverBody: String {
        zh
            ? "把水果拖到它嘴边喂饱它。\n它会走到白枕头上睡一觉，醒来长高一点点，\n水果篮里的四样水果可以一直喂下去。"
            : "Drag a fruit to its mouth and feed it.\nIt waddles to the white pillow for a nap,\nthen wakes up a little bigger — again and again."
    }
    var startButton: String { zh ? "开饭啦" : "Feeding time" }
    var restartTip: String { zh ? "提示：也可以按 ⌘R 重新开始" : "Tip: press ⌘R to restart" }

    // 水果篮
    var trayTitle: String { zh ? "水果篮" : "Fruit basket" }
    var traySubtitle: String { zh ? "拖到熊猫嘴边" : "Drag to the panda's mouth" }
    var slotEmpty: String { zh ? "吃光啦" : "All gone" }

    // 底部提示
    var hintIdle: String { zh ? "把水果拖到熊猫嘴边" : "Drag a fruit to the panda's mouth" }
    var hintDragging: String { zh ? "松手喂给它" : "Drop it in!" }
    var hintEating: String { zh ? "啊呜…啊呜…" : "Nom… nom…" }
    var hintWalking: String { zh ? "吃饱了，去枕头上睡觉…" : "Full! Off to the pillow…" }
    var hintSleeping: String { zh ? "呼——呼——" : "Zzz…" }
    var hintWaking: String { zh ? "睡醒了，长高啦！" : "Woke up… and grew!" }
    var mouthOpen: String { zh ? "张嘴～" : "Open wide!" }

    // 顶部状态
    func eaten(_ count: Int) -> String {
        zh ? "已吃 \(count) 个" : "Eaten \(count)"
    }

    func size(_ percent: Int) -> String {
        zh ? "体型 \(percent)%" : "Size \(percent)%"
    }

    // 菜单
    var menuTitle: String { zh ? "游戏" : "Game" }
    var menuRestart: String { zh ? "重新开始" : "Restart" }

    // 水果名
    func fruitName(_ kind: FruitKind) -> String {
        if zh {
            switch kind {
            case .strawberry: return "草莓"
            case .avocado: return "牛油果"
            case .watermelon: return "西瓜"
            case .pineapple: return "菠萝"
            }
        } else {
            switch kind {
            case .strawberry: return "Strawberry"
            case .avocado: return "Avocado"
            case .watermelon: return "Watermelon"
            case .pineapple: return "Pineapple"
            }
        }
    }
}
