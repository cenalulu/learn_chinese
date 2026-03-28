import SwiftUI

/// State for a multiple-choice option button.
enum OptionButtonState: Equatable {
    case idle
    case selected
    case correct
    case wrong

    var backgroundColor: Color {
        switch self {
        case .idle:    return Color(.secondarySystemBackground)
        case .selected: return Color.accentColor.opacity(0.12)
        case .correct: return .green
        case .wrong:   return .red
        }
    }

    var borderColor: Color {
        switch self {
        case .idle:    return .clear
        case .selected: return .accentColor
        case .correct: return .green
        case .wrong:   return .red
        }
    }

    var labelColor: Color {
        switch self {
        case .idle, .selected: return .primary
        case .correct, .wrong: return .white
        }
    }
}

/// A standard text option button used by multiple-choice exercise views.
struct OptionButton: View {
    let label: String
    let state: OptionButtonState
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(state.labelColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(state.backgroundColor, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(state.borderColor, lineWidth: 2)
                )
        }
        .disabled(state != .idle)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}
