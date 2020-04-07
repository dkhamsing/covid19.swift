//
//  DataViewController.swift
//  covid19
//
//  Created by Daniel on 4/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    // Constants
    private let trackerApiStringUrl = "https://coronavirus-tracker-api.herokuapp.com/v2/locations?timelines=1"

    static let sectionHeaderElementKind = "section-header-element-kind"

    // UI
    private var collectionView: UICollectionView?

    private var spinner = UIActivityIndicatorView.init(style: .medium)

    // Data
    private var countries: [Country] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configure()
        loadData()
    }

    private func configure() {
        // Collection view
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let cv = collectionView {
            view.addSubview(cv)
        }

        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setup() {
        title = Constant.data.name
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
        collectionView?.register(DataView.self, forSupplementaryViewOfKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.viewId)
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
    }

    private func loadData() {
        spinner.startAnimating()
        getData(trackerApiStringUrl) { r in
            self.countries = r.locations.sorted(by: { $0.latest.confirmed > $1.latest.confirmed })
            self.collectionView?.reloadData()
            self.spinner.stopAnimating()
        }
    }

    private func getData(_ urlString: String, completion: @escaping (Response) -> Void) {
        guard let url = URL.init(string: urlString) else {
            print("error with url")
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

            if let result = try? JSONDecoder().decode(Response.self, from: unwrapped) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            else {
                print("could not decode json")
            }
        }

        task.resume()
    }
}

extension DataViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(10),
                                               heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(150))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: DataViewController.sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

extension DataViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.viewId, for: indexPath) as! DataView

        let country = self.countries[indexPath.section]
        cell.dateLabel.text = country.country
        cell.label.attributedText = country.confirmedAttributedText()

        return cell
    }
}

class DataView: UICollectionReusableView {
    static let viewId = "DataCell"

    let label = UILabel()
    let dateLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        self.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 25),
            dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        dateLabel.attributedText = nil
        label.attributedText = nil
    }
}

private extension Country {
    func confirmedAttributedText() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        let titleAttribute: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.monospacedSystemFont(ofSize: 80, weight: .regular)
        ]

        return NSMutableAttributedString.init(string: "\(latest.confirmed)", attributes: titleAttribute)
    }
}
