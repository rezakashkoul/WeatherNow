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
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        //        DispatchQueue.global(qos: .userInitiated).async {
        //            self.doSearchActionWhileTyping()
        //        }
    }
    
    //    var weatherObjects = [WeatherModel(weather: [], main: Main(), sys: Sys(), name: Name())]
    var weatherObjects : [WeatherModel]?
    var searchDelegate : SearchViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        cancelButton.layer.cornerRadius = 20
        overrideUserInterfaceStyle = .light
        tableView.keyboardDismissMode = .onDrag
        searchTextField.delegate = self
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
            let weatherObject = try decoder.decode(WeatherModel.self, from: json)
            DispatchQueue.main.async {
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
        cell.cityLabel.text = weatherObjects?[indexPath.row].name
        cell.minTemp.text = weatherObjects?[indexPath.row].main.temp_min.description
        cell.maxTemp.text = weatherObjects?[indexPath.row].main.temp_max.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchDelegate.passingData(data: weatherObjects![indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
}

