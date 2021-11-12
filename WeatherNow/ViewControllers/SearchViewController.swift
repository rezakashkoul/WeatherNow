//
//  SearchViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 29-Mehr-1400.
//

import UIKit
import Reachability

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
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkInternetConnectionAndRequest()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachability.stopNotifier()
    }
    
    func doSearchActionWhileTyping() {
        DispatchQueue.main.async {
            if self.searchTextField.text!.count >= 3 {
                self.performSearch()
            }
        }
    }
    
    func setupView() {
        setupTableView()
        cancelButton.layer.cornerRadius = 20
        setupSearchTextField()
    }
    
    func performSearch() {
        getSearchLocationFromApi()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getSearchLocationFromApi() {
        if let urlString = URL(string: "https://api.weatherapi.com/v1/search.json?key=ec51c5f169d2409b85293311210511&q=\(searchTextField.text!)") {
            let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                }
                if error != nil {
                    print("error in request")
                    DispatchQueue.main.async {
                        self.showErrorInFetchingData()
                    }
                }
                if let data = data , error == nil {
                    self.parseLocation(json: data)
                } else {
                    print("\(String(describing: error)) in parsing locations")
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                self.showPlaceNameError()
            }
        }
    }
    
    func parseLocation(json: Data) {
        let decoder = JSONDecoder()
        do {
            let locationObject = try decoder.decode([SearchLocationModel].self, from: json)
            if locationObject.isEmpty == true {
                DispatchQueue.main.async {
                    self.showPlaceNameError()
                }
            }
            DispatchQueue.main.async {
                self.locationObjects = locationObject
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Location Parsing Error: \(error)")
        }
    }
    
    func checkInternetConnectionAndRequest() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                print("Connected to the internet")
                self.performSearch()
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not Connected")
            DispatchQueue.main.async {
                self.showInternetConnectionError()
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

//MARK: Alert Extension
extension SearchViewController {
    
    func showErrorInFetchingData() {
        let alert = UIAlertController(title: "Error", message: "Due to poor internet connection, cannot access to updated weather data, Please check your internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showPlaceNameError() {
        let alert = UIAlertController(title: "Error in Place Name", message: "Please make sure the city you're looking for is in the correct form." , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: nil))
        present(alert, animated: true, completion: .none)
    }
    func showInternetConnectionError() {
        let alert = UIAlertController(title: "No Connection", message: "No internet connection, connect to the internet and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


//MARK: TableView Extension
extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
    
    func setupTableView() {
        //tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
    }
    
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
    
    func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 20
        searchTextField.clipsToBounds = true
        searchTextField.layer.borderColor = UIColor.customBlue.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Enter City Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.customBlue])
        searchTextField.textAlignment = .center
    }
}
