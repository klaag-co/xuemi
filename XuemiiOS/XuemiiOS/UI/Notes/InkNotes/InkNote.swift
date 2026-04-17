import Foundation
import PencilKit

struct InkNote: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var updatedAt: Date
    var drawingData: Data

    init(id: UUID = UUID(), title: String, drawing: PKDrawing = PKDrawing(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.updatedAt = updatedAt
        self.drawingData = drawing.dataRepresentation()
    }

    var drawing: PKDrawing {
        get { (try? PKDrawing(data: drawingData)) ?? PKDrawing() }
        set {
            drawingData = newValue.dataRepresentation()
            updatedAt = Date()
        }
    }
}

