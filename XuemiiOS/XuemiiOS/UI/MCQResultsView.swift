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
    let level: String?
    let chapter: String?
    let topic: String?
    let folderName: String?

    let dismissCallback: () -> ()

    @Environment(\.dismiss) private var dismiss

    init(
        correctAnswers: Int,
        wrongAnswers: Int,
        totalQuestions: Int,
        level: String,
        chapter: String,
        topic: String
    ) {
        self.correctAnswers = correctAnswers
        self.wrongAnswers = wrongAnswers
        self.totalQuestions = totalQuestions
        self.level = level
        self.chapter = chapter
        self.topic = topic
        self.folderName = nil
        self.dismissCallback = {}
    }

    init(
        correctAnswers: Int,
        wrongAnswers: Int,
        totalQuestions: Int,
        folderName: String,
        dismissCallback: @escaping () -> ()
    ) {
        self.correctAnswers = correctAnswers
        self.wrongAnswers = wrongAnswers
        self.totalQuestions = totalQuestions
        self.level = nil
        self.chapter = nil
        self.topic = nil
        self.folderName = folderName
        self.dismissCallback = dismissCallback
    }

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
            
            Text("总分是\(correctAnswers)/\(totalQuestions)")
                .font(.title)
                .padding(5)
            
            Button("Home") {

                if let level, let chapter, let topic {
                    NotesManager.shared.addResult(
                        level: level,
                        chapter: chapter,
                        topic: topic,
                        correctAnswers: correctAnswers,
                        wrongAnswers: wrongAnswers,
                        totalQuestions: totalQuestions
                    )
                } else if let folderName {
                    NotesManager.shared.addResult(
                        folderName: folderName,
                        correctAnswers: correctAnswers,
                        wrongAnswers: wrongAnswers,
                        totalQuestions: totalQuestions
                    )
                }

                if folderName != nil {
                    dismiss()
                    dismissCallback()
                } else {
                    PathManager.global.popToRoot()
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle)
            .padding(.vertical)
            
            Spacer()
        }
    }
}
