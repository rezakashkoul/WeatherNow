//
//  WeatherModel.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import Foundation
//https://api.weatherapi.com/v1/forecast.json?key=67b477a0e3404afeb5891850213110&q=tehran&days=1&aqi=no&alerts=no

struct WeatherModel: Codable , Equatable {
    
    static func == (lhs: WeatherModel, rhs: WeatherModel) -> Bool {
        
        return lhs.location.region == rhs.location.region && lhs.location.name == rhs.location.name && lhs.location.country == rhs.location.country
    }
    
    var location: WeatherLocation
    var current: CurrentWeather
    var forecast: Forecast
    var time: Date?
    var weatherUrl: String?
}

struct Forecast: Codable {
    var forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    var day: Day
}

struct Day: Codable {
    var maxtemp_c: Double
    var mintemp_c: Double
}

struct WeatherLocation: Codable {
    var country: String
    var name: String
    var region: String
}

struct CurrentWeather: Codable {
    var temp_c: Double
    var condition: WeatherCondition
}

struct WeatherCondition: Codable {
    var text: String
    //    var icon: String
}
