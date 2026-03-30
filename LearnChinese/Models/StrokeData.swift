import Foundation

/// A single stroke represented as an ordered list of normalized points (0–1 coordinate space).
/// Origin (0,0) = top-left of the character bounding box.
struct StrokeMedian: Codable {
    let points: [[Double]]  // each element is [x, y]
}

/// Stroke order data for one character.
struct CharacterStrokeData: Codable {
    let strokeCount: Int
    let medians: [StrokeMedian]  // one per stroke, in correct stroke order
}

/// Top-level container decoded from stroke_data.json.
struct StrokeDataFile: Codable {
    let characters: [String: CharacterStrokeData]
}
