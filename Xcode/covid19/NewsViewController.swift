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
    // UI
    private var collectionView: UICollectionView?

    private let refreshControl = UIRefreshControl()

    // Data
    private let apiKey = "8815d577462a4195a64f6f50af3ada08"
    private var articles: [Article] = []

    init(tab: Tab) {
        super.init(nibName: nil, bundle:nil)

        title = tab.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configure()
        getData()
    }

    private func setup() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView?.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.cellId)
        collectionView?.backgroundColor = .white

        collectionView?.dataSource = self
        collectionView?.delegate = self

        refreshControl.addTarget(self, action: #selector(getData), for: UIControl.Event.valueChanged)
    }

    private func configure() {
        // Collection view
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let cv = collectionView {
            view.addSubview(cv)
        }

        // Refresh control
        collectionView?.addSubview(refreshControl)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let inset: CGFloat = 15
        let sideInset: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: sideInset, bottom: 0, trailing: sideInset)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    @objc private func getData() {        
        get("https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)&category=health") { articles in
            self.articles = articles

            self.collectionView?.reloadData()

            self.refreshControl.endRefreshing()
        }
    }

    private func get(_ urlString: String, completion: @escaping ([Article]) -> Void) {
        guard let url = URL.init(string: urlString) else {
            print("get url error")
            return
        }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {

                print(error)
                return
            }

            guard let unwrapped = data else {
                print("error unwrapping data")

                return
            }

            if let result = try? JSONDecoder().decode(Headline.self, from: unwrapped) {
                DispatchQueue.main.async {
                    completion(result.articles)
                }
            }
        }

        task.resume()
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
