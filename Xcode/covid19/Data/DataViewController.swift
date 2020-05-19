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
    static let sectionHeaderElementKind = "section-header-country"
    
    // UI
    private var collectionView: UICollectionView?
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configure()
        loadData()
    }
}

private extension DataViewController {
    func colorForRow(_ row: Int) -> UIColor {
        return row % 2 == 0 ? .red : UIColor.systemPink
    }
    
    func configure() {
        // Collection view
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let cv = collectionView {
            view.addSubview(cv)
        }
        
        // Spinner
        view.autolayoutAddSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setup() {
        title = Constant.data.name
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView?.register(DataBarCell.self, forCellWithReuseIdentifier: DataBarCell.identifier)
        collectionView?.register(DataView.self, forSupplementaryViewOfKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.identifier)
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
    }
    
    func loadData() {
        guard let url = URL(string: trackerApiStringUrl) else {
            self.presentOkAlertWithMessage("Error with the API URL")
            return
        }
        
        spinner.startAnimating()
        
        url.get { (result: Result<Response, ApiError>) in
            self.spinner.stopAnimating()
            
            switch result {
            case .success(let r):
                self.countries = r.locations.sorted(by: { $0.latest.confirmed > $1.latest.confirmed })
                self.collectionView?.reloadData()
                
            case .failure(let e):
                self.presentOkAlertWithMessage(e.localizedDescription)
            }
        }
    }
    
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
                                                      heightDimension: .absolute(85))
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
        return Country.numberOfDaysOfDataToDisplay
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DataBarCell.identifier, for: indexPath) as! DataBarCell
        
        cell.color = colorForRow(indexPath.section)
        
        let country = self.countries[indexPath.section]
        cell.height = country.height(index: indexPath.row, height: 44)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: DataViewController.sectionHeaderElementKind, withReuseIdentifier: DataView.identifier, for: indexPath) as! DataView
        
        cell.color = colorForRow(indexPath.section)
        
        let country = self.countries[indexPath.section]
        cell.configure(country)
        
        return cell
    }
}

private extension Country {
    static let numberOfDaysOfDataToDisplay = 24
    
    func height(index: Int, height: CGFloat) -> CGFloat {
        let cases = self.newCases()
        
        let confirmed = cases[index]
        
        guard let max = cases.max() else { return 0 }
        
        return CGFloat(confirmed) * height / CGFloat(max)
    }
    
    func newCases() -> [Int] {
        var newCases: [Int] = []
        
        let dataDictionary = timelines.confirmed.timeline
        
        let sortedDateKeys = Array(dataDictionary.keys).sorted(by: { $1 > $0 })
        let subset = sortedDateKeys.suffix(Country.numberOfDaysOfDataToDisplay + 1)
        let sortedDateKeysSubset = Array(subset)
        
        if var prev: Int = dataDictionary[sortedDateKeysSubset[0]] {
            for (k) in sortedDateKeysSubset {
                if let v = dataDictionary[k] {
                    let d = v - prev
                    newCases.append(d)
                    prev = v
                }
            }
        }

        let newCasesSubset = newCases.suffix(Country.numberOfDaysOfDataToDisplay)
        return Array(newCasesSubset)
    }
}
