//
//  DataViewController.swift
//  covid19
//
//  Created by Daniel on 4/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import WebKit

class DataViewController: UIViewController {
    // UI
    private var webview = WKWebView()
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    // Data
    var websites: [Website] = []

    init(_ sites: [Website]) {
        super.init(nibName: nil, bundle:nil)

        websites = sites

        setup()
        configure()
        loadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DataViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if webview.estimatedProgress == 1 {
                spinner.stopAnimating()
            }
        }
    }
}

private extension DataViewController {
    func loadWebsite(_ website: Website) {
        guard let url = URL(string: website.urlString) else { return }
        spinner.startAnimating()
        
        webview.evaluateJavaScript("document.body.remove()")
        
        let r = URLRequest(url: url)
        webview.load(r)
    }

    func setup() {
        title = Tab.web.name
        
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func configure() {
        // Web view
        view = webview
        
        // Select website button
        let buttonImage = UIImage(systemName: "ellipsis")
        let children: [UIAction] =  websites.map {
            let w = $0
            return UIAction(title: $0.domain) { _ in
                self.loadWebsite(w)
            }
        }

        let menu = UIMenu(title: "", children: children)
        let barButton = UIBarButtonItem(image: buttonImage, primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItems = [barButton]

        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func loadData() {
        if let w = websites.first {
            loadWebsite(w)
        }
    }
}
