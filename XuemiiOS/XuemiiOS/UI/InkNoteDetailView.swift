import SwiftUI
import PencilKit

struct InkNoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = InkNotesManager.shared

    @State var note: InkNote
    @State private var drawing = PKDrawing()
    @State private var titleDraft = ""
    @State private var fingerMode = true

    // access the underlying PKCanvasView for undo/redo
    @State private var canvasRef: PKCanvasView? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Untitled", text: $titleDraft)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Toggle("Finger", isOn: $fingerMode).labelsHidden()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Divider()

            PencilCanvasView(drawing: $drawing, isFingerDrawingEnabled: fingerMode)
                .background(CanvasReader($canvasRef)) // capture PKCanvasView instance
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationTitle("Ink Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    canvasRef?.undoManager?.undo()
                } label: { Image(systemName: "arrow.uturn.backward") }
                .disabled(!(canvasRef?.undoManager?.canUndo ?? false))

                Button {
                    canvasRef?.undoManager?.redo()
                } label: { Image(systemName: "arrow.uturn.forward") }
                .disabled(!(canvasRef?.undoManager?.canRedo ?? false))
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    drawing = PKDrawing() // clear canvas
                } label: { Image(systemName: "trash") }

                Button {
                    exportPNG()
                } label: { Image(systemName: "square.and.arrow.up") }

                Button("Done") { saveAndClose() }
                    .fontWeight(.semibold)
            }
        }
        .onAppear {
            titleDraft = note.title
            drawing = note.drawing
        }
    }

    private func saveAndClose() {
        var edited = note
        edited.title = titleDraft.isEmpty ? "Untitled" : titleDraft
        edited.drawing = drawing
        manager.update(edited)
        dismiss()
    }

    private func exportPNG() {
        let img = drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(titleDraft.isEmpty ? "Ink" : titleDraft).png")
        if let d = img.pngData() {
            try? d.write(to: url)
            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            UIApplication.shared.topMostController()?.present(av, animated: true)
        }
    }
}

/// Captures the underlying PKCanvasView created by PencilCanvasView
private struct CanvasReader: UIViewRepresentable {
    @Binding var ref: PKCanvasView?

    init(_ ref: Binding<PKCanvasView?>) { _ref = ref }

    func makeUIView(context: Context) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: Context) {
        // walk up the view tree and find PKCanvasView
        if let canvas = uiView.superview?.subviews.compactMap({ $0 as? PKCanvasView }).first {
            if ref !== canvas { ref = canvas }
        }
    }
}

private extension UIApplication {
    func topMostController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? (connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?.rootViewController
        if let nav = base as? UINavigationController { return topMostController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController { return topMostController(base: tab.selectedViewController) }
        if let presented = base?.presentedViewController { return topMostController(base: presented) }
        return base
    }
}

