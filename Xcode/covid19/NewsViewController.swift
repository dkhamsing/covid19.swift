//
//  NewsViewController.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    private var articles: [Article] = []

    private var collectionView: UICollectionView?

    private let refreshControl = UIRefreshControl()

    private var apiKey: String = ""

    init(tab: Tab, key: String) {
        super.init(nibName: nil, bundle:nil)

        title = tab.name

        apiKey = key
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView?.backgroundColor = .white
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        collectionView?.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.cellId)

        if let cv = collectionView {
            view.addSubview(cv)
        }

        collectionView?.dataSource = self
        collectionView?.delegate = self

        refresh()

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refreshControl)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let inset: CGFloat = 15
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: 0, trailing: inset)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    @objc private func refresh() {
        let api = NewsApi()
        api.get("https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)&category=health") { articles in
            self.articles = articles

            self.collectionView?.reloadData()

            self.refreshControl.endRefreshing()
        }
    }
}

extension NewsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let article = self.articles[indexPath.row]

        let c = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.cellId, for: indexPath) as! NewsCell

        c.urlString = article.urlToImage
        c.label.attributedText = article.attributedContent()
        c.dateLabel.attributedText = article.attributedDate()

        return c
    }
}

extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let article = articles[indexPath.row]

        guard let urlString = article.url, let url = URL.init(string: urlString) else {
            return
        }

        let sfvc = SFSafariViewController.init(url: url)
        self.present(sfvc, animated: true, completion: nil)
    }
}
