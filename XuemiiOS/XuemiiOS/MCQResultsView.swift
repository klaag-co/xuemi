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
            
            Text("正确答案数量: \(correctAnswers)")
                .font(.title)
                .padding()
            
            Text("错误答案数量: \(wrongAnswers)")
                .font(.title)
                .padding()
            
            Text("总题目数量: \(totalQuestions)")
                .font(.title)
                .padding()
            
            Text("等级: \(level)")
                .font(.title)
                .padding()
            
            Text("章节: \(chapter)")
                .font(.title)
                .padding()
            
            Text("话题: \(topic)")
                .font(.title)
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
