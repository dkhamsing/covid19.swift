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
        
        // Select website button
        let image = UIImage(systemName: "ellipsis")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(selectWebsite))
        if websites.count > 1 {
            navigationItem.rightBarButtonItem = button
        }
        
        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func selectWebsite() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.fixiOSAutolayoutNegativeConstraints()

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
