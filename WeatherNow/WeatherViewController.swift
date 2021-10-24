//
//  WeatherViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 28-Mehr-1400.
//

import UIKit

class WeatherViewController: UIViewController , SearchViewControllerDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var topTemperatureLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var topLocationLabel: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var sortListButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    
    @IBAction func sortListButtonAction(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            saveWeatherData()
        } else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func addCityButtonAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.searchDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var weatherData : WeatherModel!
    var weatherList : [WeatherModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadWeatherData()
        overrideUserInterfaceStyle = .light
        addCityButton.layer.cornerRadius = 20
        sortListButton.layer.cornerRadius = 20
    }
    
    func passingData(data: WeatherModel) {
        weatherData = data
        guard let passedData = weatherData else { return }
        weatherList.append(passedData)
        tableView.reloadData()
        saveWeatherData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = weatherList[indexPath.row].name + ", " + weatherList[indexPath.row].sys.country
        cell.minTemp.text = weatherList[indexPath.row].main.temp_min.toCelsius.description
        cell.maxTemp.text = weatherList[indexPath.row].main.temp_max.toCelsius.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let reorderedItem = weatherList[sourceIndexPath.row]
        weatherList.remove(at: sourceIndexPath.row)
        weatherList.insert(reorderedItem, at: destinationIndexPath.row)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            weatherList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            saveWeatherData()
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
