//
//  ViewController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/22.
//

import UIKit
import CoreLocation
import Network

class HomeController: UIViewController {
    
    /// Variables
    private var fiveDayForecast = [ForecastObject]()
    private var locationManager: CLLocationManager!
    private var contentViewColour = UIColor()
    var cityName = String()
    var latitude = Double()
    var longitude = Double()
    var favoriteCheck = false
    var mapCheck = false
    private var viewsSet: Bool! {
        didSet {
            DispatchQueue.main.async {
                self.animateActivityIndicator(should: false)
                self.tableView.reloadData()
                
                if self.favoriteCheck || self.mapCheck {
                    self.navigationItem.title = self.cityName
                }
                
                // Perform animation
                UIView.animate(withDuration: 1.5) {
                    self.degreeLabel.alpha = 1
                    self.symbolOne.alpha = 1
                }
            }
        }
    }
    
    /// Outlets
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var symbolOne: UIImageView!
    @IBOutlet weak var symbolTwo: UIImageView!
    @IBOutlet weak var symbolThree: UIImageView!
    @IBOutlet weak var symbolFour: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        monitorNetwork()
        
        if self.favoriteCheck == false && self.mapCheck == false {
            // Location manager used to get users current location
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            
        } else {
            // Methods in respond to segue from MapController or FavoritesController
            let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            self.getCurrentWeather(coordinates: coordinate)
            self.animateActivityIndicator(should: true)
        }
    }
    
    // MARK: Functions
    
    /// Function to monitor network changes and react accordingly
    fileprivate func checkNetwork() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = {
            path in
            
            if path.status != .satisfied {
                
                DispatchQueue.main.async {
                    self.showFailure(message: "Please connect to a network")
                }
            } else {
                print("There is an internet connection")
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    /// Function that retrieves weather information
    fileprivate func getCurrentWeather(coordinates: CLLocationCoordinate2D) {
        WeatherClient.getCurrentWeather(latitude: coordinates.latitude, longitude: coordinates.longitude) { [weak self] weather, error in
            
            guard let weather = weather, error == nil else {
                // No weather information received from the API
                print("Didnt get weather information")
                print(error?.localizedDescription.first ?? "")
                self?.animateActivityIndicator(should: false)
                if let errorDescription = error?.localizedDescription {
                    self?.showFailure(message: errorDescription)
                } else {
                    self?.showFailure(message: "An unknown error occured.")
                }
                return
            }
            var forecast = [ForecastObject]()
            for item in weather.dailyWeather {
                // Iterate over the items to populate the 5 day forecast
                let date = NSDate(timeIntervalSince1970: Double(item.date))
                let day = self?.dayOfWeek(date: date as Date)
                let dayForecast = ForecastObject(day: day!, weatherType: item.description.first!.type, temperature: Int(item.dayTemperature.forTheDay))
                forecast.append(dayForecast)
            }
            
            forecast.removeFirst()
            self?.fiveDayForecast = Array((forecast.prefix(5)))
            
            DispatchQueue.main.async {
                // Configure the view controller's views
                self?.degreeLabel.text = String(Int(weather.dailyWeather.first!.dayTemperature.forTheDay))
                self?.weatherLabel.text = weather.currentWeather.description.first?.type
                self?.minTempLabel.text = String(Int(weather.dailyWeather.first!.dayTemperature.minTemperature))
                self?.maxTempLabel.text = String(Int(weather.dailyWeather.first!.dayTemperature.maxTemperature))
                self?.currentTempLabel.text = String(Int(weather.currentWeather.temperature))
                self?.viewsSet = true
                self?.setupBackground(type: weather.currentWeather.description.first!.type)
            }
        }
    }
    
    /// Changes the background in response to forecast
    fileprivate func setupBackground(type: String) {
        // Configure view controllers background in response to weather information
        
        switch type {
        case "Clear":
            backgroundImage.image = UIImage(named: "forest_sunny")
            backgroundView.backgroundColor = UIColor(named: "sunny")
            contentViewColour = UIColor(named: "sunny")!
        case "Rain":
            backgroundImage.image = UIImage(named: "forest_rainy")
            backgroundView.backgroundColor = UIColor(named: "rainy")
            contentViewColour = UIColor(named: "rainy")!
        case "Clouds":
            backgroundImage.image = UIImage(named: "forest_cloudy")
            backgroundView.backgroundColor = UIColor(named: "cloudy")
            contentViewColour = UIColor(named: "cloudy")!
        case "Snow":
            backgroundImage.image = UIImage(named: "forest_snowy")
            backgroundView.backgroundColor = UIColor(named: "snow")
            contentViewColour = UIColor(named: "snow")!
        case "Fog":
            backgroundImage.image = UIImage(named: "forest_foggy")
            backgroundView.backgroundColor = UIColor(named: "fog")
            contentViewColour = UIColor(named: "fog")!
        default:
            backgroundImage.image = UIImage(named: "forest_sunny")
            backgroundView.backgroundColor = UIColor(named: "sunny")
            contentViewColour = UIColor(named: "sunny")!
        }
    }
    
    /// Function to format date
    fileprivate func dayOfWeek(date: Date) -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date).capitalized
        }
    
    /// Function to control the activity indicator
    fileprivate func animateActivityIndicator(should: Bool) {
        if should {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.hideViews(should: should)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.hideViews(should: should)
            }
        }
    }
    
    /// Function to show or hide views depending on availabilty of results
    fileprivate func hideViews(should: Bool) {
        if should {
            tableView.isHidden = true
            degreeLabel.isHidden = true
            weatherLabel.text = "Loading..."
            
            currentLabel.text = "..."
            minLabel.text = "..."
            maxLabel.text = "..."
            currentTempLabel.isHidden = true
            minTempLabel.isHidden = true
            maxTempLabel.isHidden = true
            
            symbolOne.isHidden = true
            symbolTwo.isHidden = true
            symbolThree.isHidden = true
            symbolFour.isHidden = true
        } else {
            tableView.isHidden = false
            degreeLabel.isHidden = false
            
            currentTempLabel.isHidden = false
            minTempLabel.isHidden = false
            maxTempLabel.isHidden = false
            currentLabel.text = "current"
            minLabel.text = "min"
            maxLabel.text = "max"
            
            symbolOne.isHidden = false
            symbolTwo.isHidden = false
            symbolThree.isHidden = false
            symbolFour.isHidden = false
        }
    }
    
    /// Geocoding to find city name from coordinates
    fileprivate func findCity(coordinates: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        
        // Find the name of the location given its coordinates
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("No Placemarks")
                return
            }
            
            self.navigationItem.title = placemark.locality
        }
    }

}

// MARK: TableView Methods

extension HomeController: UITableViewDataSource {
    
    /// Determine number of items table view should display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiveDayForecast.count
    }
    
    /// Configure each table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherViewCell", for: indexPath) as! WeatherViewCell
        let item = fiveDayForecast[indexPath.row]
        cell.contentView.backgroundColor = contentViewColour
        
        // Configure weather symbol depending on the weather type
        switch item.weatherType {
        case "Clear":
            cell.weatherSymbol.image = UIImage(named: "clear")
        case "Rain":
            cell.weatherSymbol.image = UIImage(named: "rain")
        case "Clouds":
            cell.weatherSymbol.image = UIImage(named: "clouds")
        case "Fog":
            cell.weatherSymbol.image = UIImage(named: "fog")
        case "Snow":
            cell.weatherSymbol.image = UIImage(named: "snow")
        default:
            cell.weatherSymbol.image = UIImage(named: "clear")
        }
        
        cell.dayLabel.text = item.day
        cell.degreeLabel.text = String(item.temperature)
        
        if indexPath.row == 0 {
            cell.dayLabel.text = "Tomorrow"
        }
        
        return cell
    }
    
}

// MARK: Location Manager Functions

extension HomeController: CLLocationManagerDelegate {
    
    /// Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        getCurrentWeather(coordinates: location.coordinate)
        findCity(coordinates: location.coordinate)
    }
    
    /// Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            showPermissionMessage()
            print("Location access was restricted.")
        case .denied:
            showPermissionMessage()
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("Location status is alright.")
            manager.requestLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            animateActivityIndicator(should: true)
            
        case .authorizedWhenInUse:
            print("Location status is OK.")
            manager.requestLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            animateActivityIndicator(should: true)
        @unknown default:
            fatalError()
        }
    }
    
    /// Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager.stopUpdatingLocation()
      print("Error: \(error)")
    }
    
}

