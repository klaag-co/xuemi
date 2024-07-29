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
            if Double(wrongAnswers) / Double(totalQuestions) >= 0.5 {
                Text("继续努力！💪")
                    .font(.largeTitle)
                    .padding()
            }
            
            if Double(wrongAnswers) / Double(totalQuestions) < 0.5 {
                Text("好棒喔！👏")
                    .font(.largeTitle)
                    .padding()
            }
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 200)
                
                if Double(wrongAnswers) / Double(totalQuestions) < 0.5 {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(Double(correctAnswers) / Double(totalQuestions), 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.green)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: correctAnswers)
                        .frame(width: 200, height: 200)
                }
                
                if Double(wrongAnswers) / Double(totalQuestions) >= 0.5 {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(Double(correctAnswers) / Double(totalQuestions), 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.red)
                        .rotationEffect(Angle(degrees: 270.0))
                        .offset(x: 0, y: 0)
                        .animation(.linear, value: wrongAnswers)
                        .frame(width: 200, height: 200)
                }
            }
            .frame(width: 200, height: 200)
            .padding(20)
            
            Text("你答对了\(correctAnswers)个问题")
                .font(.title)
                .foregroundStyle(.green)
                .padding(5)
            Text("你答错了\(wrongAnswers)个问题")
                .font(.title)
                .foregroundStyle(.red)
                .padding(5)
            Text("你的总数是\(correctAnswers)/\(totalQuestions)")
                .font(.title)
                .padding(5)
            
            Button("Home") {
                PathManager.global.popToRoot()
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle)
            
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
