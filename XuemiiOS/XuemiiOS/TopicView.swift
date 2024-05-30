//
//  TopicView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

enum Topic: CaseIterable {
    case one, two, three
    
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
    
    @State var topicSelected: Topic?
    @State var showingSheet = false
    
    var body: some View {
        List {
            ForEach(Topic.allCases, id: \.hashValue) { topic in
                Button {
                    topicSelected = topic
                } label: {
                    VStack(alignment: .leading) {
                        Text(topic.string)
                        
//                        HStack {
//                            Button {
//                                
//                            } label: {
//                                Image(systemName: "hand.draw.fill")
//                                    .font(.title3)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 40)
//                                    .background(.blue)
//                                    .foregroundStyle(.white)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                            }
//                            .padding(.horizontal)
//                            
//                            Button {
//                                
//                            } label: {
//                                Image(systemName: "list.number")
//                                    .font(.title3)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 40)
//                                    .background(.blue)
//                                    .foregroundStyle(.white)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                            }
//                            .padding(.horizontal)
//                            
//                            Button {
//                                
//                            } label: {
//                                Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled.fill")
//                                    .font(.title3)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 40)
//                                    .background(.blue)
//                                    .foregroundStyle(.white)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                            }
//                            .padding(.horizontal)
//                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(chapter.string)
        .sheet(isPresented: .constant(topicSelected != nil)) {
            if let topicSelected = topicSelected {
                NavigationStack {
                    VStack {
                        // use level.getData(chapter: chapter, topic: topicSelected) to get data for each level, chapter, and topic :)
                        Button {
                            
                        } label: {
                            Text("Handwriting")
                        }
                        
                        Button {
                            
                        } label: {
                            Text("MCQ")
                        }
                        
                        Button {
                            
                        } label: {
                            Text("Flashcards")
                        }
                    }
                    .navigationTitle(topicSelected.string)
                }
                .presentationDetents([.medium])
                .onDisappear {
                    self.topicSelected = nil
                }
            }
        }
    }
}

#Preview {
    TopicView(level: .one, chapter: .one)
}
