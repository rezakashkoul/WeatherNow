//
//  Extension.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 3/Aban/1400 AP.
//

import UIKit

extension UIColor {
    static let customBlue = UIColor(red: 109.0/255.0, green: 154.0/255.0, blue: 242.0/255.0, alpha: 1.0)
}

extension Date {
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func getCleanTime()-> String {
        return self.get(.hour).description + ":" + self.get(.minute).description + ":" + self.get(.second).description
    }
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
