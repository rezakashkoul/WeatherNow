//
//  NetworkManager.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 3/Aban/1400 AP.
//

import Foundation

class NetworkManager {
    
//    func getDataFromApi() {
//        //api.openweathermap.org/data/2.5/weather?q=tehran&appid=a7acbfef3e0f470c7336e452e1a3c002
//        guard let urlString = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(.text!)&units=metric&appid=a7acbfef3e0f470c7336e452e1a3c002") else { return }
//        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
//            if let data = data , error == nil {
//                self.parse(json: data)
//            }
//        }
//        task.resume()
//    }
//
//    func parse(json: Data) {
//        let decoder = JSONDecoder()
//        do {
////            let weatherObject = try decoder.decode(WeatherModel.self, from: json)
////            DispatchQueue.main.async {
////                self.weatherObjects = [weatherObject]
////                self.tableView.reloadData()
////            }
//        } catch let error as NSError {
//            print("Parsing Error: \(error)")
//        }
//    }

}
