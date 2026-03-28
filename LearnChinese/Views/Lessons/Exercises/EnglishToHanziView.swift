import SwiftUI

/// Show the English meaning, tap the correct hanzi from 4 options.
struct EnglishToHanziView: View {
    let word: Word
    let options: [Word]
    let onAnswer: (Bool) -> Void

    @State private var selectedID: UUID?
    @State private var revealed = false

    var body: some View {
        VStack(spacing: 32) {
            // Prompt
            Text("Which character means…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            // English meaning card
            Text(word.english)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(28)
                .frame(maxWidth: 400)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.07), radius: 12, y: 4)

            // Hanzi options grid
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(options) { option in
                    HanziOptionButton(
                        option: option,
                        state: buttonState(for: option),
                        onTap: { select(option) }
                    )
                }
            }
            .frame(maxWidth: 560)
        }
        .padding(.horizontal, 32)
    }

    private func buttonState(for option: Word) -> OptionButtonState {
        guard revealed else {
            return selectedID == option.id ? .selected : .idle
        }
        if option.id == word.id { return .correct }
        if option.id == selectedID { return .wrong }
        return .idle
    }

    private func select(_ option: Word) {
        guard !revealed else { return }
        selectedID = option.id
        revealed = true
        AudioService.shared.speak(option.hanzi)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onAnswer(option.id == word.id)
        }
    }
}

// MARK: - Hanzi-specific option button

struct HanziOptionButton: View {
    let option: Word
    let state: OptionButtonState
    let onTap: () -> Void

    private var toneColor: Color {
        switch option.primaryTone {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(option.hanzi)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(state == .idle || state == .selected ? toneColor : .white)
                Text(option.pinyin)
                    .font(.caption)
                    .foregroundStyle(state == .idle || state == .selected ? .secondary : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(state.backgroundColor, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(state.borderColor, lineWidth: state == .selected ? 2 : 0)
            )
        }
        .disabled(state != .idle)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}
