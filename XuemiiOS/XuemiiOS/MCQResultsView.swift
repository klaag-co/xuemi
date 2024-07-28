//
//  MCQResultsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/7/24.
//

import SwiftUI

struct MCQResultsView: View {
    var correctAnswers: Int
    var wrongAnswers: Int
    var totalQuestions: Int
    var level: String
    var chapter: String
    var topic: String
    
    var body: some View {
        VStack {
            Text("测验结果")
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
                    Text("正确: \(correctAnswers)")
                        .font(.title)
                    Text("错误: \(wrongAnswers)")
                        .font(.title)
                    Text("总数: \(totalQuestions)")
                        .font(.title)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("等级: \(level)")
                    .font(.title2)
                
                Text("章节: \(chapter)")
                    .font(.title2)
                
                Text("话题: \(topic)")
                    .font(.title2)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("结果")
        .padding()
    }
}

#Preview {
    MCQResultsView(
        correctAnswers: 7,
        wrongAnswers: 3,
        totalQuestions: 10,
        level: "中一",
        chapter: "第一章",
        topic: "词语"
    )
}
