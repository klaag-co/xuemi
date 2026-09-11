//
//  OLevelsMenuView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI

struct OLevelsMenuView: View {
    @Environment(VocabularyManager.self) private var vocabManager
    
    var body: some View {
        ScrollView {
            VStack {
                NavigationLink {
                    MCQView(
                        parentName: "End-Of-Year Practice",
                        vocabularies: vocabManager.allVocabularies,
                        numberOfQuestions: 20
                    )
                } label: {
                    VStack(alignment: .leading) {
                        Text("End-Of-Year Practice")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("全面终考练习，检验一整年的学习成果。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .mask(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding([.top, .horizontal])
        }
        .navigationTitle("O 水准备考")
    }
}

#Preview {
    OLevelsMenuView()
}
