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
    static let news = Tab(name: "Health News", imageSystemName: "dot.radiowaves.left.and.right")
    static let bno = Tab(name: "BNO News", imageSystemName: "b.circle", twitterUser: "BNODesk")
    static let twitter = Tab(name: "Daniel Sinclair", imageSystemName: "person.circle", twitterUser: "_DanielSinclair")
}

struct Tab {
    var name: String
    var imageSystemName: String
    var twitterUser: String?
}
