//
//  Constant.swift
//  covid19
//
//  Created by Daniel on 4/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Constant {
    static let web = Tab(name: "Data", imageSystemName: "globe")
    static let data = Tab(name: "Cases", imageSystemName: "chart.bar")
    static let trends = Tab(name: "Mobility", imageSystemName: "chart.bar")
    static let news = Tab(name: "News", imageSystemName: "dot.radiowaves.left.and.right")
    static let twitter = Tab(name: "Twitter", imageSystemName: "dot.radiowaves.left.and.right")
}

struct Tab {
    var name: String
    var imageSystemName: String
}

struct Website {
    var domain: String
    var urlString: String
}
