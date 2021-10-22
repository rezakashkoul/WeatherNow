//
//  SearchViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import UIKit

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
    
    var weatherObjects : [WeatherModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        cancelButton.layer.cornerRadius = 20
        overrideUserInterfaceStyle = .light
        tableView.keyboardDismissMode = .onDrag
        searchTextField.delegate = self
    }
    
    //api.openweathermap.org/data/2.5/weather?q=tehran&appid=a7acbfef3e0f470c7336e452e1a3c002
    
    
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
        
        //        let urlString =  "https://api.openweathermap.org/data/2.5/weather?q=\(searchTextField.text!)&appid=a7acbfef3e0f470c7336e452e1a3c002"
        //        print(urlString)
        //
        //        if let url = URL(string: urlString) {
        //            if let data = try? Data(contentsOf: url) {
        //                parse(json: data)
        //            }
        //        }
        
        guard let urlString = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(searchTextField.text!)&appid=a7acbfef3e0f470c7336e452e1a3c002") else { return }
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            if let data = data , error == nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else { return }
                    self.parse(json: data)
                    print("****\(json)********")
                    
                    DispatchQueue.main.async {
                        print("AAAAA\(json)AAAAA")

                        self.tableView.reloadData()
                    }
                }
                catch {
                    print("Errorrrr")
                }
            }
        }
        task.resume()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let weatherData = try? decoder.decode([WeatherModel].self, from: json) {
            weatherObjects = weatherData
            
            print("******\(weatherData)******")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        return weatherObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.cityLabel.text = weatherObjects[indexPath.row].name.name
        cell.minTemp.text = (((weatherObjects[indexPath.row].main.temp_min ?? 0) - 32) / 1.8).description
        cell.maxTemp.text = (((weatherObjects[indexPath.row].main.temp_max ?? 0) - 32) / 1.8).description

        
        return cell
        
    }
    
}
extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
}
