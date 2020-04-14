//
//  WebViewController.swift
//  covid19
//
//  Created by Daniel on 4/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    // UI
    private var webview = WKWebView()
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var websites = [
        Website(domain: "viruscovid.tech", urlString: "https://viruscovid.tech"),
        Website(domain: "ncov2019.live", urlString: "https://ncov2019.live")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configure()
        loadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if webview.estimatedProgress == 1 {
                spinner.stopAnimating()
            }
        }
    }
}

private extension WebViewController {
    func loadWebsite(_ website: Website) {
        guard let url = URL(string: website.urlString) else { return }
        spinner.startAnimating()
        
        webview.evaluateJavaScript("document.body.remove()")
        
        let r = URLRequest(url: url)
        webview.load(r)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setup() {
        title = Constant.web.name
        
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func configure() {
        // Web view
        view = webview
        
        // Filter button
        let image = UIImage(systemName: "list.dash")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(filter))
        navigationItem.rightBarButtonItem = button
        
        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func filter() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for w in websites {
            let action = UIAlertAction(title: w.domain , style: .default, handler: openWebsite)
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openWebsite(_ action: UIAlertAction) {
        let items = websites.filter { $0.domain == action.title }
        if let w: Website = items.first {
            loadWebsite(w)
        }
    }
    
    func loadData() {
        if let w = websites.first {
            loadWebsite(w)
        }
    }
}

private struct Website {
    var domain: String
    var urlString: String
}
