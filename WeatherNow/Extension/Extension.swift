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

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
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
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
    }
}

extension String {
    func getDateFromString(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> Date? { //yyyy-MM-dd'T'HH:mm:ss
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func makeItDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "12:38 AM"
        return dateFormatter.date(from: self) // replace Date String
    }
}
