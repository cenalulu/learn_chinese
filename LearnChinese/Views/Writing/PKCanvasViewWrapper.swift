import SwiftUI
import PencilKit

/// Wraps PKCanvasView for use in SwiftUI.
/// Supports Apple Pencil and finger drawing, with a clear callback.
struct PKCanvasViewWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var onDrawingChanged: (() -> Void)?

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.monoline, color: .black, width: 10)
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput   // allow both finger and Pencil
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onDrawingChanged: onDrawingChanged) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChanged: (() -> Void)?
        init(onDrawingChanged: (() -> Void)?) { self.onDrawingChanged = onDrawingChanged }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) { onDrawingChanged?() }
    }
}

// MARK: - Stroke count helper

extension PKDrawing {
    /// Approximate stroke count based on path count in the drawing.
    var approximateStrokeCount: Int { strokes.count }
}
