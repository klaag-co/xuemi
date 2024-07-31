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
            Spacer()
            
            if Double(correctAnswers) / Double(totalQuestions) < 0.7 {
                Text("继续努力！💪")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            
            if Double(correctAnswers) / Double(totalQuestions) >= 0.7 {
                Text("好棒喔！👏")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.mint)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            
            Spacer()
            
            Text("答对了\(correctAnswers)题")
                .font(.largeTitle)
                .foregroundStyle(.green)
                .padding(5)
            Text("答错了\(wrongAnswers)题")
                .font(.largeTitle)
                .foregroundStyle(.red)
                .padding(5)
            
            Spacer()
            
            Text("你的总数是\(correctAnswers)/\(totalQuestions)")
                .font(.title)
                .padding(5)
            
            Button("Home") {
                PathManager.global.popToRoot()
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle)
            .padding(.vertical)
            
            Spacer()
        }
        .onDisappear {
            NotesManager.shared.addResult(
                level: level,
                chapter: chapter,
                topic: topic,
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                totalQuestions: totalQuestions
            )
        }
    }
}
