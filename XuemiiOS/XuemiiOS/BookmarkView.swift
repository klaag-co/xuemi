//
//  FavouritesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct BookmarkView: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String
        var children: [FileItem]? = nil
        var description: String {
            switch children {
            case nil:
                return "\(name)"
            case .some(let children):
                return children.isEmpty ? "\(name)" : "\(name)"
            }
        }
    }

    @State private var searchText = ""
    
    let fileHierarchyData: [FileItem] = [
        FileItem(name: "中一", children: [
            FileItem(name: "Random Word 1"),
            FileItem(name: "Random Word 2"),
            FileItem(name: "Random Word 3"),
        ]),
        FileItem(name: "中二", children: [
            FileItem(name: "Random Word 4"),
            FileItem(name: "Random Word 5"),
        ])
    ]
    
    var body: some View {
        NavigationStack {
            List(fileHierarchyData, children: \.children) { item in
                Text(item.description)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Bookmarks")
        }
    }
}

#Preview {
    BookmarkView()
}
