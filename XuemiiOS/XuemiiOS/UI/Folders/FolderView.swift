import SwiftUI

struct Folder: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let vocabs: [Vocabulary]
}

struct FolderView: View {
    @ObservedObject var vocabManager: VocabManager
    @ObservedObject private var pathManager = PathManager.global
    
    @State private var selectedFolder: Folder?
    @State private var selectedFolderForMCQView: Folder?
    @State private var selectedFolderForSpeakerView: Folder?
    @State private var selectedFolderForContentsView: Folder?
    
    var body: some View {
        NavigationStack(path: $pathManager.folderPath) {
            List {
                Section(header: Text("Fixed Folders")) {
                    NavigationLink(destination: VocabView(vocabManager: vocabManager)) {
                        Text("Vocabulary List")
                            .font(.headline)
                    }
                    
                    NavigationLink(destination: BookmarkView()) {
                        Text("Bookmarks")
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Custom Folders")) {
                    if vocabManager.folders.isEmpty {
                        Text("No custom folders yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(vocabManager.folders) { folder in
                            Button {
                                selectedFolder = folder
                            } label: {
                                Text(folder.name)
                                    .foregroundStyle(.black)
                            }
                        }
                        .onDelete { indexSet in
                            vocabManager.folders.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .sheet(item: $selectedFolder) { folder in
                NavigationStack {
                    VStack(spacing: 16) {
                        Button {
                            selectedFolder = nil
                            selectedFolderForMCQView = folder
                        } label: {
                            Text("MCQ")
                                .font(.title)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(.customgray)
                                .mask(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                        
                        Button {
                            selectedFolder = nil
                            selectedFolderForSpeakerView = folder
                        } label: {
                            Text("Spelling")
                                .font(.title)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(.customgray)
                                .mask(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                        
                        Button {
                            selectedFolder = nil
                            selectedFolderForContentsView = folder
                        } label: {
                            Text("Contents")
                                .font(.title)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(.customgray)
                                .mask(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                    }
                    .navigationTitle("习题")
                }
                .presentationDetents([.medium])
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Folders")
            
            .navigationDestination(item: $selectedFolderForSpeakerView) { folder in
                SpeakerView(
                    words: folder.vocabs,
                    folderName: folder.name,
                    onBackToFolders: {
                        selectedFolderForSpeakerView = nil
                    }
                )
            }
            
            .navigationDestination(item: $selectedFolderForMCQView) { folder in
                MCQView(
                    vocabularies: folder.vocabs,
                    folderName: folder.name,
                    onBackToFolders: {
                        selectedFolderForMCQView = nil
                    }
                )
            }
            
            .navigationDestination(item: $selectedFolderForContentsView) { folder in
                FlashcardView(
                    vocabularies: folder.vocabs,
                    folderName: folder.name,
                    currentIndex: 0
                )
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
        }
    }
}
