//
//  SecondInterfaceController.swift
//  WeatherNowWatch WatchKit Extension
//
//  Created by Reza Kashkoul on 1/Azar/1400 .
//

import WatchKit
import Foundation
import WatchConnectivity

class SecondInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    @IBOutlet weak var city: WKInterfaceLabel!
    @IBOutlet weak var weatherLabel: WKInterfaceLabel!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var minimumTemp: WKInterfaceLabel!
    @IBOutlet weak var maximumTemp: WKInterfaceLabel!
    @IBOutlet weak var updateTime: WKInterfaceLabel!
    
    @IBAction func makeItDefaultButton() {
        saveWeatherData()
        sendWeatherListToPhone()
        popToRootController()
    }

    var weatherData : WeatherModel!
    var weatherIndex : Int!
    var wcSession : WCSession! = nil
    var weatherList : [WeatherModel] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        getAndShowData(context)
        loadWeatherData()
        let element = weatherList.remove(at: weatherIndex)
        weatherList.insert(element, at: 0)
        print("weatherList[0].location.name" , weatherList[0].location.name)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func sendWeatherListToPhone() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weatherList)
            wcSession.sendMessageData(data, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        } catch {
            print("Unable to Encode weatherData (\(error))")
        }
    }
    
    func getAndShowData(_ context: Any?) {
        if let context = context as? (Int, WeatherModel) {
            weatherIndex = context.0
            weatherData = context.1
            city.setText(weatherData.location.name)
            tempLabel.setText(weatherData.current.temp_c.rounded().clean.description + "°C")
            minimumTemp.setText(weatherData.forecast.forecastday[0].day.mintemp_c.rounded().clean.description + "°C")
            maximumTemp.setText(weatherData.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description + "°C")
            updateTime.setText(weatherData.time?.getCleanTime())
            setWeatherCondition(weatherData)
            print("weatherIndex is", weatherIndex!)
        }
    }
    
    func setWeatherCondition (_ data: WeatherModel) {
        switch data.current.condition.text {
        case "Sunny" : weatherLabel.setText("☀️")
        case "Partly cloudy" : weatherLabel.setText("🌤")
        case "Cloudy" : weatherLabel.setText("🌥")
        case "Overcast" : weatherLabel.setText("🌩")
        case "Mist" : weatherLabel.setText("💧")
        case "Thundery outbreaks possible" : weatherLabel.setText("⛈")
        case "Blowing snow" : weatherLabel.setText("🌬")
        case "Fog" : weatherLabel.setText("🌫")
        case "Clear" : weatherLabel.setText("🌤")
        case "Light rain" :weatherLabel.setText("☔️")
        case "Heavy rain" : weatherLabel.setText("🌧")
        case "Light snow showers" : weatherLabel.setText("❄️")
        case "Light drizzle" : weatherLabel.setText("🌧")
        default:
            weatherLabel.setText("？")
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
}
