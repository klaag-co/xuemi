//
//  CanvasView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import SwiftUI

struct CanvasView: UIViewControllerRepresentable {
    var character: String
    @Environment(\.colorScheme) private var colorScheme
    
    func makeUIViewController(context: Context) -> CanvasController {
        let controller = CanvasController(nibName: nil, bundle: nil)
        controller.isDarkMode = colorScheme == .dark
        controller.setCharacter(to: character)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CanvasController, context: Context) {
        let isDark = colorScheme == .dark
        if uiViewController.isDarkMode != isDark {
            uiViewController.isDarkMode = isDark
            uiViewController.setDarkMode(isDark)
        }
        uiViewController.setCharacter(to: character)
    }
    
    typealias UIViewControllerType = CanvasController
}

#Preview {
    CanvasView(character: "我")
        .frame(width: 315, height: 315)
        .border(.black, width: 3)
}
