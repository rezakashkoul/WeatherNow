//
//  WeatherModel.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import Foundation



struct WeatherModel : Codable {
    var weather : [Weather]
    var main : Main
    var sys : Sys
    var name : String
    var time : String?
//    init(weather: [Weather] , main: Main , sys: Sys, name: Name)  {
//        self.weather = weather
//        self.main = main
//        self.sys = sys
//        self.name = name
//    }
}

struct Weather : Codable {
    var main : String
}

struct Main : Codable {
    var temp : Double
    var temp_min : Double
    var temp_max : Double
}

struct Sys : Codable {
    var country : String
}
