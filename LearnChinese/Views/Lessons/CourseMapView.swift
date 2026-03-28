import SwiftUI
import SwiftData

struct CourseMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lessonRecords: [UserLessonRecord]
    @Query private var words: [Word]

    @State private var units: [LessonUnit] = []
    @State private var activeLessonID: String?
    @State private var activeLessonContent: LessonContent?
    @State private var activeUnit: LessonUnit?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 28) {
                    ForEach(Array(units.enumerated()), id: \.element.id) { unitIndex, unit in
                        UnitCardView(
                            unit: unit,
                            unitIndex: unitIndex,
                            lessonRecords: lessonRecords,
                            onLessonTap: { lesson in
                                activeLessonContent = lesson
                                activeUnit = unit
                            }
                        )
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(item: $activeLessonContent) { lesson in
                LessonRunnerView(
                    lesson: lesson,
                    unitColor: unitColor(for: activeUnit),
                    allWords: words
                )
            }
        }
        .onAppear {
            if units.isEmpty {
                units = LessonSeeder.load()
            }
        }
    }

    private func unitColor(for unit: LessonUnit?) -> Color {
        guard let unit else { return .blue }
        return color(from: unit.colorName)
    }

    private func color(from name: String) -> Color {
        switch name {
        case "blue":   return .blue
        case "green":  return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red":    return .red
        default:       return .blue
        }
    }
}

// MARK: - Unit card

struct UnitCardView: View {
    let unit: LessonUnit
    let unitIndex: Int
    let lessonRecords: [UserLessonRecord]
    let onLessonTap: (LessonContent) -> Void

    private var unitColor: Color {
        switch unit.colorName {
        case "blue":   return .blue
        case "green":  return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red":    return .red
        default:       return .blue
        }
    }

    private func record(for lesson: LessonContent) -> UserLessonRecord? {
        lessonRecords.first { $0.lessonID == lesson.id }
    }

    private func isLocked(_ lesson: LessonContent, at index: Int) -> Bool {
        guard index > 0 else { return false }
        let previous = unit.lessons[index - 1]
        return record(for: previous)?.isCompleted != true
    }

    private var completedCount: Int {
        unit.lessons.filter { record(for: $0)?.isCompleted == true }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Unit header
            HStack(spacing: 14) {
                Image(systemName: unit.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(unitColor, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("\(completedCount)/\(unit.lessons.count) lessons complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if completedCount == unit.lessons.count {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(unitColor)
                        .font(.title2)
                }
            }

            // Lesson nodes
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160, maximum: 220))],
                spacing: 12
            ) {
                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                    LessonNodeView(
                        lesson: lesson,
                        record: record(for: lesson),
                        isLocked: isLocked(lesson, at: index),
                        color: unitColor,
                        onTap: { onLessonTap(lesson) }
                    )
                }
            }
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Lesson node

struct LessonNodeView: View {
    let lesson: LessonContent
    let record: UserLessonRecord?
    let isLocked: Bool
    let color: Color
    let onTap: () -> Void

    private var isCompleted: Bool { record?.isCompleted == true }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.15) : (isCompleted ? color.opacity(0.15) : color.opacity(0.1)))
                        .frame(width: 56, height: 56)

                    Image(systemName: isLocked ? "lock.fill" : (isCompleted ? "checkmark" : "play.fill"))
                        .font(.title3)
                        .foregroundStyle(isLocked ? .secondary : (isCompleted ? color : color))
                }

                Text(lesson.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isLocked ? .secondary : .primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let record, !record.scoreLabel.isEmpty {
                    Text(record.scoreLabel)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isLocked ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(isCompleted ? color.opacity(0.4) : .clear, lineWidth: 2)
                    )
            )
        }
        .disabled(isLocked)
    }
}

// MARK: - LessonContent: Identifiable for .fullScreenCover(item:)
extension LessonContent: @retroactive Equatable {
    public static func == (lhs: LessonContent, rhs: LessonContent) -> Bool {
        lhs.id == rhs.id
    }
}
