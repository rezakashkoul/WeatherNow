//
//  Extension.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 1-Aban-1400.
//

import Foundation

extension Double {
    var toCelsius: Double {
        return (self - 32) / 1.8
    }
    
}
