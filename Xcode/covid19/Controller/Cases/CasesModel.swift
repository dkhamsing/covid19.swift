//
//  CasesModel.swift
//  covid19
//
//  Created by Daniel on 4/6/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Response: Codable {
    var latest: Latest
    var locations: [Country]
}

struct Country: Codable {
    var country: String
    var latest: Latest
    var timelines: Timeline
}

struct Latest: Codable {
    var confirmed: Int
    var deaths: Int
}

struct Timeline: Codable {
    var confirmed: CovidData
    var deaths: CovidData
}

struct CovidData: Codable {
    var latest: Int?
    var timeline: [String: Int]
}
