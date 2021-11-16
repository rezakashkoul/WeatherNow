//
//  InterfaceController.swift
//  WeatherNowWatch WatchKit Extension
//
//  Created by Reza Kashkoul on 23/Aban/1400 .
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var cityName: WKInterfaceLabel!
    @IBOutlet weak var skyLabel: WKInterfaceLabel!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var minTemp: WKInterfaceLabel!
    @IBOutlet weak var maxTemp: WKInterfaceLabel!
    @IBOutlet weak var timeOfUpdate: WKInterfaceLabel!
    
    var locationData : SearchLocationModel!
    var weatherData : WeatherModel!
    var weatherList : [WeatherModel] = []
    var locationList : [SearchLocationModel] = []
    var expiredItems : [WeatherModel] = []
    var timer: Timer?
//    let reachability = try! Reachability()
    
    override func awake(withContext context: Any?) {
        
        loadWeatherData()
        loadLocationData()
        cityName.setText(weatherList[0].location.name)
        setWeatherCondition()
        temperatureLabel.setText(weatherList[0].current.temp_c.description)
        minTemp.setText(weatherList[0].forecast.forecastday[0].day.mintemp_c.description)
        maxTemp.setText(weatherList[0].forecast.forecastday[0].day.maxtemp_c.description)
        timeOfUpdate.setText(weatherList[0].time?.description)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func setWeatherCondition() {
        switch weatherList[0].current.condition.text {
        case "Sunny" : skyLabel.setText("☀️")
        case "Partly cloudy" : skyLabel.setText("🌤")
        case "Cloudy" : skyLabel.setText("🌥")
        case "Overcast" : skyLabel.setText("🌩")
        case "Mist" : skyLabel.setText("💧")
        case "Thundery outbreaks possible" : skyLabel.setText("⛈")
        case "Blowing snow" : skyLabel.setText("🌬")
        case "Fog" : skyLabel.setText("🌫")
        case "Clear" : skyLabel.setText("🌤")
        case "Light rain" :skyLabel.setText("☔️")
        case "Heavy rain" : skyLabel.setText("🌧")
        case "Light snow showers" : skyLabel.setText("❄️")
        case "Light drizzle" : skyLabel.setText("🌧")
        default:
            skyLabel.setText("？")
        }
    }
    
//    func trigerTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { (timer) in
//            self.updateWeather()
//            print("Update by timer \(Date().getCleanTime())")
//        }
//    }
    
    func addPercentageToUrl(urlString : String) -> String{
        return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func getWeather() {
        let fixedUrl = addPercentageToUrl(urlString: "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(locationData.url)&days=1&aqi=no&alerts=no")
        if let urlString = URL(string: fixedUrl) {
            let task = URLSession.shared.dataTask(with: urlString) { [self] data, response, error in
                if let data = data , error == nil {
                    self.parseNewWeather(json: data)
                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
                    }
                } else {
                    print("Error in fetching data")
                }
            }
            task.resume()
        }
    }
    
    func updateWeather() {
        var counter = 0
        expiredItems = weatherList.filter({ $0.time!.timeIntervalSinceNow  < -120})
        print("expiredItems.count", expiredItems.count)
        for _ in expiredItems {
            let fixedUrl = addPercentageToUrl(urlString: "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(weatherList[counter].location.name)-\(weatherList[counter].location.region)-\(weatherList[counter].location.country)&days=1&aqi=no&alerts=no")
            //            print("weatherList\(weatherList)")
            if let urlString = URL(string: fixedUrl) {
                counter += 1
                //                print("urlString", fixedUrl)
                let task = URLSession.shared.dataTask(with: urlString) { [self] data, response, error in
                    if let data = data , error == nil {
                        self.parseForUpdate(json: data)
                        if counter == expiredItems.count {
                            DispatchQueue.main.async {
//                                self.saveWeatherData()
//                                self.saveLocationData()
                            }
                        }
                    } else {
                        print("Error in fetching data")
                        DispatchQueue.main.async {
//                            self.showErrorInFetchingData()
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func parseForUpdate(json: Data) {
        let decoder = JSONDecoder()
        do {
            var weatherObject = try decoder.decode(WeatherModel.self, from: json)
            weatherObject.time = Date()
            if weatherList.contains(weatherObject) {
                for i in 0..<weatherList.count {
                    if weatherList[i].location.region == weatherObject.location.region && weatherList[i].location.name == weatherObject.location.name && weatherList[i].location.country == weatherObject.location.country {
                        weatherList[i] = weatherObject
                    }
                }
            }
//            saveWeatherData()
//            saveLocationData()
            DispatchQueue.main.async {
            }
        } catch {
            print("Weather Parsing Error: \(error)")
        }
    }
    
    func parseNewWeather(json: Data) {
        let decoder = JSONDecoder()
        do {
            var weatherObject = try decoder.decode(WeatherModel.self, from: json)
            weatherObject.time = Date()
            weatherObject.weatherUrl = locationData.url
            weatherList.append(weatherObject)
//            saveWeatherData()
//            saveLocationData()
        } catch {
            print("Weather Parsing Error: \(error)")
        }
    }
    
    func loadLocationData() {
        if let data = UserDefaults.standard.data(forKey: "location") {
            do {
                let decoder = JSONDecoder()
                locationList = try decoder.decode([SearchLocationModel].self, from: data)
            } catch {
                print("Unable to Decode LocationData (\(error))")
            }
        }
    }
    
    func loadWeatherData() {
        if let data = UserDefaults.standard.data(forKey: "weather") {
            do {
                let decoder = JSONDecoder()
                weatherList = try decoder.decode([WeatherModel].self, from: data)
            } catch {
                print("Unable to Decode weatherData (\(error))")
            }
        }
    }
}
