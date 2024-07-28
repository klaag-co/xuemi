//
//  MCQResultsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/7/24.
//

import SwiftUI

struct MCQResultsView: View {
    let correctAnswers: Int
    let wrongAnswers: Int
    let totalQuestions: Int
    let level: String
    let chapter: String
    let topic: String
    
    var body: some View {
        VStack {
            Text("Quiz Results")
                .font(.largeTitle)
                .padding()
            
            ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(correctAnswers) / Double(totalQuestions), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: correctAnswers)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(wrongAnswers) / Double(totalQuestions), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.red)
                .rotationEffect(Angle(degrees: 270.0))
                .offset(x: 0, y: 0)
                .animation(.linear, value: wrongAnswers)
                .frame(width: 200, height: 200)
                
                VStack {
                    Text("Correct: \(correctAnswers)")
                    Text("Wrong: \(wrongAnswers)")
                    Text("Total: \(totalQuestions)")
                }
            }
            .frame(width: 200, height: 200)
            
            Spacer()
        }
        .onDisappear {
            NotesManager.shared.addResult(level: level, chapter: chapter, topic: topic, correctAnswers: correctAnswers, wrongAnswers: wrongAnswers, totalQuestions: totalQuestions)
        }
    }
}
