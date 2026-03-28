import SwiftUI

struct LessonSummaryView: View {
    let lessonTitle: String
    let correct: Int
    let total: Int
    let unitColor: Color
    let onDone: () -> Void

    private var score: Int {
        guard total > 0 else { return 0 }
        return Int(Double(correct) / Double(total) * 100)
    }

    private var stars: Int {
        switch score {
        case 90...100: return 3
        case 70..<90:  return 2
        case 1..<70:   return 1
        default:       return 0
        }
    }

    private var resultMessage: String {
        switch stars {
        case 3: return "Perfect!"
        case 2: return "Great work!"
        case 1: return "Good effort!"
        default: return "Keep practicing!"
        }
    }

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            // Stars
            HStack(spacing: 8) {
                ForEach(0..<3) { i in
                    Image(systemName: i < stars ? "star.fill" : "star")
                        .font(.system(size: 44))
                        .foregroundStyle(i < stars ? .yellow : Color(.tertiaryLabel))
                        .scaleEffect(i < stars ? 1.1 : 0.9)
                }
            }

            VStack(spacing: 8) {
                Text(resultMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(lessonTitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Score card
            VStack(spacing: 20) {
                scoreRow(label: "Score", value: "\(score)%", color: unitColor)
                Divider()
                scoreRow(label: "Correct", value: "\(correct) / \(total)", color: .green)
                Divider()
                scoreRow(label: "XP Earned", value: "+\(correct * 10)", color: .orange)
            }
            .padding(24)
            .frame(maxWidth: 380)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.07), radius: 12, y: 4)

            Spacer()

            Button("Continue", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(unitColor)
                .controlSize(.large)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 40)
        .background(Color(.systemGroupedBackground))
    }

    private func scoreRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
    }
}
