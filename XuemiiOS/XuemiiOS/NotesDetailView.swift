//
//  NotesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct NotesDetailView: View {
    
    @Binding var note: Note
    
    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            ScrollView {
                TextField("Type something...", text: $note.content, axis: .vertical)
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
    }
}
