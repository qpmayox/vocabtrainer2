import SwiftUI

// MARK: - 単語モデル
struct Word: Identifiable, Codable, Equatable {
    let id = UUID()
    var english: String
    var japanese: String
}

// MARK: - 難易度レベル
enum WordLevel: String, CaseIterable, Identifiable {
    case grade3 = "英検3級"
    case pre2 = "英検準2級"
    case grade2 = "英検2級"
    case pre1 = "英検準1級"

    var id: String { self.rawValue }
}

// MARK: - 単語ストア
class WordStore: ObservableObject {
    @Published var words: [Word] = []
    private var usedWords: Set<UUID> = []

    func loadWords(for level: WordLevel) {
        switch level {
        case .grade3:
            words = [
                Word(english: "apple", japanese: "りんご"),
                Word(english: "dog", japanese: "犬"),
                Word(english: "book", japanese: "本"),
                Word(english: "fish", japanese: "魚"),
                Word(english: "car", japanese: "車"),
                Word(english: "sun", japanese: "太陽"),
                Word(english: "chair", japanese: "椅子"),
                Word(english: "school", japanese: "学校"),
                Word(english: "water", japanese: "水"),
                Word(english: "milk", japanese: "牛乳")
            ]
        case .pre2:
            words = [
                Word(english: "increase", japanese: "増加する"),
                Word(english: "discover", japanese: "発見する"),
                Word(english: "expect", japanese: "期待する"),
                Word(english: "develop", japanese: "発展する"),
                Word(english: "protect", japanese: "守る"),
                Word(english: "continue", japanese: "続ける"),
                Word(english: "prepare", japanese: "準備する"),
                Word(english: "believe", japanese: "信じる"),
                Word(english: "travel", japanese: "旅行する"),
                Word(english: "create", japanese: "作り出す")
            ]
        case .grade2:
            words = [
                Word(english: "negotiate", japanese: "交渉する"),
                Word(english: "industry", japanese: "産業"),
                Word(english: "reduce", japanese: "減らす"),
                Word(english: "efficient", japanese: "効率的な"),
                Word(english: "competition", japanese: "競争"),
                Word(english: "influence", japanese: "影響"),
                Word(english: "opportunity", japanese: "機会"),
                Word(english: "environment", japanese: "環境"),
                Word(english: "application", japanese: "申請"),
                Word(english: "community", japanese: "地域社会")
            ]
        case .pre1:
            words = [
                Word(english: "inevitable", japanese: "避けられない"),
                Word(english: "perception", japanese: "認識"),
                Word(english: "implement", japanese: "実行する"),
                Word(english: "sustainable", japanese: "持続可能な"),
                Word(english: "diversity", japanese: "多様性"),
                Word(english: "legislation", japanese: "法律制定"),
                Word(english: "phenomenon", japanese: "現象"),
                Word(english: "controversial", japanese: "論争の的になる"),
                Word(english: "innovation", japanese: "革新"),
                Word(english: "consequence", japanese: "結果")
            ]
        }
        usedWords = []
    }

    func nextWord() -> Word? {
        let unusedWords = words.filter { !usedWords.contains($0.id) }
        guard let word = unusedWords.randomElement() else { return nil }
        usedWords.insert(word.id)
        return word
    }

    func reset() {
        usedWords = []
    }
}

// MARK: - レベル選択ビュー
struct LevelSelectionView: View {
    @StateObject var store = WordStore()
    @State private var selectedLevel: WordLevel?

    var body: some View {
        if let level = selectedLevel {
            QuizView(store: store, level: level) {
                selectedLevel = nil
            }
        } else {
            VStack(spacing: 20) {
                Text("難易度を選んでください")
                    .font(.title2)
                ForEach(WordLevel.allCases) { level in
                    Button(level.rawValue) {
                        store.loadWords(for: level)
                        selectedLevel = level
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// MARK: - クイズビュー
struct QuizView: View {
    @ObservedObject var store: WordStore
    let level: WordLevel
    var onFinished: () -> Void

    @State private var currentWord: Word?
    @State private var choices: [String] = []
    @State private var answerMessage: String?
    @State private var questionCount = 0
    private let totalQuestions = 10

    var body: some View {
        VStack(spacing: 20) {
            if let current = currentWord {
                Text("第 \(questionCount + 1) 問 / 全 \(totalQuestions) 問")
                Text("次の英単語の意味は？")
                    .font(.title2)
                Text(current.english)
                    .font(.largeTitle)
                    .bold()

                ForEach(choices, id: \.self) { choice in
                    Button(action: {
                        checkAnswer(choice)
                    }) {
                        Text(choice)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                if let msg = answerMessage {
                    Text(msg)
                        .font(.title2)
                        .foregroundColor(msg.contains("正解") ? .green : .red)
                }
            } else {
                Text("お疲れ様でした！全問終了です。")
                    .font(.title2)
                Button("もう一度レベル選択へ") {
                    store.reset()
                    onFinished()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            loadNext()
        }
    }

    func checkAnswer(_ choice: String) {
        if choice == currentWord?.japanese {
            answerMessage = "✅ 正解！"
        } else {
            answerMessage = "❌ 不正解"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            questionCount += 1
            if questionCount < totalQuestions {
                loadNext()
            } else {
                currentWord = nil
                choices = []
            }
        }
    }

    func loadNext() {
        if let word = store.nextWord() {
            currentWord = word
            generateChoices(for: word)
            answerMessage = nil
        } else {
            currentWord = nil
        }
    }

    func generateChoices(for word: Word) {
        let incorrects = store.words.filter { $0 != word }
            .shuffled()
            .prefix(3)
            .map { $0.japanese }

        choices = (incorrects + [word.japanese]).shuffled()
    }
}
