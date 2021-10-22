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
    var sys : SYS
    var name : Name
}

struct Weather : Codable {
    var main : String?
    
    var id: Int?
    var description: String?
    var icon: String?
    
    
}
struct Main : Codable {
    var temp : Double?
    var temp_min : Double?
    var temp_max : Double?
}

struct SYS : Codable {
    var country : String?
}

struct Name : Codable {
    var name : String?
}









//struct VolumeInfo : Codable {
//    var title : String?
//    var authors : [String]?
////    var authors : String?
//
//    var pageCount : Int?
//    var ratingCount : Int?
//    var averageRating : Int?
//    var imageLinks : ImageLink?
//}
//struct ImageLink : Codable {
//    var smallThumbnail : String?
//    var thumbnail : String?
//}
//
//struct AccessInfo : Codable {
//    var epub : Epub?
//}
//struct Epub : Codable {
//    var downloadLink : String?
//}
