//
//  AppInfoView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Xuemi helps secondary school students practise Chinese anytime, anywhere, with tools for revision, writing, notes and progress tracking.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                VStack(spacing: 14) {
                    AboutFeatureCard(
                        icon: "book.fill",
                        title: "Sec 1–4 Content",
                        description: "Access Chinese vocabulary and revision materials across secondary levels."
                    )

                    AboutFeatureCard(
                        icon: "checkmark.circle.fill",
                        title: "Quizzes & Practice",
                        description: "Test your understanding with MCQ and memory card activities."
                    )

                    AboutFeatureCard(
                        icon: "pencil.and.scribble",
                        title: "Writing Support",
                        description: "Practise Chinese character writing and build confidence."
                    )

                    AboutFeatureCard(
                        icon: "folder.fill",
                        title: "Custom Folders",
                        description: "Save selected words into folders for personalised revision."
                    )

                    AboutFeatureCard(
                        icon: "note.text",
                        title: "Smart Notes",
                        description: "Keep notes and review your learning results in one place."
                    )
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("About Xuemi")
    }
}

#Preview {
    AppInfoView()
}
