//
//  CanvasView.swift
//  XuemiiOS
//
//  Created by Kmy Er on 27/7/24.
//

import SwiftUI

struct CanvasView: UIViewControllerRepresentable {
    var character: String
    
    func makeUIViewController(context: Context) -> CanvasController {
        let controller = CanvasController(nibName: nil, bundle: nil)
        controller.setCharacter(to: character)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CanvasController, context: Context) {
        uiViewController.setCharacter(to: character)
    }
    
    typealias UIViewControllerType = CanvasController
}

#Preview {
    CanvasView(character: "我")
        .frame(width: 315, height: 315)
        .border(.black, width: 3)
}
