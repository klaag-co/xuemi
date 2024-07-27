//
//  CanvasView.swift
//  XuemiiOS
//
//  Created by Kmy Er on 27/7/24.
//
import UIKit
import WebKit

// TODO: Implement WKUIDelegate.
class CanvasController: UIViewController, UISearchBarDelegate {
    
    var text: String = "水"
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = .init()
        webView!.frame = .init(x: 0, y: 0, width: 50, height: 50)
        self.view = webView
        // Do any additional setup after loading the view.
        
        // loading an html file from local resources
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView!.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            // deletingLastPathComponent() allows WebKit to read from directory of index.html
        }
        webView!.navigationDelegate = self
    }
    
    func setCharacter(to character: String) {
        print("Setting character!")
        text = character
        if let webView {
            webView.evaluateJavaScript("changeCharacter('\(character)')") { (result, error) in
                if error == nil {
                    // success, do nothing...
                }
            }
        }
    }
}

extension CanvasController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Nav finished")
        self.setCharacter(to: self.text)
    }
}
