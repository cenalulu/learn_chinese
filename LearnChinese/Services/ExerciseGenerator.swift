import Foundation

struct ExerciseGenerator {

    /// Build a shuffled exercise queue for a lesson.
    /// - Parameters:
    ///   - lesson: The lesson whose words and sentences to use.
    ///   - allWords: Full word pool used to generate wrong-answer distractors.
    static func exercises(for lesson: LessonContent, allWords: [Word]) -> [Exercise] {
        let lessonWords = allWords.filter { lesson.wordIDs.contains($0.id.uuidString) }
        guard !lessonWords.isEmpty else { return [] }

        var exercises: [Exercise] = []

        for word in lessonWords {
            let distractors = allWords.filter { $0.id != word.id }.shuffled()

            // Hanzi → English: show the character, pick the meaning
            let wrongMeanings = distractors.prefix(3).map { $0.english }
            let meaningOptions = ([word.english] + wrongMeanings).shuffled()
            exercises.append(Exercise(kind: .hanziToEnglish(word: word, options: meaningOptions)))

            // English → Hanzi: show the meaning, pick the character
            let wrongWords = Array(distractors.prefix(3))
            let wordOptions = ([word] + wrongWords).shuffled()
            exercises.append(Exercise(kind: .englishToHanzi(word: word, options: wordOptions)))
        }

        // Sentence tile exercises
        for seed in lesson.sentenceExercises {
            exercises.append(Exercise(kind: .sentenceTiles(
                tiles: seed.tiles,
                shuffled: seed.tiles.shuffled(),
                translation: seed.translation
            )))
        }

        // Limit to a reasonable session length (max 12 exercises)
        return Array(exercises.shuffled().prefix(12))
    }
}
