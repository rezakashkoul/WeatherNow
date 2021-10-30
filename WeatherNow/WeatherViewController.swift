//
//  WeatherViewController.swift
//
//  Created by Reza Kashkoul on 28-Mehr-1400.
//

import UIKit

class WeatherViewController: UIViewController , SearchViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skyLabel: UILabel!
    @IBOutlet weak var topTemperatureLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var topLocationLabel: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var sortListButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var upArrow: UILabel!
    @IBOutlet weak var downArrow: UILabel!
    
    @IBAction func sortListButtonAction(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            sortListButton.setTitle("Sort List", for: .normal)
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
    
    let updateTime = Date()
    var weatherData : WeatherModel!
    var weatherList : [WeatherModel] = []
    var expiredItems : [WeatherModel] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadWeatherData()
       // overrideUserInterfaceStyle = .light
        tableView.separatorStyle = .none
        addCityButton.layer.cornerRadius = 20
        sortListButton.layer.cornerRadius = 20
        setTopViewWeatherData()
        fetchData()
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { (timer) in
            self.fetchData()
            print("Update by timer")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
//        Array(Set(weatherList))
    //    weatherList = Array(Set(weatherList))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTopViewWeatherData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func fetchData() {
        var counter = 0
        expiredItems = weatherList.filter({ $0.time!.timeIntervalSinceNow < -120})
        print("expiredItems.count", expiredItems.count)
        for item in expiredItems {
            counter += 1
            print("expired itme : \(item.name.folding(options: .diacriticInsensitive, locale: .current)))")
            if let urlString = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(item.name.folding(options: .diacriticInsensitive, locale: .current))&units=metric&appid=a7acbfef3e0f470c7336e452e1a3c002") {
                let task = URLSession.shared.dataTask(with: urlString) { [self] data, response, error in
                    if let data = data , error == nil {
                        self.parse(json: data)
                        if counter == expiredItems.count {
                            DispatchQueue.main.async {
                                self.saveWeatherData()
                                self.tableView.reloadData()
                                self.setTopViewWeatherData()
                            }
                        }
                    } else {
                        //print("kish Error: \(String(describing: error))")
                        print("errorrrr")
                    }
                    
                }
                task.resume()
            }
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        do {
            var weatherObject = try decoder.decode(WeatherModel.self, from: json)
            weatherObject.time = Date()
            for i in 0..<weatherList.count {
                  weatherObject.name = weatherObject.name.folding(options: .diacriticInsensitive, locale: .current)
                if weatherList[i].name == weatherObject.name.folding(options: .diacriticInsensitive, locale: .current) {
                    weatherList[i] = weatherObject
                }
            }
            print("**\(weatherObject)***")
        } catch let error as NSError {
            print("Parsing Error: \(error)")
        }
    }
    
    func setTopViewWeatherData() {
        
        DispatchQueue.main.async {
            if self.weatherList.count != 0 {
                self.topTemperatureLabel.text = self.weatherList[0].main.temp.rounded().clean.description + " °"
                self.setTopViewWeatherCondition()
                self.updateTimeLabel.text = " Last Update " + (self.weatherList[0].time?.getCleanTime().description)!
                self.topLocationLabel.text = self.weatherList[0].name + ", " + self.weatherList[0].sys.country
                self.minTemp.text = self.weatherList[0].main.temp_min.rounded().clean.description
                self.maxTemp.text = self.weatherList[0].main.temp_max.rounded().clean.description
            } else {
                self.topTemperatureLabel.text = "Add a City"
                self.updateTimeLabel.text = ""
                self.topLocationLabel.text = "From here👇🏼"
                self.minTemp.text = ""
                self.maxTemp.text = ""
                self.upArrow.isHidden = true
                self.downArrow.isHidden = true
            }
        }
    }
    
    func setTopViewWeatherCondition() {
        switch weatherList[0].weather[0].main.description {
        case "Clear" : skyLabel.text = "🌤"
        case "Clouds" : skyLabel.text = "🌥"
        case "Snow" : skyLabel.text = "❄️"
        case "Drizzle" : skyLabel.text = "🌧"
        case "Thunderstorm" : skyLabel.text = "⛈"
        default:
            skyLabel.text = "☀️"
        }
    }
    
    func setCellWeatherCondition(_ indexPath: IndexPath, _ cell: TableViewCell) {
        switch weatherList[indexPath.row].weather[0].main.description {
        case "Clear" : cell.skyLabel.text = "🌤"
        case "Clouds" : cell.skyLabel.text = "🌥"
        case "Snow" : cell.skyLabel.text = "❄️"
        case "Drizzle" : cell.skyLabel.text = "🌧"
        case "Thunderstorm" : cell.skyLabel.text = "⛈"
        default:
            cell.skyLabel.text = "☀️"
        }
    }
    
    func passingData(data: WeatherModel) {
        weatherData = data
        //   guard let passedData = weatherData else { return }
        weatherData.time = Date()
        weatherData.name = weatherData.name.folding(options: .diacriticInsensitive, locale: .current)
        
        if weatherList.contains(where: {$0.name == weatherData.name }) {
            print("repetitve item")
            let alert = UIAlertController(title: "Repetitve City", message: "\(weatherData.name) already exist in your list. Please add another city.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
   
        } else {
        weatherList.append(weatherData)
        tableView.reloadData()
        saveWeatherData()
        }
    }
    
    func saveWeatherData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weatherList)
            UserDefaults.standard.set(data, forKey: "weather")
            
        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    func loadWeatherData() {
        if let data = UserDefaults.standard.data(forKey: "weather") {
            do {
                let decoder = JSONDecoder()
                weatherList = try decoder.decode([WeatherModel].self, from: data)
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
}

extension WeatherViewController : UITableViewDataSource , UITableViewDelegate {
    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = weatherList[indexPath.row].name + ", " + weatherList[indexPath.row].sys.country
        cell.minTemp.text = weatherList[indexPath.row].main.temp_min.rounded().clean.description
        cell.maxTemp.text = weatherList[indexPath.row].main.temp_max.rounded().clean.description
        setCellWeatherCondition(indexPath, cell)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let reorderedItem = weatherList[sourceIndexPath.row]
        weatherList.remove(at: sourceIndexPath.row)
        weatherList.insert(reorderedItem, at: destinationIndexPath.row)
        setTopViewWeatherData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            weatherList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            saveWeatherData()
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
    // Change default icon (hamburger) for moving cells in UITableView
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let imageView = cell.subviews.first(where: { $0.description.contains("Reorder") })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView

         imageView?.image = UIImage(systemName: "list.bullet") // give here your's new image
         imageView?.contentMode = .center

         imageView?.frame.size.width = cell.bounds.height
         imageView?.frame.size.height = cell.bounds.height
     }
}

