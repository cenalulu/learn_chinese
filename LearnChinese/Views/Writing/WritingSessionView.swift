import SwiftUI
import PencilKit
import SwiftData

struct WritingSessionView: View {
    let word: Word

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [UserWordRecord]

    // Canvas state
    @State private var canvasView = PKCanvasView()
    @State private var traceCount = 0          // how many successful traces done
    @State private var phase: SessionPhase = .animation
    @State private var showGuide = true
    @State private var selfAssessResult: SelfAssessResult?
    @State private var strokeData: CharacterStrokeData?

    enum SessionPhase { case animation, trace, memory, selfAssess }
    enum SelfAssessResult { case correct, needsWork }

    private var record: UserWordRecord? { records.first { $0.wordID == word.id } }

    private var safeToneColor: Color {
        switch word.primaryTone {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }

    private var expectedStrokes: Int { strokeData?.strokeCount ?? 0 }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if geo.size.width > 700 {
                    // iPad landscape: side-by-side layout
                    HStack(spacing: 0) {
                        leftPanel
                            .frame(width: geo.size.width * 0.38)
                        Divider()
                        rightPanel
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    // Portrait / compact: stacked
                    VStack(spacing: 0) {
                        leftPanel
                            .frame(height: geo.size.height * 0.42)
                        Divider()
                        rightPanel
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Write: \(word.hanzi)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            strokeData = StrokeDataLoader.shared.data(for: word.hanzi)
        }
    }

    // MARK: - Left panel (reference)

    private var leftPanel: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Phase indicator
                phaseSteps

                // Character info
                VStack(spacing: 6) {
                    Text(word.hanzi)
                        .font(.system(size: 80, weight: .medium))
                        .foregroundStyle(safeToneColor)
                    Text(word.pinyin)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(word.english)
                        .font(.headline)
                }
                .padding(.top, 8)

                // Stroke order animation
                if let sd = strokeData {
                    StrokeAnimationView(strokeData: sd, color: safeToneColor)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "pencil.slash")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Stroke data not available")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if expectedStrokes > 0 {
                            Text("\(expectedStrokes) strokes")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                }

                if !word.exampleSentenceZh.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.exampleSentenceZh)
                            .font(.system(size: 16))
                        Text(word.exampleSentenceEn)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Right panel (writing canvas)

    private var rightPanel: some View {
        VStack(spacing: 0) {
            // Phase description
            phaseHeader
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            // Canvas area
            canvasArea
                .padding(.horizontal, 20)

            Spacer()

            // Bottom controls
            bottomControls
                .padding(20)
        }
    }

    // MARK: - Phase steps indicator

    private var phaseSteps: some View {
        HStack(spacing: 0) {
            ForEach(["Watch", "Trace ×2", "Write"], id: \.self) { step in
                let index = ["Watch", "Trace ×2", "Write"].firstIndex(of: step)!
                let currentIndex = phase == .animation ? 0 : (phase == .trace ? 1 : 2)
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        Circle()
                            .fill(index <= currentIndex ? safeToneColor : Color(.tertiaryLabel))
                            .frame(width: 10, height: 10)
                        Text(step)
                            .font(.caption2)
                            .foregroundStyle(index <= currentIndex ? safeToneColor : .secondary)
                    }
                    if index < 2 {
                        Rectangle()
                            .fill(index < currentIndex ? safeToneColor : Color(.tertiaryLabel))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Phase header

    private var phaseHeader: some View {
        Group {
            switch phase {
            case .animation:
                Label("Watch the stroke order, then tap Start", systemImage: "eye.fill")
                    .font(.subheadline).foregroundStyle(.secondary)
            case .trace:
                Label("Trace the character \(2 - traceCount) more time\(2 - traceCount == 1 ? "" : "s")",
                      systemImage: "hand.draw.fill")
                    .font(.subheadline).foregroundStyle(.orange)
            case .memory:
                Label("Now write from memory", systemImage: "pencil.tip")
                    .font(.subheadline).foregroundStyle(safeToneColor)
            case .selfAssess:
                Label("How did you do?", systemImage: "checkmark.circle.fill")
                    .font(.subheadline).foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Canvas area

    private var canvasArea: some View {
        ZStack {
            // Grid guide
            CharacterGridView()

            // Character guide (shown during trace phase)
            if phase == .trace && showGuide {
                Text(word.hanzi)
                    .font(.system(size: 200, weight: .light))
                    .foregroundStyle(safeToneColor.opacity(0.18))
                    .allowsHitTesting(false)
            }

            // PencilKit canvas (hidden during animation phase)
            if phase != .animation {
                PKCanvasViewWrapper(canvasView: $canvasView)
                    .allowsHitTesting(phase != .selfAssess)
            }

            // Self-assess overlay
            if phase == .selfAssess {
                Text(word.hanzi)
                    .font(.system(size: 200, weight: .light))
                    .foregroundStyle(safeToneColor.opacity(0.35))
                    .allowsHitTesting(false)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        Group {
            switch phase {
            case .animation:
                Button("Start Tracing") {
                    withAnimation { phase = .trace }
                }
                .buttonStyle(.borderedProminent)
                .tint(safeToneColor)
                .controlSize(.large)

            case .trace:
                HStack(spacing: 16) {
                    Button("Clear") { clearCanvas() }
                        .buttonStyle(.bordered)
                        .tint(.secondary)

                    Button("Done (\(traceCount)/2)") { finishTrace() }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(canvasView.drawing.strokes.isEmpty)
                }

            case .memory:
                HStack(spacing: 16) {
                    Button("Clear") { clearCanvas() }
                        .buttonStyle(.bordered)
                        .tint(.secondary)

                    Button("Check") {
                        withAnimation { phase = .selfAssess }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(safeToneColor)
                    .disabled(canvasView.drawing.strokes.isEmpty)
                }

            case .selfAssess:
                VStack(spacing: 12) {
                    Text("Compare your writing to the guide overlay")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        Button {
                            saveResult(.needsWork)
                        } label: {
                            Label("Practice more", systemImage: "arrow.circlepath")
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                        Button {
                            saveResult(.correct)
                        } label: {
                            Label("Got it!", systemImage: "checkmark")
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
        }
        .frame(maxWidth: 400)
    }

    // MARK: - Logic

    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    private func finishTrace() {
        traceCount += 1
        clearCanvas()
        if traceCount >= 2 {
            withAnimation { phase = .memory }
        }
    }

    private func saveResult(_ result: SelfAssessResult) {
        let isCorrect = result == .correct
        let record = ensureRecord()

        // Update writing SRS
        record.isWritingLearned = true
        record.lastReviewDate = Date()

        if isCorrect {
            record.writingTimesCorrect += 1
            record.writingRepetitions += 1
            record.writingEaseFactor = min(2.5, record.writingEaseFactor + 0.1)
            let newInterval = nextWritingInterval(record: record)
            record.writingInterval = newInterval
            record.writingDueDate = Calendar.current.date(
                byAdding: .day, value: newInterval, to: Date()) ?? Date()
        } else {
            record.writingTimesIncorrect += 1
            record.writingRepetitions = 0
            record.writingEaseFactor = max(1.3, record.writingEaseFactor - 0.2)
            record.writingInterval = 1
            record.writingDueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }

        try? modelContext.save()
        dismiss()
    }

    private func nextWritingInterval(record: UserWordRecord) -> Int {
        switch record.writingRepetitions {
        case 0: return 1
        case 1: return 3
        default: return max(record.writingInterval + 1,
                            Int((Double(record.writingInterval) * record.writingEaseFactor).rounded()))
        }
    }

    private func ensureRecord() -> UserWordRecord {
        if let existing = records.first(where: { $0.wordID == word.id }) { return existing }
        let new = UserWordRecord(wordID: word.id)
        modelContext.insert(new)
        return new
    }
}

// MARK: - Character grid background

struct CharacterGridView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { path in
                // outer border
                path.addRect(CGRect(x: 0, y: 0, width: w, height: h))
                // cross
                path.move(to: .init(x: w/2, y: 0)); path.addLine(to: .init(x: w/2, y: h))
                path.move(to: .init(x: 0, y: h/2)); path.addLine(to: .init(x: w, y: h/2))
                // diagonals
                path.move(to: .init(x: 0, y: 0)); path.addLine(to: .init(x: w, y: h))
                path.move(to: .init(x: w, y: 0)); path.addLine(to: .init(x: 0, y: h))
            }
            .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        }
        .background(Color(.systemBackground))
    }
}
