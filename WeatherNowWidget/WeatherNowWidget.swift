//
//  WeatherNowWidget.swift
//  WeatherNowWidget
//
//  Created by Reza Kashkoul on 8/Azar/1400 .
//

import WidgetKit
import SwiftUI
import Intents


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weather: WeatherModel(location: WeatherLocation.init(country: "", name: "", region: ""), current: CurrentWeather(temp_c: 0.0, condition: WeatherCondition(text: "")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: ""), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =  SimpleEntry(date: Date().getCleanTime().getDateFromString() ?? Date() , weather: WeatherModel(location: WeatherLocation.init(country: "US", name: "Cupertino", region: "LA"), current: CurrentWeather(temp_c: 27, condition: WeatherCondition(text: "Sunny")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: ""), configuration: ConfigurationIntent())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        getWeatherDataFromiPhone()
        updateWeather()
        saveWeatherData()
        
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry =  SimpleEntry(date: entryDate, weather: weatherData, configuration: ConfigurationIntent())
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weather: WeatherModel
    let configuration: ConfigurationIntent
    
    
    
    
}

struct WeatherNowWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    
    var entry: Provider.Entry
    var bwColor: some View {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    var body: some View {
        if weatherList.count != 0 {
            
            ZStack {
                bwColor
                //                Color(UIColor.white)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        Text(entry.weather.current.temp_c.rounded().clean.description + "°C")
                            .font(.system(size: 32))
                            .foregroundColor(Color.customBlue)
                        
                        switch entry.weather.current.condition.text {
                        case "Sunny" : Text("☀️") .font(.system(size: 32))
                        case "Partly cloudy" : Text("🌤") .font(.system(size: 32))
                        case "Cloudy" : Text("🌥") .font(.system(size: 32))
                        case "Overcast" : Text("🌩") .font(.system(size: 32))
                        case "Mist" : Text("💧") .font(.system(size: 32))
                        case "Thundery outbreaks possible" : Text("⛈") .font(.system(size: 32))
                        case "Blowing snow" : Text("🌬") .font(.system(size: 32))
                        case "Fog" : Text("🌫") .font(.system(size: 32))
                        case "Clear" : Text("🌤") .font(.system(size: 32))
                        case "Light rain" : Text("☔️") .font(.system(size: 32))
                        case "Heavy rain" : Text("🌧") .font(.system(size: 32))
                        case "Light snow showers" : Text("❄️") .font(.system(size: 32))
                        case "Light drizzle" : Text("🌧") .font(.system(size: 32))
                        default:
                            Text("🌤")
                                .font(.system(size: 32))
                        }
                    }
                    
                    
                    Text(entry.weather.location.name)
                        .foregroundColor(Color.customBlue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.system(size: 25))
                    
                    Text(entry.weather.location.country)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.01)
                    
                        .foregroundColor(Color.customBlue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    //
                    HStack(spacing: 3) {
                        Text("↓").foregroundColor(.blue)
                            .font(.system(size: 12))
                        Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description).foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        Text("↑").foregroundColor(.red)
                            .font(.system(size: 12))
                        Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description).foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        
                        
                    }
                    VStack {
                        Text("Last Update: " + (entry.weather.time?.getCleanTime())! ?? "None").foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                    }
                    
                    
                    
                    
                    
                    
                }.padding()
                    .onAppear {
                        //                    loadWeatherData()
                    }
            }
        }
    }
}

@main
struct WeatherNowWidget: Widget {
    let kind: String = "WeatherNowWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WeatherNowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WeatherNow Widget")
        .description("A powerful weather app. I hope you enjoy")
        .supportedFamilies([.systemSmall , .systemMedium])
    }
}

struct WeatherNowWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherNowWidgetEntryView(entry:  SimpleEntry(date: Date(), weather: WeatherModel(location: WeatherLocation.init(country: "", name: "", region: ""), current: CurrentWeather(temp_c: 27, condition: WeatherCondition(text: "")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: ""), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WeatherNowWidgetEntryView(entry:  SimpleEntry(date: Date(), weather: WeatherModel(location: WeatherLocation.init(country: "", name: "", region: ""), current: CurrentWeather(temp_c: -12, condition: WeatherCondition(text: "")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: ""), configuration: ConfigurationIntent()))
            .redacted(reason: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
    }
}

var weatherData : WeatherModel!
var weatherList : [WeatherModel] = []
var locationList : [SearchLocationModel] = []
var expiredItems : [WeatherModel] = []

func addPercentageToUrl(urlString : String) -> String{
    return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}

func getWeatherDataFromiPhone() {
    let userDefaults = UserDefaults(suiteName: "group.weatherNow")
    let data = userDefaults?.object(forKey: "weatherForWidget")
    do {
        let decoder = JSONDecoder()
        weatherList = try decoder.decode([WeatherModel].self, from: data as! Data)
        print("weatherList.count is \(weatherList)")
        weatherData = weatherList[0]
    }
    catch {
        print("Unable to Decode weatherData (\(error))")
    }
}

func updateWeather() {
    var counter = 0
    loadWeatherData()
    expiredItems = weatherList.filter({ $0.time!.timeIntervalSinceNow  < -120})
    print("Widgets expiredItems.count", expiredItems.count)
    for _ in expiredItems {
        let fixedUrl = addPercentageToUrl(urlString: "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(weatherList[counter].location.name)-\(weatherList[counter].location.region)-\(weatherList[counter].location.country)&days=1&aqi=no&alerts=no")
        //            print("weatherList\(weatherList)")
        if let urlString = URL(string: fixedUrl) {
            counter += 1
            //                print("urlString", fixedUrl)
            let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
                if let data = data , error == nil {
                    parseForUpdate(json: data)
                    if counter == expiredItems.count {
                        DispatchQueue.main.async {
                            saveWeatherData()
                        }
                    }
                } else {
                    print("Error in fetching data")
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
        print("Widget: Weather Parsing Error: \(error)")
    }
}

func saveWeatherData() {
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(weatherList)
        UserDefaults.standard.set(data, forKey: "widget")
    } catch {
        print("Widget: Unable to Encode weatherData (\(error))")
    }
}

func loadWeatherData() {
    if let data = UserDefaults.standard.data(forKey: "widget") {
        do {
            let decoder = JSONDecoder()
            weatherList = try decoder.decode([WeatherModel].self, from: data)
        }
        catch {
            print("Widget: Unable to Decode weatherData (\(error))")
        }
    }
}

extension Color {
    static let customBlue = Color(red: 109.0/255.0, green: 154.0/255.0, blue: 242.0/255.0)
}

//
//struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), configuration: configuration)
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationIntent
//}
//
//struct WeatherNowWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text(entry.date, style: .time)
//    }
//}
//
//@main
//struct WeatherNowWidget: Widget {
//    let kind: String = "WeatherNowWidget"
//
//    var body: some WidgetConfiguration {
//        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
//            WeatherNowWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//struct WeatherNowWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherNowWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
