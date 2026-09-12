//
//  AddToFolderView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI

struct AddToFolderView: View {
    
    @Namespace private var namespace
    
    @State var vocabulary: Vocabulary
    
    @State private var showingNewEditFoldersView = false

    @Environment(\.dismiss) var dismiss
    @Environment(FoldersManager.self) private var foldersManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Folders") {
                    ForEach(foldersManager.folders) { folder in
                        FolderRowItem(vocabulary: vocabulary, folder: folder)
                    }
                }
            }
            .navigationTitle("Add to Folder")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingNewEditFoldersView.toggle()
                    } label: {
                        Label("New Folder", systemImage: "plus")
                    }
                    .matchedTransitionSource(id: "addButton", in: namespace)
                }
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.flexible)
                }
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
            .sheet(isPresented: $showingNewEditFoldersView) {
                NewEditFoldersView()
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.resizes)
                    .navigationTransition(.zoom(sourceID: "addButton", in: namespace))
            }
        }
    }
}
