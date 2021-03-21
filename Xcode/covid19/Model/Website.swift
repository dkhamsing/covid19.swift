//
//  Website.swift
//  covid19
//
//  Created by Daniel on 3/20/21.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

struct Website {
    var domain: String
    var urlString: String

    static var content: [Website] {
        return [
            Website(domain: "viruscovid.tech", urlString: "https://viruscovid.tech"),
            Website(domain: "ncov2019.live", urlString: "https://ncov2019.live"),
            Website(domain: "google.com", urlString: "https://www.google.com/search?q=covid+cases"),
            Website(domain: "apple.com/covid19/mobility", urlString: "https://www.apple.com/covid19/mobility"),
        ]
    }
}
