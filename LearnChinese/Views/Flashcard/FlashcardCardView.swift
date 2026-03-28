import SwiftUI

/// A single flashcard that flips between the English front and Chinese back.
struct FlashcardCardView: View {
    let word: Word
    let isFlipped: Bool
    let onAudio: () -> Void

    // Tone → brand colors
    private var toneColor: Color {
        switch word.primaryTone {
        case 1: return Color("tone1", bundle: nil)  // blue
        case 2: return Color("tone2", bundle: nil)  // green
        case 3: return Color("tone3", bundle: nil)  // orange
        case 4: return Color("tone4", bundle: nil)  // red
        default: return .gray
        }
    }

    // Fallback if named colors aren't in Assets yet
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
        ZStack {
            frontFace
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            backFace
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: 560, maxHeight: 380)
    }

    // MARK: - Front (English)

    private var frontFace: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(word.english)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal, 24)
            Spacer()
            Text("Tap to reveal")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackground)
    }

    // MARK: - Back (Chinese)

    private var backFace: some View {
        VStack(spacing: 16) {
            Spacer()

            // Hanzi — large, tone-coloured
            Text(word.hanzi)
                .font(.system(size: 88, weight: .medium))
                .foregroundStyle(safeToneColor)

            // Pinyin
            Text(word.pinyin)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            // English reminder
            Text(word.english)
                .font(.title3)
                .foregroundStyle(.primary)
                .padding(.top, 4)

            Spacer()

            // Audio button
            Button(action: onAudio) {
                Label("Hear it", systemImage: "speaker.wave.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(safeToneColor)
            }
            .buttonStyle(.bordered)
            .tint(safeToneColor)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.background)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 6)
    }
}
