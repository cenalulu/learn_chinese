import Foundation

/// Loads and caches stroke order data from stroke_data.json.
final class StrokeDataLoader {
    static let shared = StrokeDataLoader()

    private var cache: [String: CharacterStrokeData] = [:]
    private var loaded = false

    private init() {}

    func data(for character: String) -> CharacterStrokeData? {
        if !loaded { load() }
        return cache[character]
    }

    func strokeCount(for character: String) -> Int? {
        data(for: character)?.strokeCount
    }

    private func load() {
        loaded = true
        guard
            let url = Bundle.main.url(forResource: "stroke_data", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(StrokeDataFile.self, from: data)
        else {
            print("[StrokeDataLoader] Failed to load stroke_data.json")
            return
        }
        cache = file.characters
        print("[StrokeDataLoader] Loaded \(cache.count) characters.")
    }
}
