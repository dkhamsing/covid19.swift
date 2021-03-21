//
//  TwitterViewController.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class TwitterViewController: UIViewController {
    // UI
    private let webView = WKWebView()
    private let refreshControl = UIRefreshControl()
    
    // Data
    var users: [String] = []
    var webContent = ""

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(title: String, usernames: [String]) {
        super.init(nibName: nil, bundle:nil)

        users = usernames
        setup(aTitle: title, user: usernames.first)
        configure()
        refreshWebView(user: usernames.first)
    }
}

private extension TwitterViewController {
    func contentForUser(_ user: String?) -> String {
        guard let user = user else { return "" }

        return """
        <meta name='viewport' content='initial-scale=1.0'/>
        <a class="twitter-timeline" href="https://twitter.com/\(user)"></a>
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
        """
    }

    func setup(aTitle: String, user: String?) {
        view.backgroundColor = .white
        
        title = aTitle

        webView.navigationDelegate = self
    }
    
    func configure() {
        // Web view
        view.autolayoutAddSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true

        let buttonImage = UIImage(systemName: "ellipsis")
        let children: [UIAction] =  users.map {
            let user = $0
            let title = "@" + $0
            return UIAction(title: title) { _ in
                self.refreshWebView(user: user)
            }
        }

        let menu = UIMenu(title: "", children: children)
        let barButton = UIBarButtonItem(image: buttonImage, primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItems = [barButton]

    }

    func refreshWebView(user: String?) {
        webContent = contentForUser(user)
        webView.loadHTMLString(webContent, baseURL: nil)
    }
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView.loadHTMLString(webContent, baseURL: nil)
        sender.endRefreshing()
    }
}

extension TwitterViewController: WKNavigationDelegate {
    /// Credits: https://medium.com/@musmein/rendering-embedded-tweets-and-timelines-within-webview-in-ios-e48920754add
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url {
                let sfvc = SFSafariViewController(url: url)
                self.present(sfvc, animated: true, completion: nil)
                // Redirected to browser. No need to open it locally
                decisionHandler(.cancel)
            } else {
                // Open it locally
                decisionHandler(.allow)
            }
        } else {
            // Not a user click
            decisionHandler(.allow)
        }
    }
}
