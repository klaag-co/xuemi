//
//  SOneChapterView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/5/24.
//

import SwiftUI

struct ChapterView: View {
    
    var level: SecondaryNumber
    
    var body: some View {
        List {
            ForEach(level.chapters, id: \.hashValue) { chapter in
                Text(chapter)
            }
        } 
        .navigationTitle("Secondary \(level.string)")
    }
}
#Preview {
    ChapterView(level: .three)
}
