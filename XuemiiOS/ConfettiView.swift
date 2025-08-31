import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    let emojis: [String] = ["🎉","🎊","✨","⭐️","🎈","🔥","✅"]
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 2)

        var cells: [CAEmitterCell] = []
        for _ in 0..<6 {
            let cell = CAEmitterCell()
            cell.birthRate = 4
            cell.lifetime = 6
            cell.velocity = 180
            cell.velocityRange = 80
            cell.emissionLongitude = .pi
            cell.spin = 3.5
            cell.spinRange = 4
            cell.scale = 0.8
            cell.scaleRange = 0.4

            let label = UILabel()
            label.text = emojis.randomElement()
            label.font = .systemFont(ofSize: 28)
            label.textAlignment = .center
            label.backgroundColor = .clear
            let size = CGSize(width: 36, height: 36)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            label.frame = CGRect(origin: .zero, size: size)
            label.layer.render(in: UIGraphicsGetCurrentContext()!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            cell.contents = img?.cgImage
            cells.append(cell)
        }
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.birthRate = 0
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

