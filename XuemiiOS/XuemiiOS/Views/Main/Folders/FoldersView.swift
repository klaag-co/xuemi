//
//  FoldersView.swift
//  Xuemi
//
//  Created by Tristan Chay on 13/6/26.
//

import SwiftUI

struct FoldersView: View {
    
    @Namespace private var namespace
    
    @State private var selectedFolder: Folder? = nil
    @State private var selectedFolderForMCQView: Folder? = nil
    @State private var selectedFolderForFlashcardsView: Folder? = nil
    @State private var selectedFolderForSpellingView: Folder? = nil
    @State private var selectedFolderForMemoryCardView: Folder? = nil
    
    @State private var showingNewFoldersView = false
    @State private var editingFolder: Folder? = nil
    
    @Environment(FoldersManager.self) private var foldersManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Fixed Folders") {
                    NavigationLink {
                        VocabularyListView()
                            .navigationTitle("Vocabulary List")
                    } label: {
                        Text("Vocabulary List")
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Custom Folders") {
                    if !foldersManager.folders.isEmpty {
                        ForEach(foldersManager.folders) { folder in
                            Button {
                                selectedFolder = folder
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(folder.title)
                                        .font(.headline)
                                        .tint(.primary)
                                    Text("^[\(folder.vocabularies.count) words](inflect: true)")
                                        .font(.subheadline)
                                        .tint(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    foldersManager.removeFolder(id: folder.id)
                                }
                                
                                Button("Edit", systemImage: "pencil") {
                                    editingFolder = folder
                                }
                                .tint(.yellow)
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No Custom Folders",
                            systemImage: "folder.fill.badge.questionmark",
                            description: Text("Create a custom folder by pressing the + button.")
                        )
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Folder", systemImage: "plus") {
                        showingNewFoldersView.toggle()
                    }
                    .matchedTransitionSource(id: "addButton", in: namespace)
                }
            }
            .refreshable {
                foldersManager.load()
            }
            .sheet(isPresented: $showingNewFoldersView) {
                NewEditFoldersView()
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.resizes)
                    .navigationTransition(.zoom(sourceID: "addButton", in: namespace))
            }
            .sheet(item: $editingFolder) { folder in
                NewEditFoldersView(folder: folder)
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.resizes)
            }
            .sheet(item: $selectedFolder) { _ in
                PracticeModeSelectionView(
                    selectedFolder: $selectedFolder,
                    selectedFolderForMCQView: $selectedFolderForMCQView,
                    selectedFolderForFlashcardsView: $selectedFolderForFlashcardsView,
                    selectedFolderForSpellingView: $selectedFolderForSpellingView,
                    selectedFolderForMemoryCardView: $selectedFolderForMemoryCardView
                )
                .presentationDetents([.medium])
            }
            .navigationDestination(item: $selectedFolderForMCQView) { folder in
                MCQView(parentName: folder.title, vocabularies: folder.vocabularies)
            }
            .navigationDestination(item: $selectedFolderForFlashcardsView) { folder in
                FlashcardsView(parentName: folder.title, vocabularies: folder.vocabularies, folder: folder)
            }
            .navigationDestination(item: $selectedFolderForSpellingView) { folder in
                SpellingView(parentName: folder.title, vocabularies: folder.vocabularies)
            }
            .navigationDestination(item: $selectedFolderForMemoryCardView) { folder in
                MemoryCardView(parentName: folder.title, vocabularies: folder.vocabularies)
            }
        }
    }
}
