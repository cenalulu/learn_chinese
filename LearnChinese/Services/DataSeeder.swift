import Foundation
import SwiftData

/// Loads hsk1_words.json into the SwiftData store on first launch.
struct DataSeeder {

    static func seedIfNeeded(context: ModelContext, profile: UserProfile) {
        guard !profile.hasSeededData else { return }

        guard
            let url = Bundle.main.url(forResource: "hsk1_words", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(WordSeedFile.self, from: data)
        else {
            print("[DataSeeder] Failed to load hsk1_words.json")
            return
        }

        for seed in file.words {
            let word = Word(
                id: UUID(uuidString: seed.id) ?? UUID(),
                hanzi: seed.hanzi,
                pinyin: seed.pinyin,
                pinyinToneNumbers: seed.pinyinToneNumbers,
                english: seed.english,
                hskLevel: seed.hskLevel,
                topicTags: seed.topicTags,
                exampleSentenceZh: seed.exampleSentenceZh,
                exampleSentenceEn: seed.exampleSentenceEn,
                sortOrder: seed.sortOrder
            )
            context.insert(word)
        }

        profile.hasSeededData = true

        do {
            try context.save()
            print("[DataSeeder] Seeded \(file.words.count) words.")
        } catch {
            print("[DataSeeder] Save failed: \(error)")
        }
    }
}
