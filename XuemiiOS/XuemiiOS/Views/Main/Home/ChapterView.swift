//
//  ChapterView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 18/6/26.
//

import SwiftUI

struct ChapterView: View {
    @Environment(VocabularyManager.self) private var vocabManager
    let level: String
    
    var body: some View {
        ScrollView {
            Text("\(level)")
                .font(.largeTitle).bold()
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customBlue)
                .mask(RoundedRectangle(cornerRadius: 24))
                .padding([.horizontal, .bottom])
            
            VStack(spacing: 12) {
                ForEach(vocabManager.chapters(for: level), id: \.self) { chapter in
                    NavigationLink(destination: TopicView(level: level, chapter: chapter)) {
                        Text(chapter)
                            .font(.title)
                            .padding()
                            .frame(height: 65)
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                            .background(Color(.secondarySystemBackground))
                            .mask(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                    }
                }
                if level != "中四" {
                    NavigationLink(destination: MCQView(parentName: "\(level) • 年终考试", vocabularies: vocabManager.vocabularies(for: level), numberOfQuestions: 15)) {
                        Text("年终考试")
                            .font(.title)
                            .padding()
                            .frame(height: 65)
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                            .background(Color(.secondarySystemBackground))
                            .mask(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    ChapterView(level: "67")
}
