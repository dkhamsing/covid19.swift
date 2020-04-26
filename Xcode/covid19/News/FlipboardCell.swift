//
//  FlipboardCell.swift
//  covid19
//
//  Created by Daniel on 4/22/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class FlipboardCell: NewsProfileCell {
    static let ReuseIdentifier = "flipboard"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        config()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(_ article: Article) {
        super.configure(article)

        title.text = article.title
        content.attributedText = article.flipboardAttributedSubtitle
        ago.text = article.publishedAt?.timeAgoSinceDate
        source.text = article.source?.name
    }
}

private extension Date {
    var timeAgoSinceDate: String {
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

extension FlipboardCell {
    static var LogoSize = CGSize(width: 38, height: 38)

    func setup() {
        imageSize = CGSize(width: 400, height: 240)

        line.backgroundColor = .flipboardLineGray

        contentView.backgroundColor = .flipboardWhite

        content.numberOfLines = 0

        imageView.contentMode = .scaleAspectFit

        source.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 17)

        ago.textColor = .flipboardAgoGray
        ago.font = .systemFont(ofSize: 14)

        title.numberOfLines = 0
        title.font = UIFont(name: "TimesNewRomanPSMT", size: 28)

        sourceLogo.layer.cornerRadius = FlipboardCell.LogoSize.width / 2
        sourceLogo.layer.masksToBounds = true
    }

    func config() {
        [line, imageView, title, content, sourceLogo, source, ago].forEach { contentView.autolayoutAddSubview($0) }

        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: contentView.topAnchor),
            line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 13),

            imageView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            imageView.heightAnchor.constraint(equalToConstant: imageSizeUnwrapped.height),

            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            sourceLogo.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 15),
            sourceLogo.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            sourceLogo.widthAnchor.constraint(equalToConstant: FlipboardCell.LogoSize.width),
            sourceLogo.heightAnchor.constraint(equalToConstant: FlipboardCell.LogoSize.width),

            source.leadingAnchor.constraint(equalTo: sourceLogo.trailingAnchor, constant: 10),
            source.centerYAnchor.constraint(equalTo: sourceLogo.centerYAnchor),

            ago.topAnchor.constraint(equalTo: sourceLogo.bottomAnchor, constant: 22),
            ago.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: ago.bottomAnchor, constant: 5),
        ])
    }
}

private extension Article {
    var flipboardAttributedSubtitle: NSAttributedString {
        guard let font = UIFont(name: "AppleSDGothicNeo-Light", size: 15),
            let d = descriptionOrContent
            else { return NSAttributedString() }

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style,
        ]

        return NSAttributedString.init(string: d, attributes: attributes)
    }
}

private extension UIColor {
    static let flipboardAgoGray = UIColor.colorFor(red: 171, green: 173, blue: 174)
    static let flipboardLineGray = UIColor.colorFor(red: 231, green: 232, blue: 233)
    static let flipboardRed = UIColor.colorFor(red: 242, green: 38, blue: 38)
    static let flipboardWhite = UIColor.colorFor(red: 254, green: 255, blue: 255)
}
