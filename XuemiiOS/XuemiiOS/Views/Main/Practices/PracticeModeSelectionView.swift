//
//  PracticeModeSelectionView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import SwiftUI

struct PracticeModeSelectionView: View {
    
    @Binding var selectedFolder: Folder?
    @Binding var selectedFolderForMCQView: Folder?
    @Binding var selectedFolderForFlashcardsView: Folder?
    @Binding var selectedFolderForSpellingView: Folder?
    @Binding var selectedFolderForMemoryCardView: Folder?
    
    @Binding var selectedTopic: Topic?
    @Binding var selectedTopicForMCQView: Topic?
    @Binding var selectedTopicForFlashcardsView: Topic?
    @Binding var selectedTopicForSpellingView: Topic?
    @Binding var selectedTopicForMemoryCardView: Topic?
    
    init(
        selectedFolder: Binding<Folder?>,
        selectedFolderForMCQView: Binding<Folder?>,
        selectedFolderForFlashcardsView: Binding<Folder?>,
        selectedFolderForSpellingView: Binding<Folder?>,
        selectedFolderForMemoryCardView: Binding<Folder?>
    ) {
        self._selectedFolder = selectedFolder
        self._selectedFolderForMCQView = selectedFolderForMCQView
        self._selectedFolderForFlashcardsView = selectedFolderForFlashcardsView
        self._selectedFolderForSpellingView = selectedFolderForSpellingView
        self._selectedFolderForMemoryCardView = selectedFolderForMemoryCardView
        
        self._selectedTopic = .constant(nil)
        self._selectedTopicForMCQView = .constant(nil)
        self._selectedTopicForFlashcardsView = .constant(nil)
        self._selectedTopicForSpellingView = .constant(nil)
        self._selectedTopicForMemoryCardView = .constant(nil)
    }
    
    init(
        selectedTopic: Binding<Topic?>,
        selectedTopicForMCQView: Binding<Topic?>,
        selectedTopicForFlashcardsView: Binding<Topic?>,
        selectedTopicForSpellingView: Binding<Topic?>,
        selectedTopicForMemoryCardView: Binding<Topic?>
    ) {
        self._selectedTopic = selectedTopic
        self._selectedTopicForMCQView = selectedTopicForMCQView
        self._selectedTopicForFlashcardsView = selectedTopicForFlashcardsView
        self._selectedTopicForSpellingView = selectedTopicForSpellingView
        self._selectedTopicForMemoryCardView = selectedTopicForMemoryCardView
        
        self._selectedFolder = .constant(nil)
        self._selectedFolderForMCQView = .constant(nil)
        self._selectedFolderForFlashcardsView = .constant(nil)
        self._selectedFolderForSpellingView = .constant(nil)
        self._selectedFolderForMemoryCardView = .constant(nil)
    }
    
    var body: some View {
        NavigationStack {
            CustomGlassEffectContainer {
                button(text: "MCQ") {
                    if let selectedFolder {
                        selectedFolderForMCQView = selectedFolder
                        self.selectedFolder = nil
                    } else if let selectedTopic {
                        selectedTopicForMCQView = selectedTopic
                        self.selectedTopic = nil
                    }
                }
                
                button(text: "Flashcards") {
                    if let selectedFolder {
                        selectedFolderForFlashcardsView = selectedFolder
                        self.selectedFolder = nil
                    } else if let selectedTopic {
                        selectedTopicForFlashcardsView = selectedTopic
                        self.selectedTopic = nil
                    }
                }
                
                button(text: "Spelling") {
                    if let selectedFolder {
                        selectedFolderForSpellingView = selectedFolder
                        self.selectedFolder = nil
                    } else if let selectedTopic {
                        selectedTopicForSpellingView = selectedTopic
                        self.selectedTopic = nil
                    }
                }
                
                button(text: "Memory Cards") {
                    if let selectedFolder {
                        selectedFolderForMemoryCardView = selectedFolder
                        self.selectedFolder = nil
                    } else if let selectedTopic {
                        selectedTopicForMemoryCardView = selectedTopic
                        self.selectedTopic = nil
                    }
                }
            }
            .padding()
            .navigationTitle("习题")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
    
    @ViewBuilder
    func button(text: String, action: @escaping () -> ()) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    action()
                } label: {
                    Text(text)
                        .padding(8)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            } else {
                Button {
                    action()
                } label: {
                    Text(text)
                        .padding()
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(.secondary)
                        .mask(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
