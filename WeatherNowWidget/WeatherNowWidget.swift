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
    
    let weather = WeatherModel(location: WeatherLocation.init(country: "", name: "", region: ""), current: CurrentWeather(temp_c: 0.0, condition: WeatherCondition(text: "")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: "")
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weather: weather , configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weather: weather ,configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            getWeatherDataFromiPhone()
            //            updateWeather()
            saveWeatherData()
            if weatherList.count != 0 {
                let entry = SimpleEntry(date: entryDate, weather: weatherList[0] ,configuration: configuration)
                entries.append(entry)
            } else {
                print("***** weatherList in empty *****")
                let entry = SimpleEntry(date: entryDate, weather: mockData ,configuration: configuration)
                entries.append(entry)
            }
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
    
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    var body: some View {
        
        //        WeatherItemsForList(entry: entry)
        
        switch family {
        case .systemSmall:
            SmallWidget(entry: entry)
            //            Text("hello")
            //            if weatherList.count == 0 {
            //                Text("Please add some cities")
            //            }
            
            
        case .systemMedium:
            MediumWidget(entry: entry)
            
            //            if weatherList.count == 0 {
            //                Text("Please add some cities")
            //            }
            //            Text("Medium")
            
        case .systemLarge:
            //            if weatherList.count == 0 {
            //                Text("Please add some cities")
            //
            LargeWidget(entry: entry)
            //            Text("X-Large")
            
            
            
        default:
            Text("Some other WidgetFamily in the future.")
        }
    }
    
    struct SmallWidget: View {
        var entry: Provider.Entry
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
                        .minimumScaleFactor(0.5)
                        .font(.system(size: 27))
                        .foregroundColor(Color.customBlue)
                    WeatherEmoji(entry: entry)
                }
                Text(entry.weather.location.name).bold()
                    .foregroundColor(Color.customBlue)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .font(.system(size: 25))
                    .minimumScaleFactor(0.5)
                Text(entry.weather.location.country)
                    .foregroundColor(Color.customBlue)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .minimumScaleFactor(0.5)
                HStack(alignment: .center, spacing: 3) {
                    Text("↓").foregroundColor(.blue)
                        .font(.system(size: 12))
                    //                    Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
                    Text("5 ")
                        .foregroundColor(Color.customBlue)
                        .font(.system(size: 12))
                    Text("↑")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    //                    Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
                    Text("12")
                        .foregroundColor(Color.customBlue)
                        .font(.system(size: 12))
                }
                
                HStack(alignment: .center, spacing: 3, content: {
                    Text("Last Update: ")
                        .foregroundColor(Color.customBlue)
                        .font(.system(size: 12))
                    
                    Text(entry.weather.time?.getCleanTime() ?? "None")
                        .foregroundColor(Color.customBlue)
                        .font(.system(size: 12))
                })
                
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    struct MediumWidget: View {
        var entry: Provider.Entry
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                    .frame(width: 15)
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
                            .minimumScaleFactor(0.5)
                            .font(.system(size: 27))
                            .foregroundColor(Color.customBlue)
                        WeatherEmoji(entry: entry)
                    }
                    Text(entry.weather.location.name).bold()
                        .foregroundColor(Color.customBlue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.system(size: 25))
                        .minimumScaleFactor(0.5)
                    Text(entry.weather.location.country)
                        .foregroundColor(Color.customBlue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.5)
                    HStack(alignment: .center, spacing: 3) {
                        Text("↓").foregroundColor(.blue)
                            .font(.system(size: 12))
                        //                    Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
                        Text("5 ")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        Text("↑")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                        //                    Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
                        Text("12")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                    }
                    
                    HStack(alignment: .center, spacing: 3, content: {
                        Text("Last Update: ")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        
                        Text(entry.weather.time?.getCleanTime() ?? "None")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                    })
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Spacer()
                    ForEach(weatherList.dropFirst().prefix(5), id: \.self) { item in
                        HStack(spacing: 3) {
//                            Spacer()
//                                .frame(width: 15)
                            WeatherEmoji(entry: entry)
                            Text("\(item.location.name)")
                                .foregroundColor(Color.customBlue)
                                .font(.system(size: 12))
                                .lineLimit(nil)
                                .minimumScaleFactor(0.5)
                            Spacer()
                            Text("↓").foregroundColor(.blue)
                                .font(.system(size: 12))
                            //                        Spacer()
                            
                            Text(item.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
                                .foregroundColor(Color.customBlue)
                                .font(.system(size: 12))
                            //                        Spacer()
                            
                            Text("↑")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            //                        Spacer()
                            
                            Text(item.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
                                .foregroundColor(Color.customBlue)
                                .font(.system(size: 12))
                            Spacer()
                                .frame(width: 10)
                            
                        }.onAppear {
                            print("shit")
                        }

                    }
                    Spacer()
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    struct LargeWidget: View {
        var entry: Provider.Entry
        var body: some View {
            VStack {
                Spacer()
                    .frame(height: 20)
            HStack(alignment: .center, spacing: 60) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(entry.weather.location.name + ",").bold()
                            .foregroundColor(Color.customBlue)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .font(.system(size: 35))
                        Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
                            .font(.system(size: 35))
                            .foregroundColor(Color.customBlue)
                    }
                    Text(entry.weather.location.country)
                        .foregroundColor(Color.customBlue)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .font(.system(size: 28))
                        .minimumScaleFactor(0.8)
                    HStack {
                        Text(entry.weather.current.condition.text)
                            .foregroundColor(Color.customBlue)
                        .font(.system(size: 16))
                        WeatherEmoji(entry: entry)
                    }
                    
                    HStack(alignment: .top , spacing: 3) {
                        Text("↓").foregroundColor(.blue).bold()
                            .font(.system(size: 12))
                        //                    Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
                        Text("5 ")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        Text("↑").bold()
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                        //                    Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
                        Text("12")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                    }
                    
                    HStack(alignment: .center, spacing: 3) {
                        Text("Last Update: ")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        
                        Text(entry.weather.time?.getCleanTime() ?? "None")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                    }
                }
            }
            Spacer()
                    .frame(height: 15)
            VStack(alignment: .leading, spacing: 3) {

                ForEach(weatherList.dropFirst().prefix(7), id: \.self) { item in
                    HStack(spacing: 3) {
                        Spacer()
                            .frame(width: 15)
                        WeatherEmoji(entry: entry)
                        
                        Text("\(item.location.name)")
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 14))
                        Spacer()
                        Text("↓").foregroundColor(.blue)
                            .font(.system(size: 12))
                        //                        Spacer()
                        
                        Text(item.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        //                        Spacer()
                        
                        Text("↑")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                        //                        Spacer()
                        
                        Text(item.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
                            .foregroundColor(Color.customBlue)
                            .font(.system(size: 12))
                        Spacer()
                            .frame(width: 20)
                        
                    }.onAppear {
                        print("shit")
                    }
                }

            }
            
            }
            Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        
    }
    
    struct WeatherEmoji: View {
        var entry: Provider.Entry
        var body: some View {
            switch entry.weather.current.condition.text {
            case "Sunny" : Text("☀️") .font(.system(size: 20))
            case "Partly cloudy" : Text("🌤") .font(.system(size: 20))
            case "Cloudy" : Text("🌥") .font(.system(size: 20))
            case "Overcast" : Text("🌩") .font(.system(size: 20))
            case "Mist" : Text("💧") .font(.system(size: 20))
            case "Thundery outbreaks possible" : Text("⛈") .font(.system(size: 20))
            case "Blowing snow" : Text("🌬") .font(.system(size: 20))
            case "Fog" : Text("🌫") .font(.system(size: 20))
            case "Clear" : Text("🌤") .font(.system(size: 20))
            case "Light rain" : Text("☔️") .font(.system(size: 20))
            case "Heavy rain" : Text("🌧") .font(.system(size: 20))
            case "Light snow showers" : Text("❄️") .font(.system(size: 20))
            case "Light drizzle" : Text("🌧") .font(.system(size: 20))
            default: Text("🌤").font(.system(size: 20))
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
        .supportedFamilies([.systemSmall , .systemMedium , .systemLarge])
    }
}

struct WeatherNowWidget_Previews: PreviewProvider {
    
    let weather = WeatherModel(location: WeatherLocation.init(country: "", name: "", region: ""), current: CurrentWeather(temp_c: 0.0, condition: WeatherCondition(text: "")), forecast: Forecast(forecastday: [ForecastDay].init()), time: Date.init(), weatherUrl: "")
    
    static var previews: some View {
        WeatherNowWidgetEntryView(entry: SimpleEntry(date: Date(), weather: mockData, configuration: ConfigurationIntent()))
            .showWidgetPreviews(for: .systemSmall)
        
        WeatherNowWidgetEntryView(entry: SimpleEntry(date: Date(), weather: mockData, configuration: ConfigurationIntent()))
            .redacted(reason: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        //            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
    }
}


var forecastArray = [ForecastDay(day: Day(maxtemp_c: 20, mintemp_c: -2))]
var mockData = WeatherModel(location: WeatherLocation(country: "USA", name: "California", region: "LA"), current: CurrentWeather(temp_c: 12, condition: WeatherCondition(text: "Sunny")), forecast: Forecast(forecastday: forecastArray) , time: nil, weatherUrl: nil)
var weatherList: [WeatherModel] = []
//= [
//    WeatherModel(location: WeatherLocation(country: "Iran", name: "Tehran", region: "LA"), current: CurrentWeather(temp_c: 14, condition: WeatherCondition(text: "Sunny")), forecast: Forecast(forecastday: forecastArray) , time: nil, weatherUrl: nil),
//    WeatherModel(location: WeatherLocation(country: "USA", name: "California", region: "LA"), current: CurrentWeather(temp_c: 12, condition: WeatherCondition(text: "Sunny")), forecast: Forecast(forecastday: forecastArray) , time: nil, weatherUrl: nil)
//]

var locationList: [SearchLocationModel] = []
var expiredItems: [WeatherModel] = []
var forecast = [ForecastDay]()
var sampleData: WeatherModel = WeatherModel(location: WeatherLocation(country: "USA", name: "California", region: "LA"), current: CurrentWeather(temp_c: 25, condition: WeatherCondition(text: "Sunny")), forecast: Forecast(forecastday: forecast), time: Date(), weatherUrl: "")





func addPercentageToUrl(urlString : String) -> String{
    return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}

func getWeatherDataFromiPhone() {
    let userDefaults = UserDefaults(suiteName: "group.weatherNow")
    if let data = userDefaults?.object(forKey: "weatherForWidget") {
        do {
            let decoder = JSONDecoder()
            weatherList = try decoder.decode([WeatherModel].self, from: data as! Data)
            print("weatherList.count is \(weatherList)")
            print("Widget got Weather Data From iPhone")
        } catch {
            print("Unable to Decode weatherData (\(error))")
        }
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
        } catch {
            print("Widget: Unable to Decode weatherData (\(error))")
        }
    }
}

extension Color {
    static let customBlue = Color(red: 109.0/255.0, green: 154.0/255.0, blue: 242.0/255.0)
}

extension View {
    
    func showWidgetPreviews(for family: WidgetFamily) -> some View {
        Group {
            let devices = ["iPhone 13" , "iPhone SE"] //, "iPhone 11 pro Max", "iPhone SE"]
            ForEach(devices, id:\.self) { device in
                self
                //                    .previewContext(WidgetPreviewContext(family: .systemMedium))
                    .previewContext(WidgetPreviewContext(family: .systemLarge))
                
                    .previewDevice(PreviewDevice(rawValue: device))
                    .colorScheme(.light)
                    .previewDisplayName(device)
                
                self
                    .previewContext(WidgetPreviewContext(family: family))
                    .previewDevice(PreviewDevice(rawValue: device))
                    .colorScheme(.dark)
                    .previewDisplayName(device)
            }
        }
    }
}
