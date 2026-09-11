//
//  NewEditFoldersView.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI

struct NewEditFoldersView: View {
    
    @State private var isLoading = false
    
    @State private var folderName: String
    @State private var selectedVocabs: [Vocabulary]?
    
    @State private var folder: Folder?
    @State private var isEditing: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(FoldersManager.self) private var foldersManager
    
    init() {
        self.folderName = ""
        self.selectedVocabs = []
        self.folder = nil
        self.isEditing = false
    }
    
    init(folder: Folder) {
        self.folderName = folder.title
        self.selectedVocabs = folder.vocabularies
        self.folder = folder
        self.isEditing = true
    }
    
    var disabled: Bool {
        if isEditing {
             folderName.isEmpty || (folderName == folder!.title && selectedVocabs!.map(\.id).sorted() == folder!.vocabularies.map(\.id).sorted())
        } else {
            folderName.isEmpty
        }
    }
    
    var body: some View {
        NavigationStack {
            VocabularyListView(selectedVocabs: $selectedVocabs) {
                Section("Folder Name") {
                    TextField("Folder Name", text: $folderName)
                }
            }
            .navigationTitle("\(isEditing ? "Edit" : "New") Folder")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    var saveButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    save()
                } label: {
                    if !isLoading {
                        Text("Save")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .buttonStyle(.glassProminent)
                .disabled(disabled)
            } else {
                Button {
                    save()
                } label: {
                    if !isLoading {
                        Text("Save")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(disabled)
            }
        }
    }
    
    func save() {
        if isEditing {
            if let selectedVocabs, !folderName.isEmpty && (folderName != folder?.title || selectedVocabs != folder?.vocabularies) {
                update()
            }
        } else {
            if !folderName.isEmpty {
                add()
            }
        }
    }
    
    func add() {
        if let selectedVocabs {
            Task {
                isLoading = true
                await foldersManager.addFolder(title: folderName, vocabularies: selectedVocabs)
                isLoading = false
                dismiss()
            }
        }
    }
    
    func update() {
        if let id = folder?.id, let selectedVocabs {
            Task {
                isLoading = true
                await foldersManager.updateFolder(folder: Folder(id: id, title: folderName, vocabularies: selectedVocabs))
                isLoading = false
                dismiss()
            }
        }
    }
}

#Preview {
    NewEditFoldersView()
}
