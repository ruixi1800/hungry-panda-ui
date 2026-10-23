import AppKit

/// 从 App 包里加载图片资源，带缓存。
enum Assets {
    private static var cache: [String: NSImage] = [:]

    static func image(_ name: String, ext: String = "png") -> NSImage {
        if let cached = cache[name] { return cached }
        let url = Bundle.main.url(forResource: name, withExtension: ext)
            ?? Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources")
            ?? assetDirectory().flatMap { dir in
                let candidates = ["\(dir)/\(name).\(ext)", "\(dir)/fruits/\(name).\(ext)"]
                return candidates.first { FileManager.default.fileExists(atPath: $0) }
                    .map { URL(fileURLWithPath: $0) }
            }
        let image = url.flatMap { NSImage(contentsOf: $0) }
            ?? NSImage(size: NSSize(width: 8, height: 8))
        cache[name] = image
        return image
    }

    static var cover: NSImage { image("cover", ext: "jpg") }

    /// 预览/调试工具用：允许通过环境变量或可执行文件旁边的 Resources 目录加载素材。
    private static func assetDirectory() -> String? {
        if let dir = ProcessInfo.processInfo.environment["HUNGRYPANDA_RESOURCES"] {
            return dir
        }
        let sibling = Bundle.main.bundleURL.deletingLastPathComponent()
            .appendingPathComponent("Resources").path
        return FileManager.default.fileExists(atPath: sibling) ? sibling : nil
    }
}
