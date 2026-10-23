import SwiftUI

struct RootView: View {
    @EnvironmentObject var game: GameModel

    var body: some View {
        ZStack {
            SceneView()
            if game.phase == .cover {
                CoverView()
                    .transition(.opacity)
            }
        }
        .frame(width: Theme.width, height: Theme.height)
        .coordinateSpace(name: "scene")
        .clipped()
    }
}
