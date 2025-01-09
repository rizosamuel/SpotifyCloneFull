//
//  AuthViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, FileIdentifier {
    
    private let webview: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        config.defaultWebpagePreferences = prefs
        let webview = WKWebView(frame: .zero, configuration: config)
        return webview
    }()
    
    var isAsync: Bool = false
    var completion: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .label
        
        guard let url = AuthManager.shared.signInURL else { return }
        
        view.addSubview(webview)
        constrainWebview()
        webview.backgroundColor = .label
        webview.navigationDelegate = self
        webview.load(URLRequest(url: url))
        print("\n[\(fileName)] SIGNING IN TO SPOTIFY...")
    }
    
    private func constrainWebview() {
        webview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        // Exchange the code for an access token
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        
        print("\n[\(fileName)] SIGN IN APPROVED WITH CODE:", code)
        exchangeCodeForToken(code: code)
    }
    
    private func exchangeCodeForToken(code: String) {
        switch isAsync {
        case true:
            Task { [weak self] in
                do {
                    let success = try await AuthManager.shared.exchangeCodeForToken(code: code)
                    self?.handleTokenResult(with: success)
                } catch {
                    guard let self else { return }
                    print("[\(self.fileName)] FAILED TO EXCHANGE CODE FOR TOKEN:", error)
                }
            }
        case false:
            AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
                self?.handleTokenResult(with: success)
            }
        }
    }
    
    private func handleTokenResult(with success: Bool) {
        DispatchQueue.main.async {
            self.completion?(success)
        }
    }
}
