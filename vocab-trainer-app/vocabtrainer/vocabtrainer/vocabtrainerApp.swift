import SwiftUI

@main
struct vocabtrainerApp: App {
    var body: some Scene {
        WindowGroup {
            LevelSelectionView() // ← ここがポイント！
        }
    }
}
