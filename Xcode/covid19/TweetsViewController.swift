//
//  TweetsViewController.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class TweetsViewController: UIViewController {
    // UI
    private let webView = WKWebView()
    private let refreshControl = UIRefreshControl()
    
    // Data
    var user = ""
    var webContent = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(tab: Tab) {
        super.init(nibName: nil, bundle:nil)
        
        setup(tab)
        configure()
        refreshWebView(refreshControl)
    }
}

private extension TweetsViewController {
    func setup(_ tab: Tab) {
        view.backgroundColor = .white
        
        title = tab.name
        
        guard let tuser = tab.twitterUser else {
            return
        }
        
        user = tuser
        
        webContent = """
        <meta name='viewport' content='initial-scale=1.0'/>
        <a class="twitter-timeline" href="https://twitter.com/\(tuser)"></a>
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
        """
        
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
    }
    
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView.loadHTMLString(webContent, baseURL: nil)
        sender.endRefreshing()
    }
}

extension TweetsViewController: WKNavigationDelegate {
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
