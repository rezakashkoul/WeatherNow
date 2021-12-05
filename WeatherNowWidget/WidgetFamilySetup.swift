////
////  WidgetFamily.swift
////  WeatherNowWidgetExtension
////
////  Created by Reza Kashkoul on 14/Azar/1400 .
////
//
//import Foundation
//import SwiftUI
//
//
//struct WidgetEmoji: View {
//    var input: WeatherModel
//    var body: some View {
//        switch input.current.condition.text {
//        case "Sunny" : Text("☀️") .font(.system(size: 20))
//        case "Partly cloudy" : Text("🌤") .font(.system(size: 20))
//        case "Cloudy" : Text("🌥") .font(.system(size: 20))
//        case "Overcast" : Text("🌩") .font(.system(size: 20))
//        case "Mist" : Text("💧") .font(.system(size: 20))
//        case "Thundery outbreaks possible" : Text("⛈") .font(.system(size: 20))
//        case "Blowing snow" : Text("🌬") .font(.system(size: 20))
//        case "Fog" : Text("🌫") .font(.system(size: 20))
//        case "Clear" : Text("🌤") .font(.system(size: 20))
//        case "Light rain" : Text("☔️") .font(.system(size: 20))
//        case "Heavy rain" : Text("🌧") .font(.system(size: 20))
//        case "Light snow showers" : Text("❄️") .font(.system(size: 20))
//        case "Light drizzle" : Text("🌧") .font(.system(size: 20))
//        default: Text("🌤").font(.system(size: 20))
//        }
//    }
//}
//
//
//struct SmallWidget: View {
//    var entry: Provider.Entry
//    var body: some View {
//        HStack {
//            Spacer()
//        VStack(alignment: .leading) {
//            Spacer()
//                HStack {
////                        Spacer()
//                Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
//                    .minimumScaleFactor(0.5)
//                    .font(.system(size: 27))
//                    .foregroundColor(Color.customBlue)
//                WidgetEmoji(input: entry.weather)
//            }
//            Spacer()
//            Text(entry.weather.location.name).bold()
//                .foregroundColor(Color.customBlue)
//                .multilineTextAlignment(.leading)
//                .lineLimit(1)
//                .font(.system(size: 25))
//                .minimumScaleFactor(0.5)
//            Spacer()
//            Text(entry.weather.location.country)
//                .foregroundColor(Color.customBlue)
//                .multilineTextAlignment(.leading)
//                .lineLimit(1)
//                .font(.system(size: 14))
//                .minimumScaleFactor(0.5)
//            Spacer()
//            HStack(alignment: .center, spacing: 3) {
//                Text("↓").foregroundColor(.blue)
//                    .font(.system(size: 12))
//                Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
//                    .foregroundColor(Color.customBlue)
//                    .font(.system(size: 12))
//                Text("↑")
//                    .foregroundColor(.red)
//                    .font(.system(size: 12))
//                Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
//                    .foregroundColor(Color.customBlue)
//                    .font(.system(size: 12))
//                Spacer()
//            }
//            Spacer()
//            HStack(alignment: .center, spacing: 3) {
//                Text("Last Update: ")
//                    .foregroundColor(Color.customBlue)
//                    .font(.system(size: 12))
//                
//                Text(entry.weather.time?.getCleanTime() ?? "None")
//                    .foregroundColor(Color.customBlue)
//                    .font(.system(size: 12))
//            }
//            .padding(.bottom)
//        }
//            Spacer()
//
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground))
//    }
//}
//
//struct MediumWidget: View {
//    var entry: Provider.Entry
//    var body: some View {
//        HStack(alignment: .center, spacing: 10) {
//            Spacer()
//                .frame(width: 15)
//            VStack(alignment: .leading) {
//                Spacer()
//                    HStack {
////                        Spacer()
//                    Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
//                        .minimumScaleFactor(0.5)
//                        .font(.system(size: 27))
//                        .foregroundColor(Color.customBlue)
//                    WidgetEmoji(input: entry.weather)
//                }
//                Spacer()
//                Text(entry.weather.location.name).bold()
//                    .foregroundColor(Color.customBlue)
//                    .multilineTextAlignment(.leading)
//                    .lineLimit(1)
//                    .font(.system(size: 25))
//                    .minimumScaleFactor(0.5)
//                Spacer()
//                Text(entry.weather.location.country)
//                    .foregroundColor(Color.customBlue)
//                    .multilineTextAlignment(.leading)
//                    .lineLimit(1)
//                    .font(.system(size: 14))
//                    .minimumScaleFactor(0.5)
//                Spacer()
//                HStack(alignment: .center, spacing: 3) {
//                    Text("↓").foregroundColor(.blue)
//                        .font(.system(size: 12))
//                    Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
//                        .foregroundColor(Color.customBlue)
//                        .font(.system(size: 12))
//                    Text("↑")
//                        .foregroundColor(.red)
//                        .font(.system(size: 12))
//                    Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
//                        .foregroundColor(Color.customBlue)
//                        .font(.system(size: 12))
//                    Spacer()
//                }
//                Spacer()
//                HStack(alignment: .center, spacing: 3) {
//                    Text("Last Update: ")
//                        .foregroundColor(Color.customBlue)
//                        .font(.system(size: 12))
//                    
//                    Text(entry.weather.time?.getCleanTime() ?? "None")
//                        .foregroundColor(Color.customBlue)
//                        .font(.system(size: 12))
//                }
//                .padding(.bottom)
//            }
//                Spacer()
//
//            
//            VStack(alignment: .leading, spacing: 3) {
//                Spacer()
//                ForEach(weatherList.dropFirst().prefix(5), id: \.self) { item in
//                    HStack(spacing: 0) {
//                        WidgetEmoji(input: item)
//                        
//                        Text("\(item.location.name)")
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                            .lineLimit(1)
////                                .minimumScaleFactor(0.8)
//                        Spacer()
//                        Text("↓").foregroundColor(.blue)
//                            .font(.system(size: 12))
//                        Text(item.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        Text("↑")
//                            .foregroundColor(.red)
//                            .font(.system(size: 12))
//                        Text(item.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        Spacer()
//                            .frame(width: 10)
//                    }.onAppear {
//                        print("shit")
//                    }
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground))
//    }
//}
//
//struct LargeWidget: View {
//    var entry: Provider.Entry
//    var body: some View {
//        VStack {
//            Spacer()
//                .frame(height: 20)
//            HStack(alignment: .top, spacing: 60) {
//                VStack(alignment: .center, spacing: 0) {
//                    HStack(alignment: .center, spacing: 0) {
//                        Spacer()
//                        Text(entry.weather.location.name + ",").bold()
//                            .foregroundColor(Color.customBlue)
//                            .multilineTextAlignment(.leading)
//                            .lineLimit(1)
//                            .font(.system(size: 35))
//                            .minimumScaleFactor(0.8)
//                        Text(entry.weather.current.temp_c.rounded().clean.description + " °C")
//                            .font(.system(size: 35))
//                            .foregroundColor(Color.customBlue)
//                        Spacer()
//                    }
//                    Text(entry.weather.location.country)
//                        .foregroundColor(Color.customBlue)
//                        .multilineTextAlignment(.leading)
//                        .lineLimit(1)
//                        .font(.system(size: 28))
//                        .minimumScaleFactor(0.8)
//                    HStack {
//                        Text(entry.weather.current.condition.text)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 16))
//                        WidgetEmoji(input: entry.weather)
//                    }
//                    
//                    HStack(alignment: .top , spacing: 3) {
//                        Text("↓").foregroundColor(.blue).bold()
//                            .font(.system(size: 12))
//                        Text(entry.weather.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        Text("↑").bold()
//                            .foregroundColor(.red)
//                            .font(.system(size: 12))
//                        Text(entry.weather.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                    }
//                    HStack(alignment: .center, spacing: 3) {
//                        Text("Last Update: ")
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        
//                        Text(entry.weather.time?.getCleanTime() ?? "None")
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                    }
//                    Spacer()
////                            .frame(height: 20)
//                }
//                
//            }
//            Spacer()
//                .frame(height: 15)
//            VStack(alignment: .leading, spacing: 3) {
//                
//                ForEach(weatherList.dropFirst().prefix(7), id: \.self) { item in
//                    HStack(spacing: 3) {
//                        Spacer()
//                            .frame(width: 15)
//                        WidgetEmoji(input: item)
////                            Spacer()
//
//                        Text("\(item.location.name)")
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 14))
//                        Spacer()
//                        Text("↓").foregroundColor(.blue)
//                            .font(.system(size: 12))
//                        Text(item.forecast.forecastday[0].day.mintemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        Text("↑")
//                            .foregroundColor(.red)
//                            .font(.system(size: 12))
//                        Text(item.forecast.forecastday[0].day.maxtemp_c.rounded().clean.description)
//                            .foregroundColor(Color.customBlue)
//                            .font(.system(size: 12))
//                        Spacer()
//                            .frame(width: 20)
//                        
//                    }.onAppear {
//                        print("shit")
//                    }
//                }
//                Spacer()
//            }
//        }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(.systemBackground))
//    }
//}
//
