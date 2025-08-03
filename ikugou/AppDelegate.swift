import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var mainCoordinator: MainCoordinator!

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 应用启动开始")

        // 确保应用程序激活
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // 创建窗口 - 模仿 Spotify 的尺寸和样式
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "ikugou"
        // 设置合理的最小和最大尺寸，支持拖动调整
        window.minSize = NSSize(width: 900, height: 600)
        window.maxSize = NSSize(width: 1800, height: 1200)
        window.center()

        // QQ音乐风格的窗口设置
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true

        // 禁用窗口状态恢复，确保每次都使用新的窗口大小
        window.isRestorable = false
        window.identifier = NSUserInterfaceItemIdentifier("MainWindow")

        // 创建并启动主协调器
        mainCoordinator = MainCoordinator(window: window)
        mainCoordinator.start()

        // 显示窗口
        window.makeKeyAndOrderFront(nil)

        print("✅ 窗口创建完成")
    }
}

@main
struct Main {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }
}
