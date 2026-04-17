import SwiftUI
import PencilKit

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var isFingerDrawingEnabled: Bool = true
    var backgroundColor: UIColor = .systemBackground

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let canvas = PKCanvasView()
        let toolPicker = PKToolPicker()
        var parent: PencilCanvasView

        init(parent: PencilCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = context.coordinator.canvas
        canvas.delegate = context.coordinator
        canvas.drawing = drawing
        canvas.backgroundColor = backgroundColor
        canvas.allowsFingerDrawing = isFingerDrawingEnabled
        canvas.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 4

        // ✅ Full iOS Notes-like tool picker (pens, colors, eraser, lasso, ruler)
        context.coordinator.toolPicker.addObserver(canvas)
        context.coordinator.toolPicker.setVisible(true, forFirstResponder: canvas)
        context.coordinator.toolPicker.selectedTool = PKInkingTool(.pen, color: .label, width: 6)
        canvas.becomeFirstResponder()

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing { uiView.drawing = drawing }
        uiView.allowsFingerDrawing = isFingerDrawingEnabled
        uiView.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
    }

    // Expose undo manager for toolbar buttons
    static func undo(_ canvas: PKCanvasView) { canvas.undoManager?.undo() }
    static func redo(_ canvas: PKCanvasView) { canvas.undoManager?.redo() }
}

