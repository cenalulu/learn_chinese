import Foundation
import SwiftData

@Model
final class Word {
    @Attribute(.unique) var id: UUID
    var hanzi: String
    var pinyin: String            // display form with tone marks: "nǐ hǎo"
    var pinyinToneNumbers: String // processing form: "ni3 hao3"
    var english: String
    var hskLevel: Int
    var topicTags: [String]
    var exampleSentenceZh: String
    var exampleSentenceEn: String
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        hanzi: String,
        pinyin: String,
        pinyinToneNumbers: String,
        english: String,
        hskLevel: Int = 1,
        topicTags: [String] = [],
        exampleSentenceZh: String = "",
        exampleSentenceEn: String = "",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.pinyinToneNumbers = pinyinToneNumbers
        self.english = english
        self.hskLevel = hskLevel
        self.topicTags = topicTags
        self.exampleSentenceZh = exampleSentenceZh
        self.exampleSentenceEn = exampleSentenceEn
        self.sortOrder = sortOrder
    }

    /// First tone number found in pinyinToneNumbers (1–4, 0 = neutral)
    var primaryTone: Int {
        for char in pinyinToneNumbers {
            if let digit = char.wholeNumberValue, digit >= 1 && digit <= 4 {
                return digit
            }
        }
        return 0
    }
}

// MARK: - Tone color coding
extension Word {
    var toneColor: String {
        switch primaryTone {
        case 1: return "tone1"   // blue   – flat
        case 2: return "tone2"   // green  – rising
        case 3: return "tone3"   // orange – falling-rising
        case 4: return "tone4"   // red    – falling
        default: return "toneN"  // gray   – neutral
        }
    }
}

// MARK: - Codable mirror for JSON seeding
struct WordSeed: Codable {
    let id: String
    let hanzi: String
    let pinyin: String
    let pinyinToneNumbers: String
    let english: String
    let hskLevel: Int
    let topicTags: [String]
    let exampleSentenceZh: String
    let exampleSentenceEn: String
    let sortOrder: Int
}

struct WordSeedFile: Codable {
    let words: [WordSeed]
}
