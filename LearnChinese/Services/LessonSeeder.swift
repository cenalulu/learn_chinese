import Foundation

/// Loads lessons.json from the bundle into memory (not persisted — content is static).
struct LessonSeeder {
    static func load() -> [LessonUnit] {
        guard
            let url = Bundle.main.url(forResource: "lessons", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(LessonFile.self, from: data)
        else {
            print("[LessonSeeder] Failed to load lessons.json")
            return []
        }
        return file.units
    }
}
