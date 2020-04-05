//
//  Constant.swift
//  covid19
//
//  Created by Daniel on 4/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Constant {
    static let apiKey = "8815d577462a4195a64f6f50af3ada08"

    static let news = Tab.init(name: "Health News", imageSystemName: "dot.radiowaves.left.and.right")
    static let bno = Tab.init(name: "Tweets by BNO News", imageSystemName: "b.circle", twitterUser: "BNODesk")
    static let twitter = Tab.init(name: "Tweets by Daniel Sinclair", imageSystemName: "person.circle", twitterUser: "_DanielSinclair")
}

struct Tab {
    var name: String
    var imageSystemName: String
    var twitterUser: String?
}
