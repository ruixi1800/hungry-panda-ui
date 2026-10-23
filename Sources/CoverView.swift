import SwiftUI

/// 封面：图 1 的海报 + 标题 + 开始按钮。
struct CoverView: View {
    @EnvironmentObject var game: GameModel
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.906, blue: 0.760),
                         Color(red: 0.996, green: 0.831, blue: 0.584)],
                startPoint: .top, endPoint: .bottom
            )

            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 520)
                .blur(radius: 80)
                .offset(x: -360, y: -260)
            Circle()
                .fill(Color(red: 1.0, green: 0.96, blue: 0.88).opacity(0.5))
                .frame(width: 380)
                .blur(radius: 60)
                .offset(x: 380, y: 300)

            HStack(spacing: 70) {
                Image(nsImage: Assets.cover)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 330, height: 330)
                    .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 56, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.9), lineWidth: 5)
                    )
                    .shadow(color: Theme.brown.opacity(0.22), radius: 30, y: 18)
                    .rotationEffect(.degrees(-2.5))
                    .offset(y: appeared ? 0 : 18)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 20) {
                    Text("hungry Panda UI")
                        .font(Theme.rounded(56, .black))
                        .foregroundStyle(Theme.brown)
                        .fixedSize()

                    Text(game.l.coverTagline)
                        .font(Theme.rounded(20, .semibold))
                        .foregroundStyle(Theme.brownSoft)

                    Text(game.l.coverBody)
                        .font(Theme.rounded(14, .medium))
                        .foregroundStyle(Theme.brown.opacity(0.72))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        game.startGame()
                    } label: {
                        HStack(spacing: 8) {
                            Text(game.l.startButton)
                                .font(Theme.rounded(17, .heavy))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .heavy))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Theme.ink))
                        .shadow(color: Theme.ink.opacity(0.3), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.defaultAction)

                    Text(game.l.restartTip)
                        .font(Theme.rounded(11, .medium))
                        .foregroundStyle(Theme.brown.opacity(0.45))
                }
                .frame(maxWidth: 460, alignment: .leading)
                .offset(y: appeared ? 0 : 12)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 60)
        }
        .overlay(alignment: .topTrailing) {
            LanguageToggle()
                .padding(.top, 22)
                .padding(.trailing, 26)
        }
        .frame(width: Theme.width, height: Theme.height)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
    }
}
