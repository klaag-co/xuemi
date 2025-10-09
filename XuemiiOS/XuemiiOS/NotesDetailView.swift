import SwiftUI
import PencilKit

struct NotesDetailView: View {
    @Binding var note: Note
    @State private var pkDrawing: PKDrawing = .init()

    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)

            Divider()

            // 🎨 main drawing canvas
            PencilCanvasView(
                drawing: $pkDrawing,
                isFingerDrawingEnabled: true,
                backgroundColor: .systemBackground
            )
            .ignoresSafeArea(.keyboard) // so drawing isn’t pushed up by keyboard
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // load saved drawing if exists
            if let data = note.drawingData,
               let drawing = try? PKDrawing(data: data) {
                pkDrawing = drawing
            }
        }
        .onDisappear {
            // save drawing when leaving
            note.drawingData = pkDrawing.dataRepresentation()
        }
    }
}

