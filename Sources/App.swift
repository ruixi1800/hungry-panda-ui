import SwiftUI

@main
struct HungryPandaApp: App {
    @StateObject private var game = GameModel()

    var body: some Scene {
        WindowGroup("hungry Panda UI") {
            RootView()
                .environmentObject(game)
                .frame(width: Theme.width, height: Theme.height)
                .preferredColorScheme(.light)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu(game.l.menuTitle) {
                Button(game.l.menuRestart) { game.reset() }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
