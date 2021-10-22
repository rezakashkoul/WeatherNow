//
//  WeatherViewController.swift
//  WeatherNow
//
//  Created by Reza Kashkoul on 28-Mehr-1400.
//

import UIKit

class WeatherViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
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
        
    }
    
    @IBAction func addCityButtonAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    var weatherData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        overrideUserInterfaceStyle = .light
        addCityButton.layer.cornerRadius = 20
        sortListButton.layer.cornerRadius = 20
    
        
        
        
    }
    

    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension WeatherViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        return cell
        
    }
    
}
