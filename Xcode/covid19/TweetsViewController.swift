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

class TweetsViewController: UIViewController, WKNavigationDelegate {
    private let webView = WKWebView()

    private let refreshControl = UIRefreshControl()

    var user = ""
    var webContent = ""

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(tab: Tab) {
        super.init(nibName: nil, bundle:nil)

        view.backgroundColor = .white

        title = tab.name

        guard let tuser = tab.twitterUser else {
            return
        }

        webContent = """
        <meta name='viewport' content='initial-scale=1.0'/>
        <a class="twitter-timeline" href="https://twitter.com/\(tuser)"></a>
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
        """

        user = tuser

        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        webView.navigationDelegate = self

        refreshWebView(refreshControl)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func refreshWebView(_ sender: UIRefreshControl) {
        webView.loadHTMLString(webContent, baseURL: nil)
        sender.endRefreshing()
    }

    /// Credits: https://medium.com/@musmein/rendering-embedded-tweets-and-timelines-within-webview-in-ios-e48920754add
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      if navigationAction.navigationType == .linkActivated  {
        if let url = navigationAction.request.url {
            let sfvc = SFSafariViewController.init(url: url)
            self.present(sfvc, animated: true, completion: nil)

//          print(url)
//          print("Redirected to browser. No need to open it locally")
          decisionHandler(.cancel)
        } else {
//          print("Open it locally")
          decisionHandler(.allow)
          }
      } else {
//          print("not a user click")
          decisionHandler(.allow)
         }
    }
}
