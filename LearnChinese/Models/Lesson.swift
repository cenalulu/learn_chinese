import Foundation

// MARK: - Content models (loaded from lessons.json, not SwiftData)

struct LessonFile: Codable {
    let units: [LessonUnit]
}

struct LessonUnit: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String        // SF Symbol name
    let colorName: String   // "blue", "green", "orange", "purple", "red"
    let lessons: [LessonContent]
}

struct LessonContent: Codable, Identifiable {
    let id: String
    let title: String
    let wordIDs: [String]               // UUIDs of words taught in this lesson
    let sentenceExercises: [SentenceExerciseSeed]
}

struct SentenceExerciseSeed: Codable, Identifiable {
    let id: String
    let tiles: [String]     // correct order, e.g. ["我", "是", "学生"]
    let translation: String // English translation
}

// MARK: - Runtime exercise model (pure value type, generated at runtime)

struct Exercise: Identifiable {
    let id = UUID()
    let kind: ExerciseKind
}

enum ExerciseKind {
    /// Show the hanzi, pick the correct English meaning from 4 options.
    case hanziToEnglish(word: Word, options: [String])

    /// Show the English meaning, pick the correct hanzi from 4 options.
    case englishToHanzi(word: Word, options: [Word])

    /// Rearrange shuffled word tiles into the correct sentence.
    case sentenceTiles(tiles: [String], shuffled: [String], translation: String)
}
