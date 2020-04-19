//
//  CnnCell.swift
//  covid19
//
//  Created by Daniel on 4/13/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class CnnCell: UICollectionViewCell {
    var identifier: String?

    private let imageView = UIImageView()
    private let top = UILabel()
    private let imageLabel = UILabel()
    private let content = UILabel()
    private let ago = UILabel()
    private let separator = UIView()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        identifier = nil
        top.text = nil
        imageLabel.text = nil
        content.text = nil
        ago.text = nil
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CnnCell {
    static var ReuseIdentifier = "CnnCell"
    static var ImageSize = CGSize(width: 450, height: 280)
    
    func configure(_ article: Article) {
        ago.text = article.cnnAgo
        top.text = article.source?.name?.uppercased()
        imageLabel.text = article.title
        content.text = article.descriptionOrContent
        identifier = article.identifier
    }

    func update(image: UIImage?, identifier ident: String?) {
        guard identifier == ident else { return }
        imageView.image = image

        guard imageView.layer.sublayers?.count == nil else { return }
        addGradient()
    }
}

private extension CnnCell {
    func addGradient() {
           let gradientLayer = CAGradientLayer()
           gradientLayer.frame = imageView.bounds
           gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
           imageView.layer.insertSublayer(gradientLayer, at: 0)
       }

    func setup() {
        contentView.backgroundColor = .white
        
        ago.textColor = .lightGray
        ago.font = UIFont.systemFont(ofSize: 14)
        
        top.textColor = .white
        top.font = UIFont.boldSystemFont(ofSize: 12)
        
        imageLabel.numberOfLines = 0
        imageLabel.textColor = .white
        
        content.numberOfLines = 0
        content.textColor = .darkGray
        content.font = UIFont.systemFont(ofSize: 14)
        
        imageView.contentMode = .scaleAspectFit

        separator.backgroundColor = UIColor.colorFor(red: 241, green: 242, blue: 246)
    }
    
    func config() {
        [imageView, top, imageLabel, content, ago, separator].forEach { contentView.autolayoutAddSubview($0) }
        
        let inset: CGFloat = 15
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: CnnCell.ImageSize.height),
            
            top.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: inset),
            top.heightAnchor.constraint(equalToConstant: 35),
            top.bottomAnchor.constraint(equalTo: imageLabel.topAnchor),
            
            imageLabel.leadingAnchor.constraint(equalTo: top.leadingAnchor),
            imageLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: (-2 * inset)),
            imageLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -inset),
            
            content.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: inset),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: (2 * inset)),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: (-2 * inset)),

            ago.topAnchor.constraint(equalTo: content.bottomAnchor),
            ago.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            ago.heightAnchor.constraint(equalToConstant: 35),

            separator.topAnchor.constraint(equalTo: ago.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 10),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

private extension Article {
    var cnnAgo: String {
        guard let publishedAt = self.publishedAt else {
            return ""
        }
        
        let f = ISO8601DateFormatter()
        let da = f.date(from: publishedAt)
        guard let date = da else {
            return ""
        }
        
        return date.timeAgoSinceDate()
    }
}

// Credits: https://stackoverflow.com/questions/34457434/swift-convert-time-to-time-ago
private extension Date {
    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }

        return "a moment ago"
    }
}
