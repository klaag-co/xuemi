//
//  VocabularyListView.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI

struct VocabularyListView<TopSection: View>: View {
    
    let topSection: (() -> TopSection)?
    @Binding var selectedVocabs: [Vocabulary]?
    
    @State private var searchText = ""
    @Environment(VocabularyManager.self) private var vocabManager
    @Environment(SettingsManager.self) private var settingsManager
    
    init(
        selectedVocabs: Binding<[Vocabulary]?>? = nil,
        searchText: String = "",
        @ViewBuilder topSection: @escaping () -> TopSection = { EmptyView() }
    ) where TopSection == EmptyView {
        self._selectedVocabs = selectedVocabs ?? .constant(nil)
        self.topSection = nil
        self.searchText = searchText
    }
    
    init(
        selectedVocabs: Binding<[Vocabulary]?>? = nil,
        searchText: String = "",
        @ViewBuilder topSection: @escaping () -> TopSection
    ) {
        self._selectedVocabs = selectedVocabs ?? .constant(nil)
        self.topSection = topSection
        self.searchText = searchText
    }
    
    var filteredVocabs: [Vocabulary] {
        let vocabs = vocabManager.allVocabularies.filter { $0.chineseLevel == settingsManager.chineseLevel }
        if searchText.isEmpty {
            return vocabs
        } else {
            return vocabs.filter({ $0.word.localizedCaseInsensitiveContains(searchText) || $0.pinyin.localizedCaseInsensitiveContains(searchText) })
        }
    }
    
    var body: some View {
        List {
            if let topSection {
                topSection()
            }
            ForEach(vocabManager.levels, id: \.self) { level in
                let vocabsForLevel = filteredVocabs.filter({ $0.level == level })
                if !vocabsForLevel.isEmpty {
                    Section(level) {
                        ForEach(vocabsForLevel) { vocab in
                            if let selectedVocabs {
                                Button {
                                    withAnimation {
                                        if selectedVocabs.contains(vocab) {
                                            self.selectedVocabs?.removeAll(where: { $0 == vocab })
                                        } else {
                                            self.selectedVocabs?.append(vocab)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(vocab.word)
                                                .font(.headline)
                                                .tint(.primary)
                                            Text("\(vocab.chapterName) • \(vocab.topicName)")
                                                .font(.subheadline)
                                                .tint(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: selectedVocabs.contains(vocab) ? "checkmark.circle.fill" : "checkmark.circle")
                                            .font(.title2)
                                            .foregroundStyle(selectedVocabs.contains(vocab) ? .white : .accent, .accent)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text(vocab.word)
                                        .font(.headline)
                                    Text("\(vocab.chapterName) • \(vocab.topicName)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search by word or pinyin"))
    }
}

#Preview {
    VocabularyListView()
}
