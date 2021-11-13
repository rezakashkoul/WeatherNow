//
//  SearchLocationModel.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 9/Aban/1400 AP.
//

import Foundation

struct SearchLocationModel: Codable {
    var url: String
    var name: String
    // var region: String
    //var country: String
    var time: Date?
}
