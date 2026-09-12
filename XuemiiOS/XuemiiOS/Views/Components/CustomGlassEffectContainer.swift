//
//  CustomGlassEffectContainer.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 16/6/26.
//

import SwiftUI

struct CustomGlassEffectContainer<Content : View>: View {
    let spacing: CGFloat?
    let content: () -> Content
    
   init(
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: spacing) {
                    content()
                }
            } else {
                VStack(spacing: spacing) {
                    content()
                }
            }
        }
    }
}
