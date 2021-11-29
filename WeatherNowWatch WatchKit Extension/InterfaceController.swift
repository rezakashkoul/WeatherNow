//
//  InterfaceController.swift
//  WeatherNowWatch WatchKit Extension
//
//  Created by Reza Kashkoul on 23/Aban/1400 .
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var cityName: WKInterfaceLabel!
    @IBOutlet weak var skyLabel: WKInterfaceLabel!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var minTemp: WKInterfaceLabel!
    @IBOutlet weak var maxTemp: WKInterfaceLabel!
    @IBOutlet weak var timeOfUpdate: WKInterfaceLabel!
    @IBOutlet weak var weatherDataStatus: WKInterfaceLabel!
    @IBOutlet weak var currentGroup: WKInterfaceGroup!
    @IBOutlet weak var minMaxGroup: WKInterfaceGroup!
    @IBOutlet weak var timeGroup: WKInterfaceGroup!
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var weatherData : WeatherModel!
    var weatherList : [WeatherModel] = []
    var locationList : [SearchLocationModel] = []
    var expiredItems : [WeatherModel] = []
    var timer: Timer?
    var wcSession : WCSession!
    
        override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        loadWeatherData()
        DispatchQueue.main.async {
            self.setupTable()
            self.setupWeatherUIToPresent()
        }
    }
    
    override func willActivate() {
        super.willActivate()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        loadWeatherData()
        DispatchQueue.main.async {
            self.setupTable()
            self.setupWeatherBanner()
            self.setupWeatherUIToPresent()
            self.scroll(to: self.cityName, at: .top , animated: true)
        }
        updateWeather()
        trigerTimer()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func setupTable() {
        if tableView == nil { return }
        tableView.setNumberOfRows(weatherList.count, withRowType: "watchCell")
        
        for (index, item) in weatherList.enumerated() {
            let row = tableView.rowController(at: index) as! WatchCustomCell
            row.cityName.setText(item.location.name)
            row.currentTemp.setText(item.current.temp_c.rounded().clean.description + " °C")
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "SecondInterfaceController", context: (index: rowIndex, data: weatherList[rowIndex]))
    }
    
    func setupWeatherUIToPresent() {
        if weatherList.count == 0 {
            weatherDataStatus.setHidden(false)
            cityName.setHidden(true)
            currentGroup.setHidden(true)
            minMaxGroup.setHidden(true)
            timeGroup.setHidden(true)
            tableView.setHidden(true)
        } else {
            weatherDataStatus.setHidden(true)
            cityName.setHidden(false)
            currentGroup.setHidden(false)
            minMaxGroup.setHidden(false)
            timeGroup.setHidden(false)
            tableView.setHidden(false)
        }
    }
    
    func setupWeatherBanner() {
        if weatherList.count != 0 {
            cityName.setText(weatherList[0].location.name)
            setWeatherCondition()
            timeOfUpdate.setText((weatherList[0].time?.getCleanTime().description)!)
            temperatureLabel.setText(weatherList[0].current.temp_c.rounded().clean.description + " °C")
            minTemp.setText(weatherList[0].forecast.forecastday[0].day.mintemp_c.rounded().clean.description + " °C")
            maxTemp.setText(weatherList[0].forecast.forecastday[0].day.maxtemp_c.rounded().clean.description + " °C")
        }
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
    
    func trigerTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { (timer) in
            self.updateWeather()
            print("Update by timer \(Date().getCleanTime())")
        }
    }
    
    func addPercentageToUrl(urlString : String) -> String{
        return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
                                self.saveWeatherData()
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
            saveWeatherData()
        } catch {
            print("Watch Weather Parsing Error: \(error)")
        }
    }
    
    func saveWeatherData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weatherList)
            UserDefaults.standard.set(data, forKey: "watch")
        } catch {
            print("Unable to Encode weatherData (\(error))")
        }
    }
    
    func loadWeatherData() {
        if let data = UserDefaults.standard.data(forKey: "watch") {
            do {
                let decoder = JSONDecoder()
                weatherList = try decoder.decode([WeatherModel].self, from: data)
            }
            catch {
                print("Unable to Decode weatherData (\(error))")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let decoder = JSONDecoder()
            weatherList = try decoder.decode([WeatherModel].self, from: messageData)
            saveWeatherData()
            DispatchQueue.main.async {
                self.setupWeatherUIToPresent()
                self.setupWeatherBanner()
                self.setupTable()
            }
        } catch {
            print("Unable to Decode weatherData (\(error))")
        }
    }
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
        return self.get(.hour).description + ":" + self.get(.minute).description
    }
}
