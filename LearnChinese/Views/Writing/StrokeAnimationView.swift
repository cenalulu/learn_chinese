import SwiftUI

/// Animates the stroke order of a character, one stroke at a time.
/// Stroke medians are drawn as thick rounded paths in sequence.
struct StrokeAnimationView: View {
    let strokeData: CharacterStrokeData
    let color: Color

    @State private var visibleStrokes: Int = 0
    @State private var currentProgress: CGFloat = 0
    @State private var isPlaying = false

    private let strokeDuration: Double = 0.45
    private let pauseBetween: Double = 0.15

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Guide grid lines (like Chinese character practice paper)
                guideGrid

                // Completed strokes (fully drawn)
                ForEach(0..<visibleStrokes, id: \.self) { i in
                    StrokePath(points: strokeData.medians[i].points)
                        .stroke(color.opacity(0.85),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
                }

                // Current stroke animating in
                if visibleStrokes < strokeData.medians.count {
                    StrokePath(points: strokeData.medians[visibleStrokes].points)
                        .trim(from: 0, to: currentProgress)
                        .stroke(color,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))

                    // Stroke start dot
                    if let first = strokeData.medians[visibleStrokes].points.first {
                        Circle()
                            .fill(color)
                            .frame(width: 18, height: 18)
                            .position(x: 0, y: 0)  // positioned via GeometryReader below
                            .overlay(
                                GeometryReader { geo in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 18, height: 18)
                                        .position(
                                            x: first[0] * geo.size.width,
                                            y: first[1] * geo.size.height
                                        )
                                }
                            )
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 260)
            .padding(8)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))

            // Controls
            HStack(spacing: 20) {
                Text("\(strokeData.strokeCount) stroke\(strokeData.strokeCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    replay()
                } label: {
                    Label(isPlaying ? "Playing…" : "Replay", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .disabled(isPlaying)
            }
        }
        .onAppear { replay() }
    }

    // MARK: - Guide grid

    private var guideGrid: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                // outer box
                path.addRect(CGRect(x: 0, y: 0, width: w, height: h))
                // cross hairs
                path.move(to: CGPoint(x: w/2, y: 0))
                path.addLine(to: CGPoint(x: w/2, y: h))
                path.move(to: CGPoint(x: 0, y: h/2))
                path.addLine(to: CGPoint(x: w, y: h/2))
                // diagonals
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: 0, y: h))
            }
            .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        }
    }

    // MARK: - Animation driver

    func replay() {
        visibleStrokes = 0
        currentProgress = 0
        isPlaying = true
        animateStroke(index: 0)
    }

    private func animateStroke(index: Int) {
        guard index < strokeData.medians.count else {
            isPlaying = false
            return
        }
        currentProgress = 0
        withAnimation(.linear(duration: strokeDuration)) {
            currentProgress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + strokeDuration + pauseBetween) {
            visibleStrokes = index + 1
            currentProgress = 0
            animateStroke(index: index + 1)
        }
    }
}

// MARK: - StrokePath shape

/// A SwiftUI Shape that draws a polyline through normalized (0–1) points.
struct StrokePath: Shape {
    let points: [[Double]]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }
        let mapped = points.map {
            CGPoint(x: $0[0] * rect.width, y: $0[1] * rect.height)
        }
        path.move(to: mapped[0])
        for pt in mapped.dropFirst() {
            path.addLine(to: pt)
        }
        return path
    }
}
