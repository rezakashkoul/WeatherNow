//
//  SearchViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import UIKit

protocol SearchViewControllerDelegate {
    func passingData(data: WeatherModel)
}

class SearchViewController: UIViewController  {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSearchActionWhileTyping()
        }
    }
    
    var weatherObjects : [WeatherModel]?
    var searchDelegate : SearchViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        cancelButton.layer.cornerRadius = 20
        //overrideUserInterfaceStyle = .light
        tableView.keyboardDismissMode = .onDrag
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 20
        searchTextField.layer.borderColor = UIColor.customBlue.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.attributedPlaceholder = NSAttributedString(string: " Enter City Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.customBlue])
        
    }
    
    func calculateRequestTime() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        print("the hour is \(hour)")
    }
    
    func doSearchActionWhileTyping() {
        DispatchQueue.main.async {
            if self.searchTextField.text!.count >= 3 {
                self.performSearch()
            }
        }
    }
    
    func performSearch() {
        getDataFromApi()
        tableView.reloadData()
    }
    
    func getDataFromApi() {
        //api.openweathermap.org/data/2.5/weather?q=tehran&appid=a7acbfef3e0f470c7336e452e1a3c002
        guard let urlString = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(searchTextField.text!)&units=metric&appid=a7acbfef3e0f470c7336e452e1a3c002") else { return }
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            if let data = data , error == nil {
                self.parse(json: data)
            }
        }
        task.resume()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        do {
            var weatherObject = try decoder.decode(WeatherModel.self, from: json)
            DispatchQueue.main.async {
                weatherObject.name = weatherObject.name.folding(options: .diacriticInsensitive, locale: .current)
             //   weatherObject.name = self.searchTextField.text!
                self.weatherObjects = [weatherObject]
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Parsing Error: \(error)")
        }
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = weatherObjects?[indexPath.row].name //.folding(options: .diacriticInsensitive, locale: .current)
        cell.minTemp.text = weatherObjects?[indexPath.row].main.temp_min.rounded().clean.description
        cell.maxTemp.text = weatherObjects?[indexPath.row].main.temp_max.rounded().clean.description
        setCellWeatherCondition(indexPath, cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        weatherObjects![indexPath.row].name = weatherObjects![indexPath.row].name.folding(options: .diacriticInsensitive, locale: .current)
        searchDelegate.passingData(data: weatherObjects![indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func setCellWeatherCondition(_ indexPath: IndexPath, _ cell: TableViewCell) {
        switch weatherObjects?[indexPath.row].weather[0].main.description {
        case "Clear" : cell.skyLabel.text = "🌤"
        case "Clouds" : cell.skyLabel.text = "🌥"
        case "Snow" : cell.skyLabel.text = "❄️"
        case "Drizzle" : cell.skyLabel.text = "🌧"
        case "Thunderstorm" : cell.skyLabel.text = "⛈"
        default:
            cell.skyLabel.text = "☀️"
        }
    }
}

extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
}

