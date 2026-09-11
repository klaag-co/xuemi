//
//  CanvasController.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import UIKit
import WebKit

class CanvasController: UIViewController, UISearchBarDelegate {
    
    var text: String = "水"
    var isDarkMode: Bool = false
    var webView: WKWebView?
    private var pageLoaded = false
    private var appliedCharacter: String?
    private var appliedDarkMode: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let webView = WKWebView()
        webView.frame = .init(x: 0, y: 0, width: 50, height: 50)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.underPageBackgroundColor = .clear
        self.webView = webView
        self.view = webView
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        webView.navigationDelegate = self
    }
    
    func setCharacter(to character: String) {
        text = character
        guard pageLoaded, let webView, appliedCharacter != character else { return }
        appliedCharacter = character
        let script = "initializeWriter(\(Self.jsString(character)))"
        webView.evaluateJavaScript(script)
    }
    
    func setDarkMode(_ dark: Bool) {
        isDarkMode = dark
        guard pageLoaded, let webView, appliedDarkMode != dark else { return }
        appliedDarkMode = dark
        webView.evaluateJavaScript("setDarkMode(\(dark))")
    }
    
    private func applyAppearance() {
        appliedDarkMode = nil
        setDarkMode(isDarkMode)
    }
    
    private static func jsString(_ value: String) -> String {
        guard let data = try? JSONEncoder().encode(value),
              let encoded = String(data: data, encoding: .utf8) else {
            return "\"\""
        }
        return encoded
    }
}

extension CanvasController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoaded = true
        appliedCharacter = nil
        webView.evaluateJavaScript("document.body.style.background = 'transparent';")
        applyAppearance()
        setCharacter(to: text)
    }
}
