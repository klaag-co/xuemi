//
//  TopicView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

enum Topic: Identifiable, Codable, CaseIterable {
    case one, two, three
    
    var id: UUID {
        switch self {
        case .one, .two, .three:
            return UUID()
        }
    }
    
    var string: String {
        switch self {
        case .one:
            return "Topic 1"
        case .two:
            return "Topic 2"
        case .three:
            return "Topic 3"
        }
    }
}

struct TopicView: View {
    var level: SecondaryNumber
    var chapter: Chapter
    
    @State private var showingSheet = false
    @State private var showingFlashcards = false
    @State private var topicSelected: Topic?
    
    var body: some View {
        ScrollView {
            Text("中 \(level.string)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customblue)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .bottom])
            
            ForEach(Topic.allCases, id: \.self) { topic in
                Button {
                    showingSheet = true
                    topicSelected = topic
                } label: {
                    VStack(alignment: .leading) {
                        Text(topic.string)
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
                .navigationTitle(chapter.string)
                .sheet(isPresented: $showingSheet) {
                    if let topicSelected = topicSelected {
                        NavigationStack {
                            VStack {
                                Button {
                                    // Handwriting action
                                } label: {
                                    Text("Handwriting")
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
                                    // MCQ action
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
                                    showingSheet = false
                                    showingFlashcards.toggle()
                                } label: {
                                    Text("Flashcards")
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
                            .navigationTitle(topicSelected.string)
                        }
                        .presentationDetents([.medium])
                        .padding(.top, -30)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showingFlashcards) {
            if let topicSelected = topicSelected {
                FlashcardView(vocabularies: loadVocabulariesFromJSON(fileName: "中\(level.string)", chapter: chapter.string, topic: topicSelected.string), level: level, chapter: chapter, topic: topicSelected)
            }
        }
    }
}

#Preview {
    TopicView(level: .one, chapter: .one)
}
