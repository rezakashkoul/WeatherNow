//
//  WeatherViewController.swift
//
//  Created by Reza Kashkoul on 28-Mehr-1400.
//

import UIKit
import QuartzCore
import Reachability

class WeatherViewController: UIViewController , SearchViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skyLabel: UILabel!
    @IBOutlet weak var topTemperatureLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var topLocationLabel: MarqueeLabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var sortListButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var upArrow: UILabel!
    @IBOutlet weak var downArrow: UILabel!
    @IBOutlet weak var listStatus: UILabel!
    
    @IBAction func sortListButtonAction(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            sortListButton.setTitle("Sort List", for: .normal)
            saveLocationData()
            saveWeatherData()
        } else {
            tableView.setEditing(true, animated: true)
            sortListButton.setTitle("Done", for: .normal)
        }
    }
    
    @IBAction func addCityButtonAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.searchDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var locationData : SearchLocationModel!
    var weatherData : WeatherModel!
    var weatherList : [WeatherModel] = []
    var locationList : [SearchLocationModel] = []
    var expiredItems : [WeatherModel] = []
    var timer: Timer?
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadWeatherData()
        loadLocationData()
        trigerTimer()
        checkInternetConnectionAndRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTopViewWeatherData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachability.stopNotifier()
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
    
    func getWeather() {
        let fixedUrl = addPercentageToUrl(urlString: "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(locationData.url)&days=1&aqi=no&alerts=no")
        if let urlString = URL(string: fixedUrl) {
            let task = URLSession.shared.dataTask(with: urlString) { [self] data, response, error in
                if let data = data , error == nil {
                    self.parseNewWeather(json: data)
                    DispatchQueue.main.async {
                        self.saveWeatherData()
                        self.saveLocationData()
                        self.tableView.reloadData()
                        self.setTopViewWeatherData()
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
                                self.saveWeatherData()
                                self.saveLocationData()
                                self.tableView.reloadData()
                                self.setTopViewWeatherData()
                            }
                        }
                    } else {
                        print("Error in fetching data")
                        DispatchQueue.main.async {
                            self.showErrorInFetchingData()
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
            saveLocationData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
            saveWeatherData()
            saveLocationData()
        } catch {
            print("Weather Parsing Error: \(error)")
        }
    }
    
    func transferData(data: SearchLocationModel) {
        locationData = data
        locationData.time = Date()
        if locationList.contains(where: {$0.url == locationData.url}) {
            print("Repeatitve item")
            let alert = UIAlertController(title: "Repeatitve City", message: " \(locationData.name.split(separator: ",").first ?? "This city") has been already exist in your list. Please add another city.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            locationList.append(locationData)
            getWeather()
            saveLocationData()
        }
    }
    
    func saveLocationData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(locationList)
            UserDefaults.standard.set(data, forKey: "location")
        } catch {
            print("Unable to Encode LocationData (\(error))")
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
    
    func saveWeatherData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weatherList)
            UserDefaults.standard.set(data, forKey: "weather")
        } catch {
            print("Unable to Encode weatherData (\(error))")
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
    
    func checkInternetConnectionAndRequest() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                print("Connected to the internet")
                self.updateWeather()
                self.trigerTimer()
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not Connected")
            DispatchQueue.main.async {
                self.showInternetConnectionError()
                self.updateTimeLabel.text = "Expired Data. \n Last Update " + (self.weatherList[0].time?.getCleanTime().description)!
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func showErrorInFetchingData() {
        let alert = UIAlertController(title: "Error", message: "Due to poor internet connection, cannot access to updated weather data, Please check your internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showInternetConnectionError() {
        let alert = UIAlertController(title: "No Connection", message: "No internet connection, connect to the internet and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: Setup View Extension
extension WeatherViewController {
    
    func setupView() {
        setTopViewWeatherData()
        setupTableView()
        addCityButton.layer.cornerRadius = 20
        sortListButton.layer.cornerRadius = 20
    }
    
    func setTopViewWeatherData() {
        if weatherList.count != 0 {
            listStatus.isHidden = true
            tableView.isHidden = false
            sortListButton.isEnabled = true
            topTemperatureLabel.text = self.weatherList[0].current.temp_c.rounded().clean.description + " °"
            setTopViewWeatherCondition()
            updateTimeLabel.text = " Last Update " + (self.weatherList[0].time?.getCleanTime().description)!
            topLocationLabel.text = self.weatherList[0].location.name + ", " + self.weatherList[0].location.country
            minTemp.text = self.weatherList[0].forecast.forecastday[0].day.mintemp_c.rounded().clean.description
            maxTemp.text = self.weatherList[0].forecast.forecastday[0].day.maxtemp_c.rounded().clean.description
            upArrow.isHidden = false
            downArrow.isHidden = false
        } else {
            listStatus.isHidden = false
            tableView.isHidden = true
            sortListButton.isEnabled = false
            topTemperatureLabel.text = "Add a City"
            updateTimeLabel.text = ""
            topLocationLabel.text = "From here👇🏼"
            minTemp.text = ""
            maxTemp.text = ""
            upArrow.isHidden = true
            downArrow.isHidden = true
        }
    }
    
    func setTopViewWeatherCondition() {
        switch weatherList[0].current.condition.text {
        case "Sunny" : skyLabel.text = "☀️"
        case "Partly cloudy" : skyLabel.text = "🌤"
        case "Cloudy" : skyLabel.text = "🌥"
        case "Overcast" : skyLabel.text = "🌩"
        case "Mist" : skyLabel.text = "💧"
        case "Thundery outbreaks possible" : skyLabel.text = "⛈"
        case "Blowing snow" : skyLabel.text = "🌬"
        case "Fog" : skyLabel.text = "🌫"
        case "Clear" : skyLabel.text = "🌤"
        case "Light rain" : skyLabel.text = "☔️"
        case "Heavy rain" : skyLabel.text = "🌧"
        case "Light snow showers" : skyLabel.text = "❄️"
        case "Light drizzle" : skyLabel.text = "🌧"
        default:
            skyLabel.text = "？"
        }
    }
}

//MARK: TableView Extension
extension WeatherViewController : UITableViewDataSource , UITableViewDelegate {
    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = weatherList[indexPath.row].location.name + ", " + weatherList[indexPath.row].location.country
        cell.minTemp.text = weatherList[indexPath.row].forecast.forecastday[0].day.mintemp_c.rounded().clean.description
        cell.maxTemp.text = weatherList[indexPath.row].forecast.forecastday[0].day.maxtemp_c.rounded().clean.description
        setCellWeatherCondition(indexPath, cell)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func setCellWeatherCondition(_ indexPath: IndexPath, _ cell: TableViewCell) {
        switch weatherList[indexPath.row].current.condition.text {
        case "Sunny" : cell.skyLabel.text = "☀️"
        case "Partly cloudy" : cell.skyLabel.text = "🌤"
        case "Cloudy" : cell.skyLabel.text = "🌥"
        case "Overcast" : cell.skyLabel.text = "🌩"
        case "Mist" : cell.skyLabel.text = "💧"
        case "Thundery outbreaks possible" : cell.skyLabel.text = "⛈"
        case "Blowing snow" : cell.skyLabel.text = "🌬"
        case "Fog" : cell.skyLabel.text = "🌫"
        case "Clear" : cell.skyLabel.text = "🌤"
        case "Light rain" : cell.skyLabel.text = "☔️"
        case "Heavy rain" : cell.skyLabel.text = "🌧"
        case "Light snow showers" : cell.skyLabel.text = "❄️"
        case "Light drizzle" : cell.skyLabel.text = "🌧"
        default:
            cell.skyLabel.text = "？"
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let reorderedItem = weatherList[sourceIndexPath.row]
        weatherList.remove(at: sourceIndexPath.row)
        locationList.remove(at: sourceIndexPath.row)
        weatherList.insert(reorderedItem, at: destinationIndexPath.row)
        locationList.insert(locationList[sourceIndexPath.row], at: destinationIndexPath.row)
        setTopViewWeatherData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            weatherList.remove(at: indexPath.row)
            locationList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            saveWeatherData()
            saveLocationData()
            setTopViewWeatherData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if tableView.isEditing == false {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
