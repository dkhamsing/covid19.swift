//
//  Extension.swift
//  covid19
//
//  Created by Daniel on 4/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

extension Article {
    func attributedDate() -> NSAttributedString {
        guard let publishedAt = self.publishedAt else {
            return NSAttributedString()
        }

        let f = ISO8601DateFormatter()
        let da = f.date(from: publishedAt)
        guard let date = da else {
            return NSAttributedString()
        }

        let attribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ]

        return NSAttributedString(string: "\(date.timeAgoSinceDate())", attributes: attribute)
    }

    func attributedSource() -> NSAttributedString {
        guard let source = self.source,
            let name = source.name else {
                return NSAttributedString()
        }

        let attribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ]

        return NSAttributedString(string: "\(name)", attributes: attribute)
    }

    func attributedContent() -> NSAttributedString {
        let titleAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.white
        ]
        let a = NSMutableAttributedString.init(string: "\(title ?? "")\n", attributes: titleAttribute)

        let whiteColorAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        let b =  NSAttributedString.init(string: description ?? content ?? "", attributes: whiteColorAttribute)
        a.append(b)

        return a
    }
}

// Credits: https://stackoverflow.com/questions/34457434/swift-convert-time-to-time-ago
extension Date {
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

extension String {
    func escapeHtml() -> String {
        var text = self
        text = text.replacingOccurrences(of: "<p>", with: "")
        text = text.replacingOccurrences(of: "</p>", with: "")
        text = text.replacingOccurrences(of: "&rsquot;", with: "")

        return text
    }
}

extension UIImageView {
    func setImageWithURL(_ url: URL?) {
        DispatchQueue.global().async { [weak self] in
            if let url = url,
                let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.image = UIImage(data: data)
                }
            }
        }
    }
}
