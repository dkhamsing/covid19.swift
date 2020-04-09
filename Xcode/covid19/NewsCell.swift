//
//  NewsCell.swift
//  covid19
//
//  Created by Daniel on 4/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class NewsCell: UICollectionViewCell {
    static let cellId = "NewsCell"

    var urlString: String? {
        didSet {
            guard let u = urlString,
                let url = URL.init(string: u) else {
                    return
            }

            imageView.setImageWithURL(url)
        }
    }

    private let imageView = UIImageView()
    let label = UILabel()
    let dateLabel = UILabel()
    let sourceLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(sourceLabel)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 25),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            sourceLabel.topAnchor.constraint(equalTo:contentView.topAnchor),
            sourceLabel.heightAnchor.constraint(equalToConstant: 25),
            sourceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            imageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        imageView.image = nil

        label.attributedText = nil
    }

    private func setup() {
        label.numberOfLines = 0

        let cornerRadius: CGFloat = 10

        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
