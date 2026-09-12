//
//  FolderRowItem.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI

struct FolderRowItem: View {
    
    @State var vocabulary: Vocabulary
    @State var folder: Folder
    
    @State var isLoading = false
    
    @Environment(FoldersManager.self) private var foldersManager
    
    var body: some View {
        Button {
            if !folder.vocabularies.contains(vocabulary) {
                Task {
                    withAnimation {
                        isLoading = true
                        folder.vocabularies.append(vocabulary)
                    }
                    await foldersManager.addToFolder(vocabulary: vocabulary, folder: folder)
                    withAnimation {
                        isLoading = false
                    }
                }
            } else {
                Task {
                    withAnimation {
                        isLoading = true
                        folder.vocabularies.removeAll(where: { $0 == vocabulary })
                    }
                    await foldersManager.removeFromFolder(vocabulary: vocabulary, folder: folder)
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(folder.title)
                        .font(.headline)
                        .tint(.primary)
                    Text("^[\(folder.vocabularies.count) words](inflect: true)")
                        .font(.subheadline)
                        .tint(.secondary)
                        .contentTransition(.numericText())
                }
                Spacer()
                if !isLoading {
                    Image(systemName: folder.vocabularies.contains(vocabulary) ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundStyle(folder.vocabularies.contains(vocabulary) ? .white : .accent, .accent)
                } else {
                    ProgressView()
                }
            }
        }
    }
}
