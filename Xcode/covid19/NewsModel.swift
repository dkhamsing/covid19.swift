//
//  Model.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Headline: Codable {
    var status: String?
    var totalResults: Int?
    var articles: [Article]
}

struct Article: Codable {
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?

    var source: Source?
}

struct Source: Codable {
    var name: String?
}
