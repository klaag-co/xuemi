import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class InkNotesManager: ObservableObject {
    static let shared = InkNotesManager()

    @Published private(set) var notes: [InkNote] = [] { didSet { save() } }

    private let storeKey = "inknotes_v1"

    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) { return email }
        return nil
    }

    private init() { load() }

    // CRUD
    @discardableResult
    func add(title: String) -> InkNote {
        let new = InkNote(title: title)
        notes.insert(new, at: 0)
        return new
    }
    func update(_ note: InkNote) {
        if let i = notes.firstIndex(where: { $0.id == note.id }) { notes[i] = note }
    }
    func delete(at offsets: IndexSet) { notes.remove(atOffsets: offsets) }
    func delete(_ note: InkNote) { notes.removeAll { $0.id == note.id } }

    // Persistence (UserDefaults + Firestore)
    private func load() {
        Task {
            let remote = await getFromFirebase()
            guard !remote else { return }
            guard let data = UserDefaults.standard.data(forKey: storeKey) else { return }
            if let decoded = try? JSONDecoder().decode([InkNote].self, from: data) {
                self.notes = decoded
            }
        }
    }
    private func save() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: storeKey)
        Task { await setOnFirebase(data) }
    }

    private func getFromFirebase() async -> Bool {
        guard let uid = userDocId else { return false }
        do {
            let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
            guard let b64 = doc.data()?["\(storeKey)"] as? String,
                  let data = Data(base64Encoded: b64),
                  let decoded = try? JSONDecoder().decode([InkNote].self, from: data)
            else { return false }
            await MainActor.run { self.notes = decoded }
            return true
        } catch {
            print("InkNotes get error: \(error)")
            return false
        }
    }
    private func setOnFirebase(_ data: Data) async {
        guard let uid = userDocId else { return }
        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .setData([storeKey: data.base64EncodedString()], merge: true)
        } catch {
            print("InkNotes set error: \(error)")
        }
    }
}

