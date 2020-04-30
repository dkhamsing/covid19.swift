//
//  DataView.swift
//  covid19
//
//  Created by Daniel on 4/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class DataView: UICollectionReusableView {
    static let identifier = "DataCell"
    
    var color = UIColor.black
    
    private let countryLabel = UILabel()
    private let casesLabel = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        casesLabel.attributedText = nil
        countryLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
        configure()
    }
}

private extension DataView {
    func configure() {
        [countryLabel, casesLabel].forEach { self.autolayoutAddSubview($0) }
        
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
    
    private func setup() {
        countryLabel.textColor = color
    }
}

extension DataView {
    func configure(_ country: Country) {
        countryLabel.text = country.country
        casesLabel.attributedText = country.confirmedAttributedText(color: color)
    }
}

private extension Country {
    func confirmedAttributedText(color: UIColor) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let titleAttribute: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: color,
            .font: UIFont.monospacedSystemFont(ofSize: 64, weight: .regular)
        ]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let num = NSNumber(value: latest.confirmed)
        
        guard let s = numberFormatter.string(from: num) else { return NSAttributedString() }
        
        return NSAttributedString(string: s, attributes: titleAttribute)
    }
}
