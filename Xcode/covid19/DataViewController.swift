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
        collectionView?.register(BarCell.self, forCellWithReuseIdentifier: BarCell.cellId)
        collectionView?.register(DataView.self, forSupplementaryViewOfKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.viewId)
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
    }

    private func loadData() {
        spinner.startAnimating()
        getData(trackerApiStringUrl) { result, error in
            self.spinner.stopAnimating()
            if let r = result {
                self.countries = r.locations.sorted(by: { $0.latest.confirmed > $1.latest.confirmed })
                self.collectionView?.reloadData()

            }
            if let e = error {
                let alertvc = UIAlertController.init(title: nil, message: e.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alertvc.addAction(action)
                self.present(alertvc, animated: true, completion: nil)
            }
        }
    }

    private func getData(_ urlString: String, completion: @escaping (Response?, Error?) -> Void) {
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
                    completion(result, nil)
                }
            }
            else {
                print("could not decode json")
                let e: ApiError = .generic
                DispatchQueue.main.async {
                    completion(nil, e)
                }
            }
        }

        task.resume()
    }
}

enum ApiError: Error {
    case generic
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .generic:
            return NSLocalizedString("Could not retrieve data.", comment: "")
        }
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 30, bottom: 30, trailing: 10)

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(85))
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
        let country = countries[section]

        return country.count()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BarCell.cellId, for: indexPath) as! BarCell

        cell.row = indexPath.section

        let country = self.countries[indexPath.section]
        cell.height = country.height(index: indexPath.row, height: 44)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.viewId, for: indexPath) as! DataView

        cell.row = indexPath.section

        let country = self.countries[indexPath.section]
        cell.countryLabel.text = country.country
        cell.casesLabel.attributedText = country.confirmedAttributedText(indexPath.section)

        return cell
    }
}

private extension UIColor {
    static func colorForRow(_ row: Int) -> UIColor {
        return row % 2 == 0 ? .red : UIColor.systemPink
    }
}

private extension Country {
    func confirmedAttributedText(_ row: Int) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        let titleAttribute: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.colorForRow(row),
            .font: UIFont.monospacedSystemFont(ofSize: 65, weight: .regular)
        ]

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let num = NSNumber.init(value: latest.confirmed)

        if let s = numberFormatter.string(from: num) {
            return NSAttributedString.init(string: s, attributes: titleAttribute)
        }

        return NSAttributedString()
    }
}

extension Country {
    static let lastNumDays = 24

    func count() -> Int {
        Country.lastNumDays
    }

    func height(index: Int, height: CGFloat) -> CGFloat {
        let cases = self.newCases()

        let confirmed = cases[index]
        if let max = cases.max() {
          return CGFloat(confirmed) * height / CGFloat(max)
        }

        return 0
    }

    func newCases() -> [Int] {
        var diff: [Int] = []

        let dict = timelines.confirmed.timeline

        let sorted = Array(dict.keys).sorted(by: { $1 > $0 })
        let s = sorted.suffix(Country.lastNumDays + 1)
        let keys = Array(s)

        if var prev: Int = dict[keys[0]] {
            for (k) in keys {
                if let v = dict[k] {
                    let d = v - prev
                    diff.append(d)
                    prev = v
                }
            }
        }

        let diffSuffix = diff.suffix(Country.lastNumDays)
        return Array(diffSuffix)
    }
}

class BarCell: UICollectionViewCell {
    static let cellId = "BarCell"

    var row = 0

    let barView = UIView()

    var height: CGFloat = 44

    override func layoutSubviews() {
        super.layoutSubviews()

        barView.backgroundColor = UIColor.colorForRow(row)

        self.addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                barView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                barView.heightAnchor.constraint(equalToConstant: height),
                barView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                barView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        barView.removeConstraints(barView.constraints)
    }
}

class DataView: UICollectionReusableView {
    static let viewId = "DataCell"

    var row = 0

    let countryLabel = UILabel()
    let casesLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        countryLabel.textColor = UIColor.colorForRow(row)

        self.addSubview(countryLabel)
        countryLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(casesLabel)
        casesLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            countryLabel.topAnchor.constraint(equalTo: self.topAnchor),
            countryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            countryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            casesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            casesLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            casesLabel.heightAnchor.constraint(equalToConstant: 60),
            casesLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        countryLabel.attributedText = nil
        casesLabel.attributedText = nil
    }
}
