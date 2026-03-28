import SwiftUI

/// Show the hanzi + pinyin, tap the correct English meaning.
struct HanziToEnglishView: View {
    let word: Word
    let options: [String]
    let onAnswer: (Bool) -> Void

    @State private var selected: String?
    @State private var revealed = false

    private var safeToneColor: Color {
        switch word.primaryTone {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            // Prompt
            VStack(spacing: 4) {
                Text("What does this mean?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            // Hanzi card
            VStack(spacing: 10) {
                Text(word.hanzi)
                    .font(.system(size: 96, weight: .medium))
                    .foregroundStyle(safeToneColor)
                Text(word.pinyin)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Button {
                    AudioService.shared.speak(word.hanzi)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(safeToneColor)
                }
                .buttonStyle(.borderless)
                .padding(.top, 4)
            }
            .padding(28)
            .frame(maxWidth: 400)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.07), radius: 12, y: 4)

            // Options grid
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(options, id: \.self) { option in
                    OptionButton(
                        label: option,
                        state: buttonState(for: option),
                        onTap: { select(option) }
                    )
                }
            }
            .frame(maxWidth: 560)
        }
        .padding(.horizontal, 32)
    }

    private func buttonState(for option: String) -> OptionButtonState {
        guard revealed, let sel = selected else {
            return selected == option ? .selected : .idle
        }
        if option == word.english { return .correct }
        if option == sel { return .wrong }
        return .idle
    }

    private func select(_ option: String) {
        guard !revealed else { return }
        selected = option
        revealed = true
        AudioService.shared.speak(word.hanzi)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onAnswer(option == word.english)
        }
    }
}
