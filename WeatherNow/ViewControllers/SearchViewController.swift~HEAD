//
//  SearchViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import UIKit

protocol SearchViewControllerDelegate {
    func transferData(data: SearchLocationModel)
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
    
    var locationObjects : [SearchLocationModel]!
    var searchDelegate : SearchViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        cancelButton.layer.cornerRadius = 20
        tableView.keyboardDismissMode = .onDrag
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 20
        searchTextField.layer.borderColor = UIColor.customBlue.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.attributedPlaceholder = NSAttributedString(string: " Enter City Name",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.customBlue])
    }
    
    func doSearchActionWhileTyping() {
        DispatchQueue.main.async {
            if self.searchTextField.text!.count >= 3 {
                self.performSearch()
            }
        }
    }
    
    func performSearch() {
        getSearchLocationFromApi()
        tableView.reloadData()
    }
    
    func getSearchLocationFromApi() {
        //    https://api.weatherapi.com/v1/search.json?key=67b477a0e3404afeb5891850213110&q=tehran
        if let urlString = URL(string: "https://api.weatherapi.com/v1/search.json?key=ec51c5f169d2409b85293311210511&q=\(searchTextField.text!)") {
            let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                }
                if let data = data , error == nil {
                    self.parseLocation(json: data)
                } else {
                    print("\(String(describing: error)) in parsing locations")
                }
            }
            task.resume()
        } else {
            let alert = UIAlertController(title: "Error in Place Name", message: "Please make sure the city you're looking for is in correct form.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: nil))
        }
    }
    
    func parseLocation(json: Data) {
        let decoder = JSONDecoder()
        do {
            let locationObject = try decoder.decode([SearchLocationModel].self, from: json)
            DispatchQueue.main.async {
                self.locationObjects = locationObject
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Location Parsing Error: \(error)")
        }
    }
    
    func setupTableView() {
        //tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: TableView Extension
extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = locationObjects?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //locationObjects![indexPath.row].time = Date()
        searchDelegate.transferData(data: locationObjects![indexPath.row])
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
