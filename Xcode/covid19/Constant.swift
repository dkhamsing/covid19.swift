//
//  Constant.swift
//  covid19
//
//  Created by Daniel on 4/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Constant {
    static let web = Tab.init(name: "Data", imageSystemName: "globe")
    static let data = Tab.init(name: "Cases", imageSystemName: "chart.bar")
    static let news = Tab.init(name: "Health News", imageSystemName: "dot.radiowaves.left.and.right")
    static let bno = Tab.init(name: "BNO News", imageSystemName: "b.circle", twitterUser: "BNODesk")
    static let twitter = Tab.init(name: "Daniel Sinclair", imageSystemName: "person.circle", twitterUser: "_DanielSinclair")
}

struct Tab {
    var name: String
    var imageSystemName: String
    var twitterUser: String?
}

struct Website {
    var domain: String
    var urlString: String
}
